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

## Example

Mini compile commands can be used to generate a `compile_commands.json` for the linux kernel:

```
nix-shell -E 'with import <nixpkgs> {}; let mcc-env = (callPackage <this_repo> {}).wrap stdenv; in linux.override { stdenv = mcc-env; }'
```

As demonstrated in the above video, create two shells. In one, run `mini_compile_commands_server.py compile_commands.json` and in the other, run your build command.


## Testing

There are tests for `gcc` and `clang` in `tests/gcc` and `tests/clang` respectively. In either of these directories, running `nix-shell` will generate a `compile_commands.json`. To test if things are working, open `test.cc` and try and jump into the `iostream` header.
