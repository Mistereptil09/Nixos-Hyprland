{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.ssh;
in {
  options.modules.shell.ssh = {
    enable = lib.mkEnableOption "Enable SSH configuration";
    
    matchBlocks = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "SSH host configurations";
    };
    
    forwardAgent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable SSH agent forwarding";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level SSH configuration
    programs.ssh.startAgent = true;
    
    # User-level configuration
    home-manager.users.${config.user.name} = { ... }: {
      programs.ssh = {
        enable = true;
        matchBlocks = cfg.matchBlocks;
        forwardAgent = cfg.forwardAgent;
        serverAliveInterval = 60;
      };
    };
  };
}
