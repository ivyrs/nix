# nix

Ivy's machine configurations, managed as a single Nix flake.

## Machines

| Host        | Platform                                   | Role                                    |
|-------------|---------------------------------------------|------------------------------------------|
| aspen       | aarch64-darwin (nix-darwin + home-manager) | Personal macOS machine |
| elm         | x86_64-linux (NixOS)                       | Home server behind the tailnet: Syncthing, glance, miniflux, pocket-id, vaultwarden, Nextcloud, GoToSocial, Forgejo, multi-scrobbler (vikunja currently disabled) |
| houseplants | aarch64-linux (NixOS, Hetzner VPS)         | Public edge: Caddy reverse-proxies each `houseplants.cloud`/`ivy.rs` hostname to the matching service on elm over Tailscale; the only host with ports open to the raw internet |
| alder       | aarch64-linux (NixOS/Asahi, niri)          | Dual-boots aspen's physical Mac — same hardware, second OS. Tailnet client only, no services, no public exposure. |

elm's services sit on bare ports behind the tailnet, except glance — exposed
as a TLS-terminated Tailscale Service (`dash.<tailnet>.ts.net` via `tailscale
serve`, see `modules/aspects/glance/default.nix`). houseplants is the only
host in this flake that terminates real internet traffic
(`networking.firewall.allowedTCPPorts = [80 443]`), proxying to
`elm.<tailnet>:<port>` where needed (`modules/aspects/caddy.nix`); every
other host only opens ports on `tailscale0`.

## Layout

