{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # The version of wasm-bindgen-cli needs to match the version in Cargo.lock
    # Update this to include the version you need
    nixpkgs-for-wasm-bindgen.url = "github:NixOS/nixpkgs/4e6868b1aa3766ab1de169922bb3826143941973";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane, nixpkgs-for-wasm-bindgen, flake-compat }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
            # config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            #   # "vscode-with-extensions-1.86.0"
            #   "vscode-extension-ms-vscode-remote-remote-containers-0.305.0"
            # ];
            config.allowUnfree = true;
          };

          # import and bind toolchain to the provided `rust-toolchain.toml` in the root directory
          rustToolchain = (pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
            # Set the build targets supported by the toolchain, wasm32-unknown-unknown is required for trunk.
            extensions = [
              "rust-src" # needed by rust-analyzer vscode extension when installed through internet
              "rust-analyzer"
            ];
            targets = [ 
              "wasm32-unknown-unknown"
              "wasm32-wasi"
            ];
          };
          craneLib = ((crane.mkLib pkgs).overrideToolchain rustToolchain).overrideScope' (_final: _prev: {
            # The version of wasm-bindgen-cli needs to match the version in Cargo.lock. You
            # can unpin this if your nixpkgs commit contains the appropriate wasm-bindgen-cli version
            inherit (import nixpkgs-for-wasm-bindgen { inherit system; }) wasm-bindgen-cli;
          });

          # declare the build inputs used to build the projects
          nativeBuildInputs = with pkgs; [
            # install the toolchain itself
            rustToolchain
            # taskrunner for .justfile
            just
            # tools for webassembly usage
            cargo-component
            wasm-tools
          ] ++ macosBuildInputs;
          # declare the build inputs used to link and run the projects, will be included in the final artifact container
          buildInputs = with pkgs; [ openssl sqlite ];
          macosBuildInputs = with pkgs.darwin.apple_sdk.frameworks;
            [ ]
            ++ (nixpkgs.lib.optionals (nixpkgs.lib.hasSuffix "-darwin" system) [
              Security
              CoreFoundation
            ]);

          # declare build arguments
          commonArgs = {
            # inherit src buildInputs nativeBuildInputs;
            inherit buildInputs nativeBuildInputs;
          };
        in
        with pkgs;
        {
          # formatter for the flake.nix
          formatter = nixpkgs-fmt;

          # executes all checks
          checks = { };

          # packages to build and provide
          packages = {
            default = about;
            about = pkgs.writeScriptBin "about" ''
              #!/bin/sh
              echo "Welcome to our bot!"
            '';
          };

          # development environment provided with all bells and whistles included
          devShells.default = craneLib.devShell {
            # inherit (self.checks.${system}.pre-commit-check) shellHook;
            inputsFrom = [ ];
            # used by codium - pins the rust-analyzer version to this project's rust version
            RUST_ANALYZER_SERVER_PATH = "${rustToolchain}/bin/rust-analyzer";
            packages = with pkgs; [
              (vscode-with-extensions.override {
                vscode = vscodium;
                vscodeExtensions = with vscode-extensions; [
                  # direnv/nix related
                  mkhl.direnv
                  jnoortheen.nix-ide
                  arrterian.nix-env-selector

                  # rust related plugins
                  rust-lang.rust-analyzer
                  serayuzgur.crates
                  # dustypomerleau.rust-syntax

                  # unfree, but helpful stuff
                  ms-vscode-remote.remote-containers
                  ms-azuretools.vscode-docker
                ] ++ vscode-utils.extensionsFromVscodeMarketplace [
                  # {
                  #   name = "vscode-lldb";
                  #   publisher = "vadimcn";
                  #   version = "1.10.0";
                  #   sha256 = "sha256-RAKv7ESw0HG/avBOPE1CTr0THsB7UWx0haJVd/Dm9Gg=";
                  # }
                  {
                    name = "intellij-idea-keybindings";
                    publisher = "k--kato";
                    version = "1.5.13";
                    sha256 = "sha256-IewHupCMUIgtMLcMV86O0Q1n/0iUgknHMR8m8fci5OU=";
                  }
                ];
              })
            ];
          };
        });
}
