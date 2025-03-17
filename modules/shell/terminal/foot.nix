{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.terminal.foot;
  terminalConfig = config.modules.shell.terminal;
in {
  options.modules.shell.terminal.foot = {
    enable = lib.mkEnableOption "Enable Foot terminal";
    
    server = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable foot server for faster startup";
    };
    
    pad = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Terminal padding";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      foot
    ];
    
    home-manager.users.${config.user.name} = { ... }: {
      programs.foot = {
        enable = true;
        server.enable = cfg.server;
        
        settings = {
          main = {
            font = "${terminalConfig.font.family}:size=${toString terminalConfig.font.size}";
            pad = "${toString cfg.pad}x${toString cfg.pad}";
            term = "xterm-256color";
          };
          
          scrollback = {
            lines = terminalConfig.scrollback;
          };
          
          cursor = {
            style = "beam";
            blink = true;
          };
          
          colors = {
            alpha = terminalConfig.opacity;
            background = config.theme.colors.background;
            foreground = config.theme.colors.foreground;
          };
        };
      };
    };
  };
}
