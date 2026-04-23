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
  fence-agent = pkgs.callPackage ./nix/fence-agent.nix {
    # For new config `allowLocalOutboundPorts`
    fence = pkgs.fence.overrideAttrs (old: {
      version = "0.1.50";
      src = old.src.override {
        hash = "sha256-avWQkOWRf1qby/wUSieDiusX5M1Vg00CrvclOZFvp5s=";
      };
      vendorHash = "sha256-JIkEe+wscowc1IT8gtm5C4ZnChsOhy5wTy7R//DLFTU=";
    });
  };
  fence-claude = pkgs.callPackage ./nix/fence-claude.nix { inherit fence-agent; };
  fence-pi = pkgs.callPackage ./nix/fence-pi.nix { inherit fence-agent; };
in

fence-claude
// {
  inherit fence-claude;
  inherit fence-pi;
}
