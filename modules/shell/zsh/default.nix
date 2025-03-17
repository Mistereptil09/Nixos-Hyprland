{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];

  options.modules.shell.zsh = {
    enable = lib.mkEnableOption "Enable ZSH shell";
    
    historySize = lib.mkOption {
      type = lib.types.int;
      default = 50000;
      description = "Size of the ZSH history file";
    };
    
    autoSuggestions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ZSH auto-suggestions";
    };
    
    syntaxHighlighting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ZSH syntax highlighting";
    };
    
    autocd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically change directory without typing cd";
    };
    
    defaultKeymap = lib.mkOption {
      type = lib.types.enum [ "emacs" "viins" "vicmd" ];
      default = "emacs";
      description = "Default keymap for ZSH";
    };
    
    initExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration for zshrc";
    };
    
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "ZSH plugins to load";
      example = lib.literalExpression ''
        [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.5.0";
              sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
            };
          }
        ]
      '';
    };
  };
}
