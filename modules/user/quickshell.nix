{ pkgs, config, ... }: let
  c = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.sansSerif.name;
in {
  programs.quickshell = {
    enable = true;
    activeConfig = "control-center";

    configs = {
      control-center = pkgs.writeTextDir "shell.qml" ''
        import Quickshell
        import Quickshell.Wayland
        import Quickshell.Hyprland
        import QtQuick
        import QtQuick.Layouts

        PanelWindow {
          id: root

          anchors {
            top: true
            right: true
          }

          implicitWidth: 360
          implicitHeight: wrapper.implicitHeight

          color: "transparent"

          margins {
            top: -12
            right: 0
          }

          exclusionMode: ExclusionMode.Normal
          exclusiveZone: 0

          WlrLayershell.namespace: "qs-control-center"
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

          Item {
            id: wrapper

            anchors.fill: parent

            readonly property int outerMargin: 12
            readonly property int innerMargin: 18
            readonly property int buttonHeight: 48
            readonly property int spacingSize: 14

            implicitWidth: 360
            implicitHeight: panel.implicitHeight + outerMargin * 2

            Rectangle {
              id: panel

              x: wrapper.outerMargin
              y: wrapper.outerMargin
              width: parent.width - wrapper.outerMargin * 2
              height: implicitHeight

              implicitHeight: content.implicitHeight + wrapper.innerMargin * 2

              radius: 20
              color: "${c.base00}"
              border.color: "${c.base03}"
              border.width: 1

              ColumnLayout {
                id: content

                x: wrapper.innerMargin
                y: wrapper.innerMargin
                width: parent.width - wrapper.innerMargin * 2

                spacing: wrapper.spacingSize

                Text {
                  text: "Control Center"
                  color: "${c.base05}"
                  font.family: "${font}"
                  font.pixelSize: 22
                  font.bold: true
                }

                Rectangle {
                  Layout.fillWidth: true
                  height: wrapper.buttonHeight
                  radius: 12
                  color: audioMouse.containsMouse ? "${c.base02}" : "${c.base01}"
                  border.color: "${c.base03}"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "Audio settings"
                    color: "${c.base05}"
                    font.family: "${font}"
                    font.pixelSize: 15
                  }

                  MouseArea {
                    id: audioMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("exec pavucontrol")
                  }
                }

                Rectangle {
                  Layout.fillWidth: true
                  height: wrapper.buttonHeight
                  radius: 12
                  color: networkMouse.containsMouse ? "${c.base02}" : "${c.base01}"
                  border.color: "${c.base03}"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "Network settings"
                    color: "${c.base05}"
                    font.family: "${font}"
                    font.pixelSize: 15
                  }

                  MouseArea {
                    id: networkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("exec nm-connection-editor")
                  }
                }

                Rectangle {
                  Layout.fillWidth: true
                  height: wrapper.buttonHeight
                  radius: 12
                  color: bluetoothMouse.containsMouse ? "${c.base02}" : "${c.base01}"
                  border.color: "${c.base03}"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "Bluetooth"
                    color: "${c.base05}"
                    font.family: "${font}"
                    font.pixelSize: 15
                  }

                  MouseArea {
                    id: bluetoothMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("exec blueman-manager")
                  }
                }

                Rectangle {
                  Layout.fillWidth: true
                  height: 1
                  color: "${c.base03}"
                }

                Text {
                  text: "Quickshell + Hyprland"
                  color: "${c.base04}"
                  font.family: "${font}"
                  font.pixelSize: 13
                }
              }
            }
          }

        }
      '';
    };
  };
}
