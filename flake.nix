{
  description = "stehessel's homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              # Nix
              alejandra.enable = true;
              deadnix.enable = true;
              statix.enable = true;

              # YAML
              yamllint = {
                enable = true;
                entry = pkgs.lib.mkForce "${pkgs.yamllint}/bin/yamllint --config-file .github/lint/.yamllint.yaml";
              };

              # Pre-commit
              check-merge-conflict = {
                enable = true;
                name = "check for merge conflicts";
                description = "checks for files that contain merge conflict strings.";
                entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-merge-conflict";
                language = "python";
                types = ["text"];
              };
              detect-private-key = {
                enable = true;
                name = "detect private key";
                description = "detects the presence of private keys.";
                entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/detect-private-key";
                language = "python";
                types = ["text"];
              };
              end-of-file-fixer = {
                enable = true;
                name = "fix end of files";
                description = "ensures that a file is either empty, or ends with one newline.";
                entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
                language = "python";
                types = ["text"];
                stages = ["commit" "push" "manual"];
              };
              trailing-whitespace = {
                enable = true;
                name = "trim trailing whitespace";
                description = "trims trailing whitespace.";
                entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                language = "python";
                types = ["text"];
                stages = ["commit" "push" "manual"];
              };
            };

            settings = {
              statix.ignore = [".direnv"];
            };
          };
        };
        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;

          buildInputs = [
            pkgs.cmctl
            pkgs.fluxcd
            pkgs.go-task
            pkgs.hcloud
            pkgs.httpie
            pkgs.istioctl
            pkgs.kubeconform
            pkgs.kustomize
            pkgs.linkerd
            pkgs.packer
            pkgs.sops
            pkgs.terraform
            pkgs.timoni
            pkgs.trivy
            pkgs.yq-go
          ];
        };
      }
    );
}
