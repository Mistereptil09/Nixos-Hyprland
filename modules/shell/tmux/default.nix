{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];

  options.modules.shell.tmux = {
    enable = lib.mkEnableOption "Enable tmux terminal multiplexer";
    
    # Shell integration options
    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Bash integration for tmux";
    };
    
    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Zsh integration for tmux";
    };
    
    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Fish integration for tmux";
    };
    
    # Other tmux configuration options
    keyMode = lib.mkOption {
      type = lib.types.enum ["emacs" "vi"];
      default = "emacs";
      description = "Set the key binding mode for tmux";
    };
    
    shortcut = lib.mkOption {
      type = lib.types.str;
      default = "b";
      description = "The prefix key, default is C-b";
    };
    
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "screen-256color";
      description = "Set the default terminal";
    };
    
    historyLimit = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Set the scrollback history limit";
    };
    
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional configuration to add to tmux.conf";
    };
  };
}
