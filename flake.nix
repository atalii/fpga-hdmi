{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
      import ./shell.nix { inherit pkgs; };
  };
}
