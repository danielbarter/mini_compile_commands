with import ( builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz";
  }) {};
let mcc-env = (callPackage ../.. {}).wrap stdenv;
    mcc-hook = (callPackage ../.. {}).hook;
in (hello.override { stdenv = mcc-env; }).overrideAttrs
  (finalAttrs: previousAttrs: {
    buildInputs = (previousAttrs.buildInputs or []) ++ [ mcc-hook ];
  })
