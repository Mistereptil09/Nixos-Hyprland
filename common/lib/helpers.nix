{ lib }:

{
  # Function to import all nix files from a directory into an attribute set
  importDirToAttrs = dir:
    let
      # Get all nix files in the directory
      files = lib.filterAttrs 
        (n: v: v == "regular" && lib.hasSuffix ".nix" n && n != "default.nix") 
        (builtins.readDir dir);
      
      # Convert each file to an attribute
      fileToAttr = file: {
        name = lib.removeSuffix ".nix" file;
        value = import (dir + "/${file}");
      };
      
      # Create attribute set from all files
      fileAttrs = lib.mapAttrs' 
        (name: _: { name = lib.removeSuffix ".nix" name; value = import (dir + "/${name}"); }) 
        files;
        
      # Also include any subdirectories with default.nix
      dirs = lib.filterAttrs 
        (n: v: v == "directory" && builtins.pathExists (dir + "/${n}/default.nix")) 
        (builtins.readDir dir);
        
      # Convert directories to attributes
      dirAttrs = lib.mapAttrs' 
        (name: _: { name = name; value = import (dir + "/${name}"); }) 
        dirs;
    in
      # Merge both attribute sets
      fileAttrs // dirAttrs // 
      # Include default.nix if it exists
      (lib.optionalAttrs (builtins.pathExists (dir + "/default.nix")) {
        default = import (dir + "/default.nix");
      });
}
