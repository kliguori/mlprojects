{
  # With each update re-pin with "nix develop --profile ./.gcroot"
  description = "Machine Learning in Physics dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-small # small base
          luatex
          latexmk
          
          # Broad, but still smaller than scheme-medium 
          collection-latexrecommended # bm, amsmath, mathtools, caption, subcaption, graphics, float, xcolor...
          collection-latexextra # dcolumn, slashed, braket, soul, mathrsfs, etc.
          collection-pictures # pgf/tikz and graphics libraries
          collection-luatex # fontspec and LuaTeX-related bits
          collection-fontsrecommended # cm-super and common fonts
          collection-fontsextra # extra fonts (includes bbm)

          # Not always in collections; add explicitly:
          tikz-feynman
          ;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "mlp";
        packages = with pkgs; [
          # Python packages
          (python312.withPackages (
            ps: with ps; [
              numpy
              scipy
              sympy
              pandas
              scikit-learn
              torch-bin
              torchvision-bin
              jupyterlab
              ipykernel
              matplotlib
              seaborn
              ffmpeg
              tqdm
              nbconvert
            ]
          ))

          # packages for converting notebooks to pdfs with latex
          tex
          pandoc
          ghostscript
        ];
        shellHook = ''
          export NIX_DEV_SHELL_NAME=mlp
          export PATH=$PATH:$PWD/mlinphysics/bin
          export PYTHONPATH=$PWD
          export SHELL=${pkgs.zsh}/bin/zsh
          exec ${pkgs.zsh}/bin/zsh --login
        '';
      };
    };
}
