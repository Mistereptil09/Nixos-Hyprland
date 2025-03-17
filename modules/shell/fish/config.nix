{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.fish;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.fish = {
        enable = true;
        
        # Interactive shell initialization
        interactiveShellInit = ''
          # Set Fish to not greet on start
          set -U fish_greeting ""
          
          # Set vi mode
          fish_vi_key_bindings
          
          # Source additional interactive initialization
          ${cfg.interactiveShellInit}
        '';
        
        # Login shell initialization
        loginShellInit = cfg.loginShellInit;
        
        # Custom prompt if starship is not enabled
        promptInit = lib.mkIf (!config.modules.shell.starship.enable) ''
          # Custom fish prompt if starship is not enabled
          ${cfg.promptInit}
        '';
        
        # Common fish functions
        functions = {
          # Update function wrapping common Nix commands
          nix-update = ''
            echo "Updating NixOS and Home Manager..."
            sudo nixos-rebuild switch --flake .
            echo "Update complete!"
          '';
          
          # Fish equivalent of cd -
          back = ''
            if test -n "$argv[1]"
              cd -$argv[1]
            else
              cd -
            end
          '';
        };
        
        # Fish plugins
        plugins = cfg.plugins;
      };
    };
  };
}
