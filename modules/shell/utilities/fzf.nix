{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.utilities.fzf;
in {
  options.modules.shell.utilities.fzf = {
    enable = lib.mkEnableOption "Enable fzf fuzzy finder";
    
    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Bash integration";
    };
    
    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Zsh integration";
    };
    
    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Fish integration";
    };
    
    defaultCommand = lib.mkOption {
      type = lib.types.str;
      default = "fd --type f";
      description = "Default command to use when input is tty";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install fzf at system level
    environment.systemPackages = with pkgs; [
      fzf
    ];
    
    # User-level configuration
    home-manager.users.${config.user.name} = { ... }: {
      programs.fzf = {
        enable = true;
        enableBashIntegration = cfg.enableBashIntegration;
        enableZshIntegration = cfg.enableZshIntegration;
        enableFishIntegration = cfg.enableFishIntegration;
        defaultCommand = cfg.defaultCommand;
        fileWidgetCommand = "${cfg.defaultCommand} --color=always";
        fileWidgetOptions = [
          "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        ];
        changeDirWidgetCommand = "fd --type d";
        changeDirWidgetOptions = [
          "--preview 'eza --tree --color=always --level=2 {}'"
        ];
        colors = {
          # Use theme colors
          fg = config.theme.colors.foreground;
          bg = config.theme.colors.background;
          hl = config.theme.colors.primary;
        };
      };
    };
  };
}
