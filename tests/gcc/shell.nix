with import ( builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz";
  }) {};
let mcc-env = (callPackage ../.. {}).wrap stdenv;
in (mkShell.override {stdenv = mcc-env;}) {
  buildInputs = [ clang ]; # bring clangd into env
  shellHook = ''
    mini_compile_commands_server.py &
    sleep 1 # give the server some time to start up
    $CXX test.cc -o /dev/null
    kill -s SIGINT $!
  '';
}
