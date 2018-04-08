{ system ? builtins.currentSystem, ... }@args:
# see: https://www.reddit.com/r/NixOS/comments/4btjnf/fully_setting_up_a_custom_private_nix_repository/?st=jfqxd3k1&sh=92cbc8b5
let
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  packageSources = ({dir, name, pattern ? "*", buildPhase ? ""}:
    { ... }:
    pkgs.stdenv.mkDerivation {
      version = "1.0";
      inherit name;

      src = dir;
      inherit buildPhase;
      installPhase = ''
        mkdir -p $out/${name}
        cp -r ${pattern} $out/${name}
      '';

      meta = with pkgs.stdenv.lib; {
        description = "package for " + name;
        homepage = "https://github.com/maxhbr/myconfig";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = [ ];
      };
    });

  self = rec {
    background = callPackage ./background { inherit pkgs; stdenv = pkgs.stdenv; };
    slim-theme = callPackage ./background/slim-theme { inherit pkgs background; stdenv = pkgs.stdenv; };
    nixSrc = pkgs.callPackage (packageSources {
      dir = ./nix;
      name = "nix";
      buildPhase = ''
        sed -i -e '/myconfig-background =/ s%= .*%= "${background}";%' nixpkgs-config.nix
        sed -i -e '/myconfig-slim-theme =/ s%= .*%= "${slim-theme}";%' nixpkgs-config.nix
      '';
    }) {};
    nixosSrc = pkgs.callPackage (packageSources {
      dir = ./nixos;
      name = "nixos";
      buildPhase = ''
        sed -i -e '/nixpkgs\.config =/ s%= .*%= import ${nixSrc}/nix/nixpkgs-config.nix;%' core/default.nix
      '';
    }) {};
    dotfiles = pkgs.callPackage (packageSources { dir = ./dotfiles; name = "dotfiles"; }) {};
    scripts =  pkgs.callPackage (packageSources { dir = ./scripts; name = "scripts"; pattern = "*.{sh,pl}"; }) {};
    myconfig = pkgs.buildEnv {
      name = "myconfig";
      paths = [
        nixosSrc
        nixSrc
        dotfiles
        scripts
        background
        slim-theme
      ];
    };
  };
in self
