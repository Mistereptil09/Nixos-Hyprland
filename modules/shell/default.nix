{ config, lib, pkgs, ... }:

{
  # Import all shell modules
  imports = [
    ./zsh
    ./bash
    ./fish
    ./git
    ./tmux
    ./starship
    ./terminal
    ./utilities
    ./env.nix
    ./ssh.nix
  ];
  
  # Shell module options
  options.modules.shell = {
    # Common shell options can go here
    defaultShell = lib.mkOption {
      type = lib.types.enum [ "bash" "zsh" "fish" ];
      default = "fish";  # defaults the shell to fish
      description = "Default shell to use system-wide";
    };
  };
  
  # Common shell configuration
  config = {
    # Default system-wide shell settings
    programs.bash.enableCompletion = true;
    
    # Enable command not found handler
    programs.command-not-found.enable = true;
    
    # Set user's default shell based on the configuration
    users.users.${config.user.name}.shell = lib.mkIf (config.modules.shell.${config.modules.shell.defaultShell}.enable or false) 
      pkgs.${config.modules.shell.defaultShell};
    
    # Module dependencies and assertions
    assertions = [
      {
        assertion = config.modules.shell.terminal.default != "none" -> 
                   config.modules.shell.terminal.${config.modules.shell.terminal.default}.enable;
        message = "Selected terminal emulator must be enabled";
      }
      {
        assertion = config.modules.shell.starship.enable -> (
          (config.modules.shell.zsh.enable -> config.modules.shell.starship.enableZshIntegration) &&
          (config.modules.shell.bash.enable -> config.modules.shell.starship.enableBashIntegration) &&
          (config.modules.shell.fish.enable -> config.modules.shell.starship.enableFishIntegration)
        );
        message = "Starship must be integrated with enabled shells";
      }
    ];
    
    # Enable default modules
    modules.shell = {
      # Set up the selected default shell
      bash.enable = config.modules.shell.defaultShell == "bash";
      zsh.enable = config.modules.shell.defaultShell == "zsh";
      fish.enable = config.modules.shell.defaultShell == "fish";
      
      # Environment variables
      env = {
        enable = true;
        variables = {
          EDITOR = "vim";
          VISUAL = "vim";
          PAGER = "less";
        };
        path = [ "$HOME/.local/bin" ];
      };
      
      # Terminal utilities
      utilities = {
        enable = true;
        fzf.enable = lib.mkDefault true;
        direnv.enable = lib.mkDefault true;
        zoxide.enable = lib.mkDefault true;
        modern-unix = lib.mkDefault true;
      };
      
      # Terminal emulator
      terminal = {
        default = lib.mkDefault "kitty";
      };
      
      # Enable SSH by default
      ssh.enable = lib.mkDefault true;
    };
  };
}
