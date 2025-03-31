{ lib }:

{
  # Function to import all nix files from a directory into an attribute set
  importDirToAttrs = dir: 
    lib.mapAttrs'
      (name: _: lib.nameValuePair 
        (lib.removeSuffix ".nix" name)
        (import (dir + "/${name}")))
      (lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        (builtins.readDir dir));
}
