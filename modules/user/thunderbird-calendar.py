#!/usr/bin/env python3
"""Read-only bridge from Thunderbird's synchronized CalDAV event cache."""

import configparser
import datetime as dt
import json
import re
import shutil
import sqlite3
import tempfile
import time
from pathlib import Path


HOME = Path.home()
DB_NAME = "cache.sqlite"
WINDOW_START = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=30)
WINDOW_END = dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=400)


def active_profile():
    ini = configparser.ConfigParser(interpolation=None)
    ini.read(HOME / ".thunderbird" / "profiles.ini", encoding="utf-8")
    for section in ini.sections():
        if not section.startswith("Profile") or ini.get(section, "Default", fallback="0") != "1":
            continue
        profile = Path(ini.get(section, "Path"))
        if ini.get(section, "IsRelative", fallback="1") == "1":
            profile = HOME / ".thunderbird" / profile
        return profile
    raise FileNotFoundError("No default Thunderbird profile")


def calendar_registry(profile):
    prefs = profile / "prefs.js"
    pattern = re.compile(r'^user_pref\("calendar\.registry\.([^.]+)\.([^\"]+)",\s*(.*)\);$')
    registry = {}
    if not prefs.exists():
        return registry
    with prefs.open(encoding="utf-8", errors="replace") as source:
        for line in source:
            match = pattern.match(line.strip())
            if not match:
                continue
            calendar_id, key, raw = match.groups()
            try:
                value = json.loads(raw)
            except json.JSONDecodeError:
                continue
            registry.setdefault(calendar_id, {})[key] = value
    return {
        calendar_id: data
        for calendar_id, data in registry.items()
        if data.get("type") == "caldav" and not data.get("disabled", False)
    }


def stable_snapshot(database, target_dir):
    """Copy DB and WAL together; retry if Thunderbird writes during the copy."""
    target = target_dir / DB_NAME
    sidecars = [Path(str(database) + suffix) for suffix in ("", "-wal", "-shm")]
    for _ in range(4):
        before = []
        for path in sidecars:
            try:
                stat = path.stat()
                before.append((stat.st_size, stat.st_mtime_ns))
            except FileNotFoundError:
                before.append(None)
        for path, state in zip(sidecars, before):
            dest = Path(str(target) + str(path)[len(str(database)):])
            if state is None:
                dest.unlink(missing_ok=True)
            else:
                shutil.copy2(path, dest)
        after = []
        for path in sidecars:
            try:
                stat = path.stat()
                after.append((stat.st_size, stat.st_mtime_ns))
            except FileNotFoundError:
                after.append(None)
        if before == after:
            return target
        time.sleep(0.05)
    raise RuntimeError("Thunderbird calendar cache changed during snapshot")


def parse_until(value):
    if not value:
        return None
    value = value.strip()
    try:
        if re.fullmatch(r"\d{8}", value):
            return dt.datetime.strptime(value, "%Y%m%d").replace(tzinfo=dt.timezone.utc)
        return dt.datetime.strptime(value.rstrip("Z"), "%Y%m%dT%H%M%S").replace(tzinfo=dt.timezone.utc)
    except ValueError:
        return None


def parse_recurrence(text):
    rules = []
    excluded = set()
    for line in text.replace("\r", "").split("\n"):
        if line.startswith("RRULE:"):
            rules.append(dict(part.split("=", 1) for part in line[6:].split(";") if "=" in part))
        elif line.startswith("EXDATE") and ":" in line:
            values = line.split(":", 1)[1].split(",")
            for value in values:
                parsed = parse_until(value)
                if parsed:
                    excluded.add(int(parsed.timestamp() * 1000))
    return rules, excluded


def month_dates(year, month, base_day, rule):
    import calendar

    month_days = int(calendar.monthrange(year, month)[1])
    if "BYMONTHDAY" in rule:
        days = []
        for raw in rule["BYMONTHDAY"].split(","):
            value = int(raw)
            day = value if value > 0 else month_days + value + 1
            if 1 <= day <= month_days:
                days.append(day)
        return sorted(set(days))
    if "BYDAY" not in rule:
        return [base_day] if base_day <= month_days else []

    weekdays = {"MO": 0, "TU": 1, "WE": 2, "TH": 3, "FR": 4, "SA": 5, "SU": 6}
    result = []
    for entry in rule["BYDAY"].split(","):
        match = re.fullmatch(r"([+-]?\d+)?(MO|TU|WE|TH|FR|SA|SU)", entry)
        if not match:
            continue
        ordinal, name = match.groups()
        weekday = weekdays[name]
        matching = [day for day in range(1, month_days + 1) if dt.date(year, month, day).weekday() == weekday]
        if ordinal:
            index = int(ordinal)
            if index < 0:
                index = len(matching) + index + 1
            if 1 <= index <= len(matching):
                result.append(matching[index - 1])
        else:
            result.extend(matching)
    return sorted(set(result))


