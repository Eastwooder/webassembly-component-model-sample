# WebAssembly Component Model Sample

## Getting started

You can use `just run <args>` to compile, link, and execute the model with the passed args.

See the project's [justfile](/.justfile) for more details.

If you don't want to setup everything and have nix installed, you can clone this directory and simply run the sample with:

```sh
nix develop
just run 17 add 20
```