{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    latex-utils = {
      # url = "git+file:///Users/jack/Developer/github.com/jmmaloney4/latex-utils";
      url = "github:jmmaloney4/latex-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, latex-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      texPackages = {
          inherit (pkgs.texlive) pgf amscls braket csquotes;
      };
    # in rec {
    #   packages = pkgs.lib.attrsets.mapAttrs (package: path:
    #     pkgs.stdenvNoCC.mkDerivation rec {
    #       name = "hausdorff-measure-" + package;
    #       src=self;
    #       buildInputs = [ pkgs.coreutils tex ];
    #       phases = ["unpackPhase" "buildPhase" "installPhase"];
    #       buildPhase = ''
    #         cd ${package}
    #         export PATH="${pkgs.lib.makeBinPath buildInputs}";
    #         mkdir -p .cache/texmf-var
    #         echo $PWD
    #         ls $PWD
    #         env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
    #           latexmk -f -interaction=nonstopmode -pdf -lualatex \
    #           main.tex
    #       '';
    #       installPhase = ''
    #         mkdir -p $out
    #         cp main.pdf $out/${package}.pdf
    #       '';
    #     }) { paper = ./paper; presentation = ./presentation; };
      # defaultPackage = packages.paper;

    in {
      packages.default = latex-utils.lib.${system}.mkLatexDocument {
        name = "math629-hausdorff-measure";
        src = self;
        inherit texPackages;
        workingDirectory = "paper";
        inputFile = "main.tex";
      };
    });
}
