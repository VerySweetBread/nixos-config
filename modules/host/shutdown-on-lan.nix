{ pkgs, lib, ... }:
  let
    sol = pkgs.writers.writePython3 "shutdown-on-lan.py" {
      libraries = [ pkgs.python313Packages.psutil ];
      flakeIgnore = [ "E302" "E305" "E501" "E701" ];
    } /*py*/ ''
      # https://habr.com/ru/articles/816765/

      import socket
      import os
      import logging
      import psutil
      from time import sleep

      WOL_PORT = 9

      logging.basicConfig(format='%(levelname)s: %(asctime)s %(message)s', level=logging.INFO)
      logger = logging.getLogger(__name__)

      def get_ip_mac_address() -> tuple:
          ip_addr = mac_addr = None

          while not ip_addr or not mac_addr or ip_addr == '127.0.0.1':
              nets = psutil.net_if_addrs()
              for net in list(nets.keys())[::-1]:
                  if net in ('lo', 'tun0'): continue
                  logger.debug(str(net))
                  for item in nets[net]:
                      # logger.debug(str(item))
                      addr = item.address
                      logger.debug(addr)
                      # В IPv4-адресах разделители - точки
                      if '.' in addr:
                          ip_addr = addr
                      # В MAC-адресах разделители либо тире, либо одинарное двоеточие.
                      # Двойное двоеточие - это разделители для адресов IPv6
                      elif ('-' in addr or ':' in addr) and '::' not in addr:
                          # Приводим MAC-адрес к одному формату. Формат может меняться в зависимости от ОС
                          mac_addr = addr.replace(':', '-').upper()
              if not ip_addr or not mac_addr or ip_addr == '127.0.0.1':
                  logger.error('Не удалось получить IP или MAC-адрес сетевого интерфейса')
                  sleep(10)
          logger.debug(mac_addr)
          return ip_addr, mac_addr

      def assemble_wol_packet(mac_address: str) -> str:
          return f'{"FF-" * 6}{(mac_address + "-") * 16}'

      def check_is_wol_packet(raw_bytes: bytes, assembled_wol_packet: str) -> int:
          return '-'.join(f'{byte:02x}' for byte in raw_bytes).upper() + '-' == assembled_wol_packet
    
      def run_udp_port_listener(port: int):
          ip_addr, mac_addr = get_ip_mac_address()
          server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
          server_socket.bind((ip_addr, port))
          logger.info(f'Listening on {ip_addr}:{port}')
          assembled_wol_packet = assemble_wol_packet(mac_addr)
          while True:
              data, _ = server_socket.recvfrom(1024)
              if check_is_wol_packet(data, assembled_wol_packet):
                  if os.name == 'posix':
                      os.system('shutdown -h now')
                  elif os.name == 'nt':
                      os.system('shutdown -s -t 0 -f')
      run_udp_port_listener(WOL_PORT)
    '';
  in {
    systemd.services.shutdown-on-lan = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = sol;
    };

    networking.firewall.allowedUDPPorts = [ 9 ];
  }
