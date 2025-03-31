{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
  username = config.user.name;
in {
  config = lib.mkIf cfg.enable {
    # User-level configuration via home-manager
    home-manager.users.${username} = { ... }: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = {
          monitor = "eDP-1,1920x1080@60,0x0,1";
          
          exec-once = [
            "hyprpaper"
          ];
          
          bind = [
            "SUPER, Return, exec, ${cfg.terminal}"
            "SUPER, Q, killactive,"
            "SUPER, M, exit,"
            "SUPER, Space, exec, wofi --show drun"
          ];
          
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
          };
        };
        
        extraConfig = cfg.extraConfig;
      };
    };
  };
}
