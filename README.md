# Mini Compile Commands

Mini compile commands instruments the compiler wrappers in nixpkgs to generate `compile_commands.json` files. Using a version of nixpkgs which has mini compile commands, it can be includede in an environment as follows:

```
with (import <nixpkgs> {});
let llvm = llvmPackages_latest;
in (mkShell.override {stdenv = ( mini-compile-commands.wrapper llvm.stdenv );}) {
   buildInputs = [ cmake gtest mini-compile-commands.server ];
}
```

now whenever the compiler is invoked, it will try and send a message to send its compile commands to a running `mini_compile_commands_server.py`.
