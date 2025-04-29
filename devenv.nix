{
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (inputs.atrolib.lib) listScripts goTest writeShellScript;
  inherit (inputs.atrolib.lib.devenv.scripts) help; # runDocs buildDocs;
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

  git-hooks.hooks = {
    inherit (inputs.atrolib.lib.devenv.git-hooks.hooks) gitleaks markdownlint;
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

  enterTest = goTest;

  scripts = {
    run-tests = {
      exec = goTest;
      description = "Run tests";
    };
    help = help config.scripts;
    # INFO: No docs yet.
    # run-docs = runDocs ".";
    # build-docs = buildDocs ".";

    gen-doc-refs = {
      # TODO: Do we need this ?
      exec = writeShellScript "gen-doc-refs" ''
        cd utils
        gomarkdoc --output ../docs/Utils.md
      '';
      description = "Generate the documentation references";
    };
  };
  languages.go = {
    enable = true;
    enableHardeningWorkaround = true;
    package = pkgs.go;
  };

  enterShell = listScripts config.scripts;
}
