{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.terminal.alacritty;
  terminalConfig = config.modules.shell.terminal;
in {
  options.modules.shell.terminal.alacritty = {
    enable = lib.mkEnableOption "Enable Alacritty terminal";
    
    decorations = lib.mkOption {
      type = lib.types.enum [ "full" "none" "buttonless" "transparent" ];
      default = "full";
      description = "Window decoration mode";
    };
    
    dynamicTitle = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable dynamic title";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty
    ];
    
    home-manager.users.${config.user.name} = { ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            padding = {
              x = 10;
              y = 10;
            };
            decorations = cfg.decorations;
            opacity = terminalConfig.opacity;
            dynamic_title = cfg.dynamicTitle;
          };
          
          font = {
            normal.family = terminalConfig.font.family;
            size = terminalConfig.font.size;
          };
          
          scrolling.history = terminalConfig.scrollback;
          
          colors = {
            primary = {
              background = config.theme.colors.background;
              foreground = config.theme.colors.foreground;
            };
          };
        };
      };
    };
  };
}
