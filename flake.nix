{
  # With each update re-pin with "nix develop --profile ./.gcroot"
  description = "Machine Learning in Physics dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "mlp";
        packages = with pkgs; [
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
              matplotlib
              seaborn
              ffmpeg
              tqdm
            ]
          ))
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
