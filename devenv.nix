{
  pkgs,
  lib,
  config,
  ...
}: {
  pre-commit = {
    hooks = {
      check-merge-conflicts.enable = true;
      check-added-large-files.enable = true;
      editorconfig-checker.enable = true;
      govet.enable = true;
      gofmt.enable = true;
    };
  };

  enterTest = ''
    go test ./... -race -coverprofile=coverage.out -covermode=atomic
  '';

  scripts = {
    run-docs = {
      exec = ''
        mkdocs serve
      '';
      description = "Run the documentation server";
    };
  };
  languages.go = {
    enable = true;
    package = pkgs.go;
  };

  enterShell = ''
    echo
    echo 🦾 Useful project scripts:
    echo 🦾
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
    EOF
    echo
  '';
}