def occurrences(start, rule, excluded):
    freq = rule.get("FREQ", "").upper()
    interval = max(1, int(rule.get("INTERVAL", "1")))
    count_limit = int(rule["COUNT"]) if rule.get("COUNT", "").isdigit() else None
    until = parse_until(rule.get("UNTIL"))
    candidates = []
    base_date = start.date()

    if freq == "DAILY":
        day = base_date
        while day <= WINDOW_END.date():
            delta = (day - base_date).days
            if delta % interval == 0:
                candidates.append(dt.datetime.combine(day, start.timetz()))
            day += dt.timedelta(days=1)
    elif freq == "WEEKLY":
        days = {"MO": 0, "TU": 1, "WE": 2, "TH": 3, "FR": 4, "SA": 5, "SU": 6}
        weekdays = sorted({days[x] for x in rule.get("BYDAY", "").split(",") if x in days}) or [base_date.weekday()]
        week = base_date - dt.timedelta(days=base_date.weekday())
        while week <= WINDOW_END.date():
            weeks = (week - (base_date - dt.timedelta(days=base_date.weekday()))).days // 7
            if weeks % interval == 0:
                for weekday in weekdays:
                    day = week + dt.timedelta(days=weekday)
                    if day >= base_date:
                        candidates.append(dt.datetime.combine(day, start.timetz()))
            week += dt.timedelta(days=7)
    elif freq == "MONTHLY":
        month_index = base_date.year * 12 + base_date.month - 1
        last_index = WINDOW_END.year * 12 + WINDOW_END.month - 1
        for index in range(month_index, last_index + 1, interval):
            year, month0 = divmod(index, 12)
            for day in month_dates(year, month0 + 1, base_date.day, rule):
                date = dt.date(year, month0 + 1, day)
                if date >= base_date:
                    candidates.append(dt.datetime.combine(date, start.timetz()))
    elif freq == "YEARLY":
        for year in range(base_date.year, WINDOW_END.year + 1, interval):
            months = [int(x) for x in rule.get("BYMONTH", str(base_date.month)).split(",")]
            for month in months:
                for day in month_dates(year, month, base_date.day, rule):
                    date = dt.date(year, month, day)
                    if date >= base_date:
                        candidates.append(dt.datetime.combine(date, start.timetz()))

    candidates.sort()
    result = []
    for ordinal, occurrence in enumerate(candidates):
        if count_limit is not None and ordinal >= count_limit:
            break
        if until and occurrence > until:
            break
        stamp = int(occurrence.timestamp() * 1000)
        if WINDOW_START.timestamp() * 1000 <= stamp <= WINDOW_END.timestamp() * 1000 and stamp not in excluded:
            result.append(stamp)
    return result


def main():
    profile = active_profile()
    registry = calendar_registry(profile)
    database = profile / "calendar-data" / DB_NAME
    events = []
    if registry and database.exists():
        with tempfile.TemporaryDirectory(prefix="lucid-tb-calendar-") as td:
            snapshot = stable_snapshot(database, Path(td))
            db = sqlite3.connect(snapshot)
            db.row_factory = sqlite3.Row
            recurrence = {}
            for row in db.execute("SELECT cal_id, item_id, icalString FROM cal_recurrence"):
                recurrence[(row["cal_id"], row["item_id"])] = parse_recurrence(row["icalString"] or "")

            rows = list(db.execute(
                "SELECT cal_id, id, title, event_start, event_end, recurrence_id, ical_status "
                "FROM cal_events WHERE event_start IS NOT NULL"
            ))
            overrides = set()
            for row in rows:
                if row["recurrence_id"] is not None:
                    try:
                        overrides.add((row["cal_id"], row["id"], int(row["recurrence_id"])))
                    except (TypeError, ValueError):
                        pass

            for row in rows:
                cal_id = row["cal_id"]
                if cal_id not in registry or (row["ical_status"] or "").upper() == "CANCELLED":
                    continue
                try:
                    start_us = int(row["event_start"])
                except (TypeError, ValueError):
                    continue
                start_ms = start_us // 1000
                duration_ms = max(0, int(row["event_end"] or row["event_start"]) // 1000 - start_ms)
                title = (row["title"] or "(untitled event)").strip()
                cal_name = registry[cal_id].get("name") or "CalDAV"
                rule_data = recurrence.get((cal_id, row["id"]))
                starts = [start_ms]
                if rule_data:
                    rules, excluded = rule_data
                    if rules:
                        base = dt.datetime.fromtimestamp(start_ms / 1000, dt.timezone.utc)
                        starts = occurrences(base, rules[0], excluded)
                for occurrence_ms in starts:
                    if (cal_id, row["id"], occurrence_ms * 1000) in overrides:
                        continue
                    if not (WINDOW_START.timestamp() * 1000 <= occurrence_ms <= WINDOW_END.timestamp() * 1000):
                        continue
                    events.append({
                        "id": f"{cal_id}:{row['id']}:{occurrence_ms}",
                        "name": title,
                        "calendar": cal_name,
                        "startMs": occurrence_ms,
                        "endMs": occurrence_ms + duration_ms,
                    })
            db.close()

    events.sort(key=lambda event: (event["startMs"], event["name"].casefold()))
    print(json.dumps({"events": events}, ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Keep refresh failures out of Lucid's console: current calendar events
        # remain visible until the next successful sync.
        print(json.dumps({"events": [], "error": "Thunderbird calendar cache unavailable"}))
