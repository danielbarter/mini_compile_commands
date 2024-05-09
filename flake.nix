{
  description = ''
    Mini compile commands instruments the compiler wrappers in nixpkgs to generate `compile_commands.json` files
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "flake-utils";
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mcc = pkgs.callPackage ./default.nix { };
      in
      rec {
        packages.mcc-env = mcc.wrap pkgs.stdenv;
        formatter = pkgs.nixpkgs-fmt;

        # produces a compile_commands.json and .c/.h sources under $out
        packages.example-hello1 =
          (pkgs.hello.override (prev: {
            stdenv = packages.mcc-env;
          })).overrideAttrs (final: prev: {
            MCC_BUILD_DIR = "$out/${final.pname}-${final.version}-src";
          });

        # produces a compile_commands.json and .c/.h sources under another output
        # note that some packages references its build dir, leading to dependency cycles
        packages.example-hello2 =
          (pkgs.hello.override (prev: {
            stdenv = packages.mcc-env;
          })).overrideAttrs {
            MCC_BUILD_DIR = "$dev";
            outputs = [ "out" "dev" ];
          };

        # custom python regex
        packages.example-hello3 =
          (pkgs.hello.override (prev: {
            stdenv = packages.mcc-env;
          })).overrideAttrs {
            MCC_BUILD_DIR = "$dev";
            # newlines are ignored
            MCC_KEEP_REGEXP = ''
              README|
              \.h$|
              \.c$
            '';
            outputs = [ "out" "dev" ];
          };
      }
    );
}
