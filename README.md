# Mini Compile Commands

Mini compile commands instruments the compiler wrappers in nixpkgs to generate `compile_commands.json` files. Using a version of nixpkgs which has mini compile commands, it can be included in an environment as follows:

```
with (import <nixpkgs> {});
(mkShell.override {stdenv = ( mini-compile-commands.wrap clang13Stdenv );}) {
   buildInputs = [ cmake gtest ];
}
```

When the compiler is invoked, it will send a message to `mini_compile_commands_server.py`:

https://user-images.githubusercontent.com/8081722/192353380-5c417134-1cf5-4f60-97c1-386f24b0d4f7.mp4

