{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.git.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    # Installs delta and sets git's pager + interactive.diffFilter for us.
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true; # use n and N to move between diff sections
        dark = true; # or light = true, or omit for auto-detection
      };
    };

    programs.git = {
      enable = true;

      # Global excludes, written to ~/.config/git/ignore (git's default
      # location, so no core.excludesfile needed). Per-repo concerns like
      # /result belong in each repo's own .gitignore.
      ignores = [
        # macOS
        ".DS_Store"
        "._*"
        # editor droppings
        "*.swp"
        "*.swo"
        "*~"
        # direnv
        ".direnv/"
      ];

      settings = {
        user =
          {
            name = "ivy forever";
            email = meta.email;
          }
          # SSH commit signing via the 1Password app — only installed on
          # aspen (macOS); the Linux hosts (elm/houseplants) are headless
          # servers with no 1Password, so gpgsign here would break every
          # commit for them.
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ";
          };
        init.defaultBranch = "main";
        column.ui = "auto";
        color.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";

        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };

        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };

        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };

        help.autocorrect = "prompt";
        commit =
          {verbose = true;}
          // lib.optionalAttrs pkgs.stdenv.isDarwin {gpgsign = true;};

        gpg = lib.optionalAttrs pkgs.stdenv.isDarwin {
          format = "ssh";
          ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };

        rerere = {
          enabled = true;
          autoupdate = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };

        # zealous diff3: 3-way conflict markers with common-ancestor context
        merge.conflictstyle = "zdiff3";

        gc = {
          pruneExpire = "30.days.ago";
          worktreePruneExpire = "now";
        };

        alias = {
          # Maintenance
          prune = "fetch --prune";
          sync = "!git fetch --all --prune --prune-tags && git pull --ff-only"; # safe fast-forward update

          # History / inspection
          lg = "log --graph --decorate --abbrev-commit --date=relative --all --pretty=format:'%C(auto)%h%d%Creset %s %C(blue)%cr%Creset %C(bold green)<%an>%Creset'";
          glog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

          # Undo/cleanup
          undo = "reset --soft HEAD^";
          uncommit = "reset --soft HEAD^"; # alias spelling many people expect
          amend = "commit --amend --no-edit";
          wipe = "!f() { git reset --hard \"$1\" && git clean -fdx; }; f"; # careful: nukes untracked/ignored

          # Stash ('stash save' is deprecated; push with -u includes untracked)
          stash-all = "!git stash push -u -m \"stash: $(date -u +'%Y-%m-%dT%H:%M:%SZ')\"";

          # Fixup/squash helpers
          fixup = "!f() { git commit --fixup=$1; }; f";
          squash = "!f() { git commit --squash=$1; }; f";
          autosquash = "!git rebase -i --autosquash";

          # Show changed files succinctly
          changed = "diff --name-status";
          st = "status -sb";

          # Safer pull
          pullff = "pull --ff-only";
        };
      };
    };

    programs.lazygit = {
      enable = true;
      # mkDefault: home-manager's lazygit module only manages (symlinks)
      # ~/.config/lazygit/config.yml when settings is non-empty. Hosts with
      # noctalia force this back to {} (see noctalia.nix) so that file stays
      # a plain mutable dotfile noctalia's lazygit template can write its
      # theme into — a home-manager-owned symlink would make that write
      # fail (permission denied against the nix store).
      settings = lib.mkDefault {
        os.editPreset = "nvim";

        git.pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];

        # Catppuccin mocha, lavender accent — matches fzf/neovim theming.
        gui = {
          theme = {
            activeBorderColor = ["#b4befe" "bold"];
            inactiveBorderColor = ["#a6adc8"];
            optionsTextColor = ["#89b4fa"];
            selectedLineBgColor = ["#313244"];
            cherryPickedCommitBgColor = ["#45475a"];
            cherryPickedCommitFgColor = ["#b4befe"];
            unstagedChangesColor = ["#f38ba8"];
            defaultFgColor = ["#cdd6f4"];
            searchingActiveBorderColor = ["#f9e2af"];
          };
          authorColors."*" = "#b4befe";
          showRandomTip = false;
        };
      };
    };
  };
}
