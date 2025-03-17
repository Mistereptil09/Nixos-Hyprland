{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.nix;
in {
  options.modules.core.nix = {
    enable = lib.mkEnableOption "Enable Nix configuration";
    
    optimizeStore = lib.mkEnableOption "Enable Nix store optimization";
    
    gc = {
      enable = lib.mkEnableOption "Enable Nix garbage collection";
      
      automatic = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automatically run GC";
      };
      
      dates = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "When to run the garbage collector";
      };
      
      options = lib.mkOption {
        type = lib.types.str;
        default = "--delete-older-than 30d";
        description = "Options to pass to nix-collect-garbage";
      };
      
      persistent = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Persist garbage collection on power off";
      };
    };
    
    autoOptimiseStore = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically optimize the Nix store";
    };
    
    readOnlyStore = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Make the Nix store read-only";
    };
    
    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow unfree packages";
    };
    
    allowBroken = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow broken packages";
    };
    
    enableFlakes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable flakes and new command-line interface";
    };
    
    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["root" "@wheel"];
      description = "Trusted users for Nix operations";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = cfg.autoOptimiseStore;
        trusted-users = cfg.trustedUsers;
      };
      
      # Garbage collection
      gc = {
        automatic = cfg.gc.enable && cfg.gc.automatic;
        dates = cfg.gc.dates;
        options = cfg.gc.options;
        persistent = cfg.gc.enable && cfg.gc.persistent;
      };
      
      # Store optimization
      optimise.automatic = cfg.optimizeStore;
      
      # Read-only store
      readOnlyStore = cfg.readOnlyStore;
      
      # Flakes support
      extraOptions = lib.optionalString cfg.enableFlakes ''
        experimental-features = nix-command flakes
      '';
    };
    
    # Allow unfree and broken packages if configured
    nixpkgs.config = {
      allowUnfree = cfg.allowUnfree;
      allowBroken = cfg.allowBroken;
    };
    
    # Add nix utilities to system packages
    environment.systemPackages = with pkgs; [
      nix-index  # File database for nixpkgs
      nix-top    # Tracking nix builds
      nixpkgs-fmt # Formatter for Nix code
    ];
  };
}
