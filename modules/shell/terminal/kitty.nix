{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.terminal.kitty;
  terminalConfig = config.modules.shell.terminal;
in {
  options.modules.shell.terminal.kitty = {
    enable = lib.mkEnableOption "Enable Kitty terminal";
    
    theme = lib.mkOption {
      type = lib.types.str;
      default = "Tokyo Night";
      description = "Kitty theme to use";
      example = "Dracula";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kitty
    ];
    
    home-manager.users.${config.user.name} = { ... }: {
      programs.kitty = {
        enable = true;
        font = {
          name = terminalConfig.font.family;
          size = terminalConfig.font.size;
        };
        settings = {
          scrollback_lines = terminalConfig.scrollback;
          background_opacity = toString terminalConfig.opacity;
          enable_audio_bell = false;
          window_padding_width = 4;
          update_check_interval = 0;
          confirm_os_window_close = 0;
          
          # Use colors from theme
          background = config.theme.colors.background;
          foreground = config.theme.colors.foreground;
        };
        
        theme = cfg.theme;
      };
    };
  };
}
