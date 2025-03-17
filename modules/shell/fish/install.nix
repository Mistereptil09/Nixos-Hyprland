{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.fish;
in {
  config = lib.mkIf cfg.enable {
    # System-level fish setup
    programs.fish.enable = true;
    
    # Ensure fish is installed
    environment.systemPackages = with pkgs; [
      fish
    ];
  };
}
