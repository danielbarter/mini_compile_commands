{ lib
, stdenv
, fetchFromGitHub
, python3Minimal
}:

rec {
  # function for wrapping a standard environment to include the
  # compile commands generation functionality
  wrap = env:
    let
      hook = "ln -s ${package}/bin/cc-wrapper-hook $out/nix-support/cc-wrapper-hook";
    in
      env.override (old: {
        cc = old.cc.overrideAttrs (final: previous: {
          installPhase = previous.installPhase or "" + hook;
        });
        extraBuildInputs = old.extraBuildInputs or [] ++ [ package ];
        allowedRequisites = null;
      });

  # mini compile commands package. You probably don't want to use this directly.
  # instead, wrap your standard environment: ( mini-compile-commands.wrap stdenv )
  package = stdenv.mkDerivation {
    pname = "mini_compile_commands";

    src = ./.;
    # specifying python environment variable so that it gets substituted
    # during install phase
    python = python3Minimal;

    installPhase = ''
      mkdir -p $out/bin
      export mini_compile_commands_client=$out/bin/mini_compile_commands_client.py
      for file in $(ls $src); do
        substituteAll $src/$file $out/bin/$file
        chmod +x $out/bin/$file
      done
    '';
  };
}
