{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];
  
  options.modules.shell.bash = {
    enable = lib.mkEnableOption "Enable Bash shell";
    
    historySize = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Size of the bash history";
    };
    
    historyControl = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ignoredups" "ignorespace" ];
      description = "Bash history control settings";
    };
    
    historyIgnore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ls" "cd" "exit" ];
      description = "Commands to ignore in history";
    };
    
    shellOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "autocd"
      ];
      description = "Bash shell options to enable";
    };
    
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration for bashrc";
    };
  };
}
