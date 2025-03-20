{
  # Desktop environment configurations
  hyprland = import ./desktop/hyprland.nix;
  waybar = import ./desktop/waybar.nix;
  
  # Shell configurations
  shell = import ./shell;
  
  # Application configurations
  terminal = import ./apps/terminal.nix;
  browser = import ./apps/browser.nix;
  
  # Theme configurations
  theming = import ./theming;
}
