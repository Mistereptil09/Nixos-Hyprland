{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.tmux;
in {
  config = lib.mkIf cfg.enable {
    # Install tmux at system level
    environment.systemPackages = with pkgs; [
      tmux
    ];
    
    # Add system-level tmux configuration
    environment.etc."tmux.conf".text = ''
      # System-wide tmux configuration
      set -g default-terminal "${cfg.terminal}"
      set -g history-limit ${toString cfg.historyLimit}
      set -g mouse on
    '';
  };
}
