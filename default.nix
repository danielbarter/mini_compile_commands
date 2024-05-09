{ stdenv
, python3Minimal
, lib
, makeSetupHook
, coreutils
,
}: rec {
  # function for wrapping a standard environment to include the
  # compile commands generation functionality
  wrap = env:
    let
      # currently, gcc is bundled with the C++ standard library and runtime libraries
      # so it is able to find them automatically. This is a hack to explicitly pass
      # then as command line arguments. Eventually, the plan is that these libraries will
      # be split out: https://github.com/NixOS/nixpkgs/issues/132340. Once that happens,
      # this hack will no longer be needed (and will no longer work)
      gcc-hack = lib.optionalString env.cc.isGNU ''
        libcxxflags=$out/nix-support/libcxx-cxxflags
        libcflags=$out/nix-support/libc-cflags
        echo -isystem ${env.cc.cc}/include/c++/${env.cc.cc.version} >> $libcxxflags
        echo -isystem ${env.cc.cc}/include/c++/${env.cc.cc.version}/${env.hostPlatform.config} >> $libcxxflags
        echo -isystem ${env.cc.cc}/lib/gcc/${env.hostPlatform.config}/${env.cc.cc.version}/include >> $libcflags
      '';
      cc-hook =
        ''
          ln -s ${package}/bin/cc-wrapper-hook $out/nix-support/cc-wrapper-hook
        ''
        + gcc-hack;
    in
    env.override (old: {
      cc = old.cc.overrideAttrs (final: previous: {
        installPhase = previous.installPhase or "" + cc-hook;
      });
      extraBuildInputs = old.extraBuildInputs or [ ] ++ [ package ];
      extraNativeBuildInputs = (old.extraNativeBuildInputs or [ ]) ++ [ hook ];
      allowedRequisites = null;
      preHook =
        old.preHook
        + ''
          if [[ -n $MCC_BUILD_DIR ]]; then
            export MCC_BUILD_DIR=$(eval echo $MCC_BUILD_DIR)
            echo "MCC: using $MCC_BUILD_DIR to build"
            ${coreutils}/bin/mkdir -p $MCC_BUILD_DIR
            export NIX_BUILD_TOP="$MCC_BUILD_DIR"
            cd $NIX_BUILD_TOP
          fi
        '';
    });

  # hook which will generate a compile_commands.json while building a derivation
  hook = makeSetupHook { name = "mini-compile-commands-hook"; }
    ./mini-compile-commands-hook;

  # mini compile commands package. You probably don't want to use this directly.
  # instead, wrap your standard environment: ( mini-compile-commands.wrap stdenv )
  package = stdenv.mkDerivation {
    name = "mini_compile_commands";

    src = lib.sources.sourceFilesBySuffices ./. [ "py" "-hook" ];

    # specifying python environment variable so that it gets substituted
    # during install phase
    python = python3Minimal;

    installPhase = ''
      mkdir -p $out/bin
      export mini_compile_commands_client=$out/bin/mini_compile_commands_client.py
      for file in *.py cc-wrapper-hook; do
        substituteAll $src/$file $out/bin/$file
        chmod +x $out/bin/$file
      done
    '';
  };
}
