{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.antonio = {
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            
            modules-left = ["hyprland/workspaces" "hyprland/window"];
            modules-center = ["clock"];
            modules-right = ["pulseaudio" "network" "cpu" "memory" "battery" "tray"];
            
            "hyprland/workspaces" = {
              format = "{name}";
              active-only = false;
              on-click = "activate";
            };
            
            "clock" = {
              format = "{:%H:%M}";
              format-alt = "{:%Y-%m-%d}";
              tooltip-format = "{:%Y-%m-%d | %H:%M:%S}";
            };
            
            "cpu" = {
              format = " {usage}%";
              interval = 1;
            };
            
            "memory" = {
              format = " {}%";
              interval = 1;
            };
            
            "battery" = {
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-alt = "{time} {icon}";
              format-icons = ["" "" "" "" ""];
            };
            
            "network" = {
              format-wifi = " {essid} ({signalStrength}%)";
              format-ethernet = " {ifname}";
              format-linked = " {ifname} (No IP)";
              format-disconnected = "⚠ Disconnected";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
            };
            
            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}% ";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}%";
              format-source-muted = "";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" "" ""];
              };
              on-click = "pavucontrol";
            };
            
            "tray" = {
              icon-size = 21;
              spacing = 10;
            };
          };
        };
        
        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: "Fira Sans Semibold", "Font Awesome 6 Free";
            font-size: 13px;
            min-height: 0;
          }

          window#waybar {
            background: rgba(21, 18, 27, 0.9);
            color: #cdd6f4;
          }

          tooltip {
            background: #1e1e2e;
            border-radius: 10px;
            border-width: 2px;
            border-style: solid;
            border-color: #11111b;
          }

          #workspaces button {
            padding: 5px;
            color: #313244;
            margin-right: 5px;
          }

          #workspaces button.active {
            color: #a6adc8;
            background: #eba0ac;
            border-radius: 10px;
          }

          #workspaces button:hover {
            background: #11111b;
            color: #cdd6f4;
            border-radius: 10px;
          }

          #window,
          #clock,
          #battery,
          #pulseaudio,
          #network,
          #workspaces,
          #tray,
          #cpu,
          #memory {
            background: #1e1e2e;
            padding: 0px 10px;
            margin: 3px 0px;
            border: 1px solid #181825;
            border-radius: 10px;
          }

          #tray {
            border-radius: 10px;
            margin-right: 10px;
          }

          #workspaces {
            background: #1e1e2e;
            border-radius: 10px;
            margin-left: 10px;
            padding-right: 0px;
            padding-left: 5px;
          }

          #window {
            margin-left: 10px;
            margin-right: 10px;
          }

          #pulseaudio {
            color: #89b4fa;
            border-radius: 10px 0px 0px 10px;
            margin-right: 0px;
          }

          #network {
            color: #f9e2af;
            border-radius: 10px 0px 0px 10px;
            margin-right: 0px;
          }

          #cpu {
            color: #a6e3a1;
            border-radius: 0px;
            margin-right: 0px;
          }

          #memory {
            color: #fab387;
            border-radius: 0px 10px 10px 0px;
            margin-right: 10px;
          }

          #battery {
            color: #a6e3a1;
            border-radius: 0 10px 10px 0;
            margin-right: 10px;
          }

          #battery.charging, #battery.plugged {
            color: #a6e3a1;
          }

          #battery.critical:not(.charging) {
            color: #f38ba8;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          @keyframes blink {
            to {
              background-color: #f38ba8;
              color: #1e1e2e;
            }
          }
        '';
      };
    };
  };
}
