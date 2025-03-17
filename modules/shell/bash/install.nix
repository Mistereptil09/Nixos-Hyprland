{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.bash;
in {
  config = lib.mkIf cfg.enable {
    # System-level bash setup
    programs.bash = {
      enableCompletion = true;
      enableLsColors = true;
      
      # System-wide bashrc additions
      interactiveShellInit = ''
        # System-wide bash configuration
        export HISTSIZE=${toString cfg.historySize}
        export HISTFILESIZE=${toString cfg.historySize}
        export HISTCONTROL=${lib.concatStringsSep ":" cfg.historyControl}
        export HISTIGNORE=${lib.concatStringsSep ":" cfg.historyIgnore}
      '';
    };
    
    # Make sure bash is installed
    environment.systemPackages = with pkgs; [
      bash
      bash-completion
    ];
  };
}
