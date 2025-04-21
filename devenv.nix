{
  pkgs,
  lib,
  config,
  ...
}: let
  # writeShellScript here is identity to cause treesitter to format bash scripts correctly.
  writeShellScript = name: script: script;
  helpScript = writeShellScript "help" ''
    echo
    echo 🦾 Useful project scripts:
    echo 🦾
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue {} (lib.mapAttrs (_: value: value.description) config.scripts)}
    EOF
    echo
  '';

  testScript = writeShellScript "test" ''
    ${pkgs.gotestsum}/bin/gotestsum --  ./... -race -coverprofile=coverage.out -covermode=atomic
  '';
in {
  env = {
    GOFLAGS = "-tags=assert";
    ATRO_NATS_URL = "nats://nats:4222";
  };

  packages = with pkgs; [
    # Docs
    mdbook
    mdbook-mermaid
    mdbook-admonish
    mdbook-linkcheck
    mdbook-toc

    # NATS
    natscli
    nats-top
    nats-server

    # Other
    gomarkdoc # TODO: Start using it
    gotestsum
  ];

  pre-commit.hooks = {
    editorconfig-checker.enable = true;
    gen-doc-refs = {
      enable = true;
      entry = ''gen-doc-refs '';
    };
    gofmt.enable = true;
    govet.enable = true;
    golangci-lint.enable = true;
    mixed-line-endings.enable = true;
    end-of-file-fixer.enable = true;
    check-symlinks.enable = true;
    check-merge-conflicts.enable = true;
    actionlint.enable = true;
    revive.enable = true;
  };

  enterTest = testScript;

  scripts = {
    run-tests = {
      exec = testScript;
      description = "Run tests";
    };
    run-docs = {
      exec = writeShellScript "run-docs" ''
        mkdocs serve
      '';
      description = "Run the documentation server";
    };
    gen-doc-refs = {
      # TODO: Do we need this ?
      # TODO: Can use similar definition for writeShellScript as in atrk
      # to deal with DIR matters.
      exec = writeShellScript "gen-doc-refs" ''
        CURRENT_DIR=$PWD
        cd $CURRENT_DIR/utils && gomarkdoc --output ../docs/Utils.md
        cd $CURRENT_DIR
      '';
      description = "Generate the documentation references";
    };
    help = {
      exec = helpScript;
      description = "Show this help message";
    };
  };
  languages.go = {
    enable = true;
    enableHardeningWorkaround = true;
    package = pkgs.go;
  };

  enterShell = helpScript;
}
