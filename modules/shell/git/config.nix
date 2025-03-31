{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = lib.mkDefault "Antonio";
    userEmail = lib.mkDefault "user@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
