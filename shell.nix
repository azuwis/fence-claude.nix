{ }:

let
  sources = import ./sources.nix { };
  pkgs = import sources.nixpkgs {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "claude-code"
      ];
  };
  devshell = import sources.devshell { nixpkgs = pkgs; };
  agent-sandbox = import sources.agent-sandbox.outPath {
    inherit pkgs;
  };
  claude-sandboxed = agent-sandbox.mkSandbox {
    pkg = pkgs.claude-code;
    binName = "claude";
    outName = "claude-sandboxed";
    allowedPackages = [
      pkgs.cacert
      pkgs.coreutils
      pkgs.which
      pkgs.bash
      pkgs.git
      pkgs.ripgrep
      pkgs.fd
      pkgs.gnused
      pkgs.gnugrep
      pkgs.findutils
      pkgs.jq
    ];
    stateDirs = [ "$HOME/.claude" ];
    stateFiles = [
      "$HOME/.claude.json"
      "$HOME/.claude.json.lock"
    ];
    extraEnv = {
      NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
    restrictClosure = true;
  };
in

devshell.mkShell {
  packages = [
    claude-sandboxed
  ];
}
