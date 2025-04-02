{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.editor.neovim;
in {
  options.modules.editor.neovim = {
    enable = mkEnableOption "Neovim editor";
  };

  config = mkIf cfg.enable {
    # System configuration
    environment.systemPackages = with pkgs; [
      neovim
    ];

    # Home-manager configuration
    home-manager.users.${config.user.name} = { ... }: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };
    };
  };
}