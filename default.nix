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
  devshell = import sources.devshell { nixpkgs = pkgs; };
  fence-claude = pkgs.callPackage ./nix/fence-claude.nix { };
in

devshell.mkShell {
  packages = [
    fence-claude
  ];
}
// {
  inherit fence-claude;
}
