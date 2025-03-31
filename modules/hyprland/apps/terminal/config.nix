{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.antonio = {
      programs.kitty = {
        enable = true;
        font = {
          name = "FiraCode Nerd Font";
          size = 11;
        };
        settings = {
          scrollback_lines = 10000;
          enable_audio_bell = false;
          background_opacity = "0.95";
          window_padding_width = 10;
          confirm_os_window_close = 0;
        };
        theme = "Dracula";
        shellIntegration.enableZshIntegration = true;
      };
    };
  };
}
