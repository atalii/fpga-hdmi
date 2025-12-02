{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    openfpgaloader
    yosys
    just
    python313Packages.apycula
    nextpnr
  ];
}
