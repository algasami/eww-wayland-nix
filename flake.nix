# https://elkowar.github.io/eww/ for building

{
  description = "A wayland wrapper for eww";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils/4022d587cbbfd70fe950c1e2083a02621806a725";
    rust-overlay.url = "github:oxalica/rust-overlay/a0df72e106322b67e9c6e591fe870380bd0da0d5";
    eww_src = {
      url = "github:elkowar/eww/65d622c81f2e753f462d23121fa1939b0a84a3e0";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, eww_src, rust-overlay, flake-utils, ... }:
  let

    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 0 lastModifiedDate;

  in flake-utils.lib.eachDefaultSystem (system:
    let
      name = "eww_wayland_nix";
      fs = pkgs.lib.fileset;
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      packages.default = with pkgs; rustPlatform.buildRustPackage {
        inherit system name version;
        src = eww_src;

        cargoBuildOptions = "--release --no-default-features --features=wayland";
        cargoLock.lockFile = "${eww_src}/Cargo.lock";
        # runtime dependencies
        buildInputs = with pkgs; [
          gtk3
          gtk-layer-shell
          gdk-pixbuf # provides 2.42... i guess???
          pango
          cairo
          glib # provides 2.78... i guess???
          libgcc
          glibc
        ];

        # build-time dependencies
        nativeBuildInputs = with pkgs; [
          rust-bin.nightly.latest.default
          pkg-config
        ];
      };
    }
  );
}
