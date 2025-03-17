{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.starship;
  
  # Predefined presets
  presets = {
    plain = {};
    
    "nerd-font" = {
      add_newline = true;
      format = "$all";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      aws.symbol = "  ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      python.symbol = " ";
      rust.symbol = " ";
    };
    
    "tokyo-night" = {
      format = "$all";
      palette = "tokyo-night";
      palettes.tokyo-night = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        blue = "#7aa2f7";
        green = "#9ece6a";
        red = "#f7768e";
        yellow = "#e0af68";
        purple = "#bb9af7";
        cyan = "#7dcfff";
      };
    };
    
    pastel = {
      add_newline = true;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
      };
      git_branch = {
        symbol = " ";
        style = "bold yellow";
      };
      directory = {
        style = "bold cyan";
      };
    };
    
    minimal = {
      add_newline = false;
      format = "$character";
      character = {
        success_symbol = "$";
        error_symbol = "!";
      };
    };
    
    none = {};
  };
  
  # Get the selected preset, or empty if "none"
  selectedPreset = if cfg.preset == "none" then {} else presets.${cfg.preset};
  
  # Merge the selected preset with user settings
  finalSettings = lib.recursiveUpdate selectedPreset cfg.settings;
  
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.starship = {
        enable = true;
        
        # Integration with various shells
        enableBashIntegration = cfg.enableBashIntegration;
        enableZshIntegration = cfg.enableZshIntegration;
        enableFishIntegration = cfg.enableFishIntegration;
        
        # Apply settings merged from preset and user config
        settings = finalSettings;
      };
      
      # For Bash integration
      programs.bash = lib.mkIf cfg.enableBashIntegration {
        enable = true;
        initExtra = ''
          eval "$(starship init bash)"
        '';
      };
      
      # For Zsh integration
      programs.zsh = lib.mkIf cfg.enableZshIntegration {
        enable = true;
        initExtra = ''
          eval "$(starship init zsh)"
        '';
      };
      
      # For Fish integration
      programs.fish = lib.mkIf cfg.enableFishIntegration {
        enable = true;
        interactiveShellInit = ''
          starship init fish | source
        '';
      };
    };
  };
}
