{
  description = "A tool for generating compile_commands.json files with nix";
  outputs = { self }: {
    generator = import ./generator.nix;
  };
}