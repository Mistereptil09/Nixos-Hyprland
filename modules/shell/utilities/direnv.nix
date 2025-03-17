{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.utilities.direnv;
in {
  options.modules.shell.utilities.direnv = {
    enable = lib.mkEnableOption "Enable direnv for directory-based environments";
    
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
    
    nix-direnv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the nix-direnv implementation (faster and more reliable with NixOS)";
    };
    
    flakesSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable support for Nix flakes in direnv";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level packages
    environment.systemPackages = with pkgs; [
      direnv
    ] ++ lib.optionals cfg.nix-direnv [ nix-direnv ];
    
    # User-level configuration
    home-manager.users.${config.user.name} = { ... }: {
      programs.direnv = {
        enable = true;
        enableBashIntegration = cfg.enableBashIntegration;
        enableZshIntegration = cfg.enableZshIntegration;
        enableFishIntegration = cfg.enableFishIntegration;
        nix-direnv = {
          enable = cfg.nix-direnv;
        };
        
        # Enhanced direnv setup for NixOS
        stdlib = lib.optionalString cfg.flakesSupport ''
          # Flakes integration for direnv
          use_flake() {
            watch_file flake.nix
            watch_file flake.lock
            eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile" "$@")"
          }
        '';
      };
      
      # Configuration file
      xdg.configFile."direnv/direnvrc".text = ''
        # Enable better debugging
        export DIRENV_LOG_FORMAT=""
        
        # Use faster nix-direnv implementation
        ${lib.optionalString cfg.nix-direnv ''
          if type nix_direnv_version 2>&1 > /dev/null; then
            source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
          fi
        ''}
        
        # Example .envrc for Nix projects:
        # use nix     # For traditional nix-shell
        # use flake   # For flakes-based projects
      '';
    };
  };
}
