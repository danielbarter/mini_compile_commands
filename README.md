# Mini Compile Commands

Mini compile commands instruments the compiler wrappers in nixpkgs to generate `compile_commands.json` files. Using a version of nixpkgs after [this PR](https://github.com/NixOS/nixpkgs/pull/197937), it can be used in a `shell.nix` as follows:

```
with import <nixpkgs> {};
let mcc-env = (callPackage <this_repo> {}).wrap stdenv;
in (mkShell.override {stdenv = mcc-env;}) {
   buildInputs = [ cmake gtest ];
}
```

When the compiler is invoked, it will send a message to `mini_compile_commands_server.py`:

https://user-images.githubusercontent.com/8081722/192353380-5c417134-1cf5-4f60-97c1-386f24b0d4f7.mp4

## Mini Compile Commands and flakes

If your project is flake based, add `mini-compile-commands = { url = github:danielbarter/mini_compile_commands; flake = false;};` to your inputs and `mini-compile-commands` as an argument to your outputs. Then the above development shell output would be specified as

```
devShell.x86_64-linux =
  with import nixpkgs { system = "x86_64-linux"; };
  let mcc-env = (callPackage mini-compile-commands {}).wrap stdenv;
  in (mkShell.override {stdenv = mcc-env;}) {
    buildInputs = [ cmake gtest ];
  };
```

## Examples

Mini compile commands can be used to generate a `compile_commands.json` for the linux kernel:

```
nix-shell -E 'with import <nixpkgs> {}; let mcc-env = (callPackage <this_repo> {}).wrap stdenv; in linux.override { stdenv = mcc-env; }'
```

As demonstrated in the above video, create two shells. In one, run `mini_compile_commands_server.py compile_commands.json` and in the other, run `genericBuild`.

For certain packages (like those included in `python3Packages`), there is currently no easy way to override the standard environment. To use mini compile commands for these packages, we can override the standard environment for all nixpkgs as follows:

```
nix-build -E 'with import <nixpkgs> { config.replaceStdenv = ({ pkgs }: (pkgs.callPackage <this_repo> {}).wrap pkgs.stdenv);}; python3Packages.pybind11'
```

Warning: This requires a huge amount of rebuilding.

## Testing

There are tests for `gcc` and `clang` in `tests/gcc` and `tests/clang` respectively. In either of these directories, running `nix-shell` will generate a `compile_commands.json`. To test if things are working, open `test.cc` (make sure your editor can locate clangd) and try and jump into the `iostream` header.

## Build input hook

It is possible to use mini compile commands to generate a `compile_commands.json` while building a derivation. This works by building directly in a subdirectory of `$out` or some other `$custom-output` (so that `compile_commands.json` contains valid paths).

Using this involves using a wrapped standard standard environment and setting `MCC_BUILD_DIR`:

```nix
with import <nixpkgs> {}; let
  mcc-env = (callPackage <this_repo> {}).wrap stdenv;
  mcc-hook = (callPackage <this_repo> {}).hook;
in
  (hello.override {stdenv = mcc-env;}).overrideAttrs
  (finalAttrs: previousAttrs: {
    # pick any path
    MCC_BUILD_DIR = "$out/${finalAttrs.pname}-${finalAttrs.version}-src";

    # can also put in another output
    # MCC_BUILD_DIR = "$dev";
    # outputs = ["out" "dev"];
  })
```

Running `nix-build` on this derivation will generate a `compile_commands.json` at `$MCC_BUILD_DIR/compile_commands.json`.
by default all files other than c and header files are removed in `$MCC_BUILD_DIR`. This can be customized by setting `MCC_KEEP_REGEXP`, which is any python regex.
