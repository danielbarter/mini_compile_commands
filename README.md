# Mini Compile Commands

Mini compile commands instruments the compiler wrappers in nixpkgs to generate `compile_commands.json` files. Using a version of nixpkgs after [this PR](https://github.com/NixOS/nixpkgs/pull/197937), it can be included in a `shell.nix` as follows:

```
with (import <nixpkgs> {});
let mini-compile-commands = callPackage <this_repo> {};
in (mkShell.override {stdenv = ( mini-compile-commands.wrap stdenv );}) {
   buildInputs = [ cmake gtest ];
}
```

When the compiler is invoked, it will send a message to `mini_compile_commands_server.py`:

https://user-images.githubusercontent.com/8081722/192353380-5c417134-1cf5-4f60-97c1-386f24b0d4f7.mp4

## Example

Mini compile commands can be used to generate a `compile_commands.json` for the linux kernel:

```
nix-shell -E "with (import <nixpkgs> {}); let mini-compile-commands = callPackage <this_repo> {}; in linux.override { stdenv = (mini-compile-commands.wrap stdenv); }"
```

As demonstrated in the above video, create two shells. In one, run `mini_compile_commands_server.py compile_commands.json` and in the other, run your build command.
