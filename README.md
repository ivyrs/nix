# nix

Ivy's machine configurations, managed as a single Nix flake.

## Machines

### Servers

| Host        | Platform                                   | Role                                    |
|-------------|---------------------------------------------|------------------------------------------|
| elm         | x86_64-linux (NixOS)                       | Tailnet-only home server: Syncthing, glance, miniflux, pocket-id, vaultwarden, Nextcloud, GoToSocial, Forgejo, multi-scrobbler |
| houseplants | aarch64-linux (NixOS, Hetzner VPS)         | Public edge — Caddy proxies `houseplants.cloud`/`ivy.rs` to elm over Tailscale; only host open to the internet |

### Clients

| Host        | Platform                                   | Role                                    |
|-------------|---------------------------------------------|------------------------------------------|
| aspen       | aarch64-darwin (nix-darwin + home-manager) | Personal macOS machine |
| alder       | aarch64-linux (NixOS/Asahi, niri)          | Dual-boots aspen's physical Mac — same hardware, second OS. Tailnet client only, no services, no public exposure. |

Most services live on `elm`, which is reverse-proxied by a `caddy` instance running on `houseplants`.
This is except for `glance` which uses Tailscale named services to expose glance onto the tailnet as `dash`.
It does this by creating a systemd service to bring up the assignment as tailscale's nix module doesnt allow config files to set HTTPS (for now).

## Layout

This flake is built on [Den](https://github.com/denful/den), an
aspect-oriented Nix framework. It's a formalization of the "dendritic
pattern": [`import-tree`](https://github.com/vic/import-tree) recursively
imports every `.nix` file under `modules/` and `hosts/` (via
[`flake-parts`](https://github.com/hercules-ci/flake-parts)' `flakeModules.modules`),
and each file registers itself under a `den.aspects.<name>` namespace
(a feature that can span multiple Nix classes, get `includes`d by name, and
get delivered to hosts/users) — there's no central registry to update, add a
file and it's picked up. (A handful of files register plain flake-level
outputs instead — `flake.lib`, `flake.formatter`, `flake.packages`,
`flake.homeConfigurations` — for things that aren't per-host aspects at
all; see `modules/meta/`.) Den sits on top of `import-tree` with two more
layers:

- **`den.hosts`** — declares each machine and its users
  (`hosts/<host>/default.nix`, per-host). Den turns these into real
  `darwinConfigurations.*` / `nixosConfigurations.*` outputs automatically.
- [x] **`den.aspects.<name>`** — a feature as a function of context, holding
  configuration for every Nix class it touches at once (`nixos`, `darwin`,
  `homeManager`). `hosts/aspen/`, `hosts/elm/`, `hosts/houseplants/`, and
  `hosts/alder/` each define a host aspect (system config, named to
  match the host so Den auto-applies it) and, via
  `provides.to-users.includes`/`provides.to-users.homeManager`, the
  home-manager config delivered to that host's user.
  `modules/users/ivy.nix` defines the shared `ivy` user aspect — name-matched
  to the `ivy` user declared on every host, so it auto-applies everywhere
  without being listed in any host's `includes`.

Cross-module constants (the `houseplants.cloud` domain, OIDC issuer, SMTP
account, syncthing device IDs) live in `modules/meta/meta.nix` under
`flake.lib.meta` — change them there, not in the consuming service files.

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
for its desktop session. `den.aspects.theme` carries fonts (darwin + nixos
classes) plus Linux GTK/QT theming (nixos-only) in one aspect — aspen
includes it too, but being darwin only ever picks up the fonts half.
Headless elm and houseplants only get the base bundle.

## Usage

From the machine itself:

```
just switch
```

detects the OS and runs `nh darwin switch` (aspen) or `nh os switch` (elm,
houseplants, alder) against `.#$(hostname -s)`.

To deploy from another machine on the tailnet, without SSHing in first:

```
just deploy {{ name }}
```

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
- `sops-nix` is wired into every host via `den.aspects.sops`
  (`modules/aspects/core/sops.nix`, bootstrap only — file location + host
  age key). Individual `sops.secrets.<name>` declarations live next to
  whichever aspect consumes them (e.g. `nextcloud-admin-password` in
  `modules/aspects/services/nextcloud.nix`), not in one central file.
  Every host still needs the bootstrap regardless of which secrets it
  decrypts, since `modules/users/ivy.nix`'s shared `ivy` aspect declares
  `ivy-password-hash` on all of them.
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
decrypts `secrets.yaml` (repo root) at activation using an age key derived
from its own `/etc/ssh/ssh_host_ed25519_key` — no key files to provision or
lose. `.sops.yaml` lists the age recipients (each host, plus a personal key
for editing).

To edit secrets from a workstation:

```
sops secrets.yaml
```

This requires a personal age private key at `~/.config/sops/age/keys.txt`
(path pinned via `SOPS_AGE_KEY_FILE` in
`modules/aspects/core/home-manager.nix`) whose public key is listed in
`.sops.yaml` as `admin_ivy`. That private key lives only on your own
machine(s) — back it up somewhere durable, since losing it (without still
having a host that can decrypt) means re-encrypting from scratch.

New secrets: add the value via `sops`, then declare
`sops.secrets.<name> = { };` directly in the aspect that consumes it (next
to wherever `config.sops.secrets.<name>.path` gets read) rather than in a
central file — see `modules/aspects/services/nextcloud.nix` for an example.
Every host that includes that aspect already has the `den.aspects.sops`
bootstrap (file location + age key) needed to decrypt it.
