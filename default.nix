{ }:

let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "claude-code"
      ];
  };
  fence-claude = pkgs.callPackage ./nix/fence-claude.nix { };
  fence-pi = pkgs.callPackage ./nix/fence-pi.nix { };
in

fence-claude
// {
  inherit fence-claude;
  inherit fence-pi;
}
