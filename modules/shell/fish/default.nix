{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];
  
  options.modules.shell.fish = {
    enable = lib.mkEnableOption "Enable Fish shell";
    
    interactiveShellInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Commands to run when starting an interactive shell";
    };
    
    loginShellInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Commands to run when starting a login shell";
    };
    
    promptInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Custom prompt configuration for fish (if starship is not enabled)";
    };
    
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Fish plugins to install";
      example = "[ pkgs.fishPlugins.done pkgs.fishPlugins.fzf-fish ]";
    };
  };
}
