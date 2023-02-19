{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small latex-bin latexmk braket biblatex biber csquotes rsfs;
      };
    in rec {
      packages = pkgs.lib.attrsets.mapAttrs (package: path:
        pkgs.stdenvNoCC.mkDerivation rec {
          name = "hausdorff-measure-" + package;
          src=self;
          buildInputs = [ pkgs.coreutils tex ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            cd ${package}
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            echo $PWD
            ls $PWD
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -f -interaction=nonstopmode -pdf -lualatex \
              main.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/${package}.pdf
          '';
        }) { paper = ./paper; presentation = ./presentation; };
      defaultPackage = packages.paper;
    });
}