This flake is built on [Den](https://github.com/denful/den), an
aspect-oriented Nix framework. It's a formalization of the "dendritic
pattern": [`import-tree`](https://github.com/vic/import-tree) recursively
imports every `.nix` file under `modules/` and `hosts/` (via
[`flake-parts`](https://github.com/hercules-ci/flake-parts)' `flakeModules.modules`),
and each file registers itself either under a `flake.modules.<class>.<name>`
namespace (plain reusable modules) or a `den.aspects.<name>` namespace
(features that can span multiple Nix classes, get `includes`d by name, and
get delivered to hosts/users) — there's no central registry to update, add a
file and it's picked up. Den sits on top of `import-tree` with two more
layers:

- **`den.hosts`** — declares each machine and its users
  (`hosts/<host>/default.nix`, per-host). Den turns these into real
  `darwinConfigurations.*` / `nixosConfigurations.*` outputs automatically.
- **`den.aspects.<name>`** — a feature as a function of context, holding
  configuration for every Nix class it touches at once (`nixos`, `darwin`,
  `homeManager`). `hosts/aspen/`, `hosts/elm/`, `hosts/houseplants/`, and
  `hosts/alder/` each define a host aspect (system config, named to
  match the host so Den auto-applies it) and, via
  `provides.to-users.includes`/`provides.to-users.homeManager`, the
  home-manager config delivered to that host's user.
  `modules/users/ivy.nix` defines the shared `ivy` user aspect — name-matched
  to the `ivy` user declared on every host, so it auto-applies everywhere
  without being listed in any host's `includes`.

```
flake.nix                  # inputs + import-tree/flake-parts wiring
.sops.yaml                  # sops-nix creation rules + age recipients
secrets/
  secrets.yaml              # encrypted secrets, safe to commit
packages/
  glance-agent/              # custom package, exposed via modules/meta/packages.nix
  nokkvi/                    # Navidrome client (Rust/Iced), same custom-package pattern as glance-agent
modules/
  meta/
    meta.nix                 # flake.lib.meta — shared constants (domain, tailnet, OIDC, SMTP, syncthing IDs)
    formatter.nix             # flake.formatter — alejandra, one per system
    packages.nix              # flake.packages.<system>.* — custom packages from packages/
    home-configurations.nix   # standalone homeConfigurations.* for unmanaged machines
  hosts/
    declarations.nix          # den.default state versions + den.schema.user.classes (cross-host only)
  users/
    ivy.nix                   # den.aspects.ivy — shared user wiring + the NixOS account (SSH key, password, shell)
  sops.nix                    # flake.modules.nixos.sops / flake.modules.darwin.sops
  aspects/                    # grouped into subdirectories by feature domain (core/desktop/dev/services/shell) —
                               # purely for human navigation; import-tree picks up any .nix file regardless of
                               # directory depth, so the grouping has no effect on the den.aspects.<name> namespace
    core/
      core.nix                 # den.aspects.core.homeManager — base env vars (EDITOR, SOPS_AGE_KEY_FILE), session path
      home-manager.nix          # den.aspects.home-manager — bundles core/cli-tools/shell/git/neovim/tmux, included by every host
      i18n.nix                  # den.aspects.i18n.nixos — timezone/locale/keymap
      nix-settings.nix          # den.aspects.nix-settings — Lix pin, GC/optimise, unfree, noctalia cachix substituter
      tailscale.nix             # den.aspects.tailscale-{client,server}.nixos
    desktop/
      fonts.nix                 # den.aspects.fonts — ibm-plex + aporetic, darwin & nixos
      ghostty.nix               # den.aspects.ghostty.homeManager (GUI-only, aspen + alder)
      noctalia.nix              # den.aspects.noctalia.homeManager — alder's desktop shell; also force-swaps the
                                 # ghostty/lazygit theme wiring described below
      noctalia-settings.toml    # seed settings merged as a background default under the live settings.toml, never fights hand-tuning
      onepassword.nix           # den.aspects.onepassword — 1Password GUI/CLI + SSH agent
      theme.nix                 # den.aspects.theme — GTK/QT theming (adw-gtk3, qt6ct), includes den.aspects.fonts; linux desktop only
      default.nix               # den.aspects.desktop.homeManager (workstation-only CLI, aspen + alder) and
                                 # den.aspects.desktop.nixos (Linux GUI apps — feishin, vesktop, obsidian, etc; alder only)
      aerc/                     # TUI mail client; contributes more packages into den.aspects.desktop.homeManager
        default.nix, aerc-catppuccin-mocha.conf
      mac/
        aerospace.nix, homebrew.nix, system-defaults.nix, touchid.nix   # darwin-only, aspen
      niri/
        default.nix             # den.aspects.niri — alder's desktop (niri + noctalia-greeter)
        config.kdl               # top-level: `include`s the three files below, plus window-rules
        binds.kdl, settings.kdl, ux.kdl  # keybinds / input+output+hotkey-overlay / layout+layer-rules
    dev/
      cli-tools.nix             # den.aspects.cli-tools.homeManager — base CLI toolbelt (ripgrep, fd, jq, nh, ...)
      dev-tools.nix             # den.aspects.dev-tools.homeManager — devenv + language runtimes (aspen + alder)
      git.nix, neovim.nix
      tmux/
        default.nix, tmux.conf
    services/
      caddy/
        caddy.nix               # den.aspects.caddy.nixos — the houseplants edge proxy, one virtualHost per public hostname
        houseplants-index.html
      forgejo.nix, miniflux.nix, nextcloud.nix, pocket-id.nix, syncthing.nix, vaultwarden.nix
      multi-scrobbler.nix      # den.aspects.multi-scrobbler.nixos — scrobbler, run as an upstream Docker image (oci-containers)
      vikunja.nix              # currently disabled (not in any host's includes)
      glance/                  # den.aspects.glance.nixos, split into widget files
        default.nix            # registration + page assembly; also exposes glance via `tailscale serve` (see below)
        glance-agent.nix       # den.aspects.glance-agent.nixos — companion binary reporting stats back to elm's dashboard
        _*.nix                 # plain widget functions (underscore = skipped by import-tree)
        assets/                # logo + custom css served by glance
      gotosocial/
        default.nix, theme.css
    shell/                     # den.aspects.shell — zsh + starship prompt + fzf/zoxide/direnv integrations
      default.nix, fetch.nix, integrations.nix, starship.nix, zsh.nix
hosts/
  aspen/
    default.nix              # den.hosts.aarch64-darwin.aspen + den.aspects.aspen.darwin (host-specific darwin config)
    home.nix                 # den.aspects.aspen.provides.to-users (home-manager, via includes)
  elm/
    default.nix              # den.hosts.x86_64-linux.elm + den.aspects.elm.nixos (host-specific NixOS config)
    home.nix                 # den.aspects.elm.provides.to-users.includes
    _hardware-configuration.nix  # generated by nixos-generate-config, do not edit
  houseplants/
    default.nix              # den.hosts.aarch64-linux.houseplants + den.aspects.houseplants.nixos (public edge: caddy + tailscale-server)
    home.nix                 # den.aspects.houseplants.provides.to-users.includes
    _hardware-configuration.nix, _disko.nix  # generated (nixos-anywhere), do not edit
  alder/
    default.nix              # den.hosts.aarch64-linux.alder + den.aspects.alder.nixos (NixOS/Asahi, tailscale-client + niri, dual-boots aspen's hardware)
    home.nix                 # den.aspects.alder.provides.to-users.includes (mirrors aspen: home-manager, ghostty, desktop,
                              # dev-tools, syncthing-client, onepassword, plus niri/noctalia/theme for its desktop session)
    _hardware-configuration.nix  # generated by nixos-generate-config, do not edit
```

Cross-module constants (the `houseplants.cloud` domain, OIDC issuer, SMTP
account, syncthing device IDs) live in `modules/meta/meta.nix` under
`flake.lib.meta` — change them there, not in the consuming service files.

`modules/sops.nix` is the one holdout still using the plain
`flake.modules.<class>.<name>` form (pulled into a host's aspect via
`config.flake.modules.<class>.<name>` in its `imports`); everything else has
been converted to `den.aspects.<name>`.

### Batteries

`modules/users/ivy.nix` puts two of Den's built-in `den.batteries.*` on the
shared `ivy` user aspect — `define-user` (sets `users.users.ivy` and
home-manager's `home.username`/`home.homeDirectory`) and `primary-user`
(`wheel`/`networkmanager` groups on NixOS, `system.primaryUser` on Darwin) —
plus a NixOS-only `den.aspects.ivy.nixos` block (shell, declarative password,
the aspen SSH pubkey) that Den auto-applies to every host with an `ivy` user.

Each host's `default.nix` also includes `den.batteries.hostname`
(`networking.hostName`) and the shared `den.aspects.nix-settings` aspect.
On the home-manager side, aspen's and alder's `home.nix` both add
`den.aspects.ghostty`, `den.aspects.desktop`, `den.aspects.dev-tools`,
and `den.aspects.syncthing-client` on top of the `den.aspects.home-manager`
base bundle; alder additionally layers `den.aspects.niri`,
`den.aspects.noctalia`, `den.aspects.onepassword`, and `den.aspects.theme`
for its desktop session (`den.aspects.theme` itself pulls in
`den.aspects.fonts` via `includes` — aspen gets fonts directly instead,
since aspen has no `theme` aspect to include it for). Headless elm and
houseplants only get the base bundle.

## Usage

From the machine itself:

```
just switch
```

detects the OS and runs `nh darwin switch` (aspen) or `nh os switch` (elm,
houseplants, alder) against `.#$(hostname -s)`.

To deploy to elm, houseplants, or alder from another machine on
the tailnet, without SSHing in first:

```
just deploy elm          # or: just deploy houseplants / just deploy alder
```

(alder is only reachable this way while actually booted into NixOS — it's
the same physical hardware as aspen, dual-booted, never running both at once,
so this can't be run *from* aspen against alder or vice versa.)

builds and activates over SSH via the host's Tailscale name
(`ivy@<host>.ocelot-perch.ts.net`). Both remote hosts have
`security.sudo.wheelNeedsPassword = false`, and the recipe passes `nh`
`-e passwordless` (elevation strategy), so it activates unattended even from
a non-interactive shell with no TTY — `nh`'s default elevation strategies
try to read a sudo password interactively and fail in that case, which
`passwordless` avoids entirely.

Other recipes: `just check` (`nix flake check`), `just fmt` (`nix fmt`,
alejandra), `just update` (`nix flake update`).

### On an unmanaged machine

`modules/meta/home-configurations.nix` exports standalone
`homeConfigurations."ivy@<system>"` outputs (the `den.aspects.home-manager`
bundle, rendered via Den's own `den.lib.aspects.resolve` helper, no OS
config) for putting this home environment on machines the flake doesn't
manage. With nix installed there:

```
nix run home-manager -- switch --flake github:ivyturner/nix#ivy@x86_64-linux
```

The local account name must match the entry's username (`ivy`); for a
different account, add a one-line entry in `home-configurations.nix`.

## Inputs of note

- `nixpkgs` (unstable) backs every host, including elm — elm used to pin to
  a separate `nixpkgs-stable` input (26.05) to match its NixOS release, but
  that's been dropped in favor of unstable everywhere, and the input has
  since been removed from `flake.nix` entirely (no longer even present
  commented out).
- `noctalia` / `noctalia-greeter` provide alder's desktop shell
  (`den.aspects.noctalia`) and its login greeter
  (`den.aspects.niri`'s `programs.noctalia-greeter`); `nix-settings.nix`
  adds `noctalia.cachix.org` as an extra substituter on every NixOS host so
  these don't need a local build.
- `sops-nix` is wired into every host (including houseplants, despite
  having no secrets of its own — every NixOS host needs it regardless,
  since `modules/users/ivy.nix`'s shared `ivy` aspect decrypts
  `ivy-password-hash` on all of them).
- `disko` declares houseplants' disk layout (`hosts/houseplants/_disko.nix`),
  used for its original `nixos-anywhere` install; not used on aspen/elm/alder.
- `nix-homebrew` manages Homebrew casks/brews declaratively on aspen.
- `nixos-apple-silicon` (`github:nix-community/nixos-apple-silicon`)
  provides `hardware.asahi.enable` and the Asahi hardware support alder
  needs; also why aspen has `nix.linux-builder.enable = true` (needed to
  build aarch64-linux artifacts like the Asahi installer from aarch64-darwin).
- `den` (`github:denful/den`) provides the `den.hosts`/`den.aspects`/
  `den.batteries` framework described above.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix). Each machine
decrypts `secrets/secrets.yaml` at activation using an age key derived from
its own `/etc/ssh/ssh_host_ed25519_key` — no key files to provision or lose.
`.sops.yaml` lists the age recipients (each host, plus a personal key for
editing).

To edit secrets from a workstation:

```
sops secrets/secrets.yaml
```

This requires a personal age private key at `~/.config/sops/age/keys.txt`
(path pinned via `SOPS_AGE_KEY_FILE` in `modules/aspects/core.nix`)
whose public key is listed in `.sops.yaml` as `admin_ivy`. That private key
lives only on your own machine(s) — back it up somewhere durable, since
losing it (without still having a host that can decrypt) means
re-encrypting from scratch.

New secrets: add the value via `sops`, then declare it in `modules/sops.nix`
(`sops.secrets.<name> = { };`) and reference it at
`config.sops.secrets.<name>.path` wherever it's consumed.
