with import ( builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz";
  }) {};
let mcc-env = (callPackage ../.. {}).wrap stdenv;
in (hello.override { stdenv = mcc-env; }).overrideAttrs
  (finalAttrs: previousAttrs: {
    preBuildPhases = [
      "startMiniCompileCommandsServer"
    ];

    startMiniCompileCommandsServer = ''
    mini_compile_commands_server.py &
    MINI_COMPILE_COMMANDS_PID=$!
    sleep 1
    '';

    postPhases = [
      "stopMiniCompileCommandsServer"
    ];


    stopMiniCompileCommandsServer = ''
    kill -s SIGINT $MINI_COMPILE_COMMANDS_PID
    wait $MINI_COMPILE_COMMANDS_PID
    mv compile_commands.json $out
    '';

  })
