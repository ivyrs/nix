# nix

Ivy's machine configurations, managed as a single Nix flake.

## Machines

| Host        | Platform                                   | Role                                    |
|-------------|---------------------------------------------|------------------------------------------|
| aspen       | aarch64-darwin (nix-darwin + home-manager) | Personal macOS machine |
| elm         | x86_64-linux (NixOS, nixpkgs-stable)       | Home server behind the tailnet: Syncthing, glance, miniflux, pocket-id, vaultwarden, Nextcloud, GoToSocial, Forgejo (vikunja currently disabled) |
| houseplants | aarch64-linux (NixOS, Hetzner VPS)         | Public edge: Caddy reverse-proxies each `houseplants.cloud`/`ivy.rs` hostname to the matching service on elm over Tailscale; the only host with ports open to the raw internet |

elm's services sit on bare ports behind the tailnet; houseplants is the only
thing that terminates real internet traffic (`networking.firewall.allowedTCPPorts
= [80 443]` in `hosts/houseplants/default.nix`) and proxies in over
`elm.<tailnet>:<port>` (see `modules/services/caddy.nix`). Every other host
only opens ports on `tailscale0`.

## Layout

This flake is built on [Den](https://github.com/denful/den), an
aspect-oriented Nix framework. It's a formalization of the "dendritic
pattern": [`import-tree`](https://github.com/vic/import-tree) recursively
imports every `.nix` file under `modules/` and `hosts/` (via
[`flake-parts`](https://github.com/hercules-ci/flake-parts)' `flakeModules.modules`),
and each file registers itself under a `flake.modules.<class>.<name>`
namespace — there's no central registry to update, add a file and it's
picked up. Den sits on top of that with two more layers:

- **`den.hosts`** — declares each machine and its users
  (`modules/den.nix`). Den turns these into real `darwinConfigurations.*` /
  `nixosConfigurations.*` outputs automatically.
- **`den.aspects.<name>`** — a feature as a function of context, holding
  configuration for every Nix class it touches at once (`nixos`, `darwin`,
  `homeManager`). `hosts/aspen/`, `hosts/elm/`, and `hosts/houseplants/` each
  define a host aspect (system config) and, via `provides.to-users.homeManager`,
  the home-manager config delivered to that host's user. `modules/den.nix`
  defines the shared `ivy` user aspect (just OS user/primary-user wiring,
  via `den.batteries.*` — see below).

```
flake.nix                  # inputs + import-tree/flake-parts wiring
.sops.yaml                  # sops-nix creation rules + age recipients
secrets/
  secrets.yaml              # encrypted secrets, safe to commit
modules/
  den.nix                   # den.hosts + den.default + shared `ivy` user aspect
  home-configurations.nix   # standalone homeConfigurations.* for unmanaged machines
  meta.nix                  # flake.lib.meta — shared constants (domain, tailnet, OIDC, SMTP, syncthing IDs)
  formatter.nix             # flake.formatter — alejandra, one per system
  nix-settings.nix          # den.aspects.nix-settings (nix daemon settings, both classes)
  i18n.nix                  # flake.modules.nixos.i18n
  sops.nix                  # flake.modules.nixos.sops / flake.modules.darwin.sops
  darwin/                   # flake.modules.darwin.*, one file per concern
    aerospace.nix, homebrew.nix, system-defaults.nix, fonts.nix, touchid.nix
  services/                 # one file per service, regardless of class
    tailscale.nix           # flake.modules.nixos.tailscale-{client,server}
    caddy.nix                # flake.modules.nixos.caddy — the houseplants edge proxy, one virtualHost per public hostname
    lovecomputer-caddy.nix   # flake.modules.nixos.lovecomputer-caddy — lovecomputer's edge proxy, same shape as caddy.nix
    miniflux.nix, pocket-id.nix, vikunja.nix, vaultwarden.nix
    nextcloud.nix, gotosocial.nix, forgejo.nix
    syncthing.nix            # flake.modules.nixos.syncthing / flake.modules.homeManager.syncthing
    glance/                 # flake.modules.nixos.glance, split into widget files
      default.nix            # registration + page assembly
      _*.nix                 # plain widget functions (underscore = skipped by import-tree)
      assets/                # logo + custom css served by glance
  home/                     # flake.modules.homeManager.base, split by concern
    core.nix, packages.nix, git.nix, neovim.nix, ...
    shell.nix                # zsh + starship prompt + fzf/zoxide/direnv integrations
    ghostty.nix              # den.aspects.gui.homeManager (GUI-only, aspen)
    workstation.nix          # den.aspects.workstation.homeManager (workstation-only CLI, aspen)
hosts/
  aspen/
    default.nix              # den.aspects.aspen.darwin (host-specific darwin config)
    home.nix                 # den.aspects.aspen.provides.to-users.homeManager
  elm/
    default.nix              # den.aspects.elm.nixos (host-specific NixOS config)
    home.nix                 # den.aspects.elm.provides.to-users.homeManager
    _hardware-configuration.nix  # generated by nixos-generate-config, do not edit
  houseplants/
    default.nix              # den.aspects.houseplants.nixos (public edge: caddy + tailscale-server)
    home.nix                 # den.aspects.houseplants.provides.to-users.homeManager
    _hardware-configuration.nix, _disko.nix  # generated (nixos-anywhere), do not edit
  lovecomputer/
    default.nix              # den.aspects.lovecomputer.nixos (public edge: static sites via lovecomputer-caddy + tailscale-server)
    home.nix                 # den.aspects.lovecomputer.provides.to-users.homeManager
    _hardware-configuration.nix, _disko.nix  # generated (nixos-anywhere), do not edit
```

Cross-module constants (the `houseplants.cloud` domain, OIDC issuer, SMTP
account, syncthing device IDs) live in `modules/meta.nix` under
`flake.lib.meta` — change them there, not in the consuming service files.

Reusable feature modules under `modules/` are unchanged from before Den —
still named-registered under `flake.modules.<class>.<name>` and pulled into
a host's aspect via `config.flake.modules.<class>.<name>` in its `imports`.
Den only replaced the layer that used to hand-assemble
`flake.darwinConfigurations`/`flake.nixosConfigurations`
(previously `modules/configurations.nix`, now generated by Den from
`den.hosts` + `den.aspects`).

### Batteries

`modules/den.nix` uses two of Den's built-in `den.batteries.*` on the shared
`ivy` user aspect:

- `den.batteries.define-user` — sets `users.users.ivy` (name/home) and
  home-manager's `home.username`/`home.homeDirectory`, on both platforms.
- `den.batteries.primary-user` — `wheel`/`networkmanager` groups on NixOS,
  `system.primaryUser` on Darwin.

Each host's `default.nix` also includes `den.batteries.hostname`, which sets
`networking.hostName`, and the shared `den.aspects.nix-settings` aspect
(`modules/nix-settings.nix`). On the home-manager side, aspen's `home.nix`
opts into `den.aspects.gui` (ghostty, discord) and `den.aspects.workstation`
(claude-code, gh, sops tooling); headless elm, houseplants, and lovecomputer
all get `homeManager.base` only.

## Usage

From the machine itself:

```
just switch
```

detects the OS and runs `nh darwin switch` (aspen) or `nh os switch` (elm,
houseplants, lovecomputer) against `.#$(hostname -s)`.

To deploy to elm, houseplants, or lovecomputer from aspen (or any machine on
the tailnet), without SSHing in first:

```
just deploy elm          # or: just deploy houseplants / just deploy lovecomputer
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

`modules/home-configurations.nix` exports standalone
`homeConfigurations."ivy@<system>"` outputs (the `homeManager.base` bundle,
no OS config) for putting this home environment on machines the flake
doesn't manage. With nix installed there:

```
nix run home-manager -- switch --flake github:ivyturner/nix#ivy@x86_64-linux
```

The local account name must match the entry's username (`ivy`); for a
different account, add a one-line entry in `home-configurations.nix`.

## Inputs of note

- `nixpkgs` (unstable) backs aspen and houseplants; `nixpkgs-stable` (26.05)
  backs elm — keep the latter's release version matching `nixos-version` on
  elm. elm's host entry in `modules/den.nix` pins both `instantiate`
  (`nixpkgs-stable.lib.nixosSystem`) and `home-manager.module`
  (`home-manager-stable`) to match.
- `sops-nix` is wired into aspen and elm, for secrets. houseplants and
  lovecomputer don't need it — both are static Caddy edges with no secrets
  of their own.
- `disko` declares houseplants' and lovecomputer's disk layouts
  (`hosts/houseplants/_disko.nix`, `hosts/lovecomputer/_disko.nix`), used
  for their original `nixos-anywhere` installs; not used on aspen/elm.
- `nix-homebrew` manages Homebrew casks/brews declaratively on aspen.
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
(path pinned via `SOPS_AGE_KEY_FILE` in `modules/home/core.nix`) whose public
key is listed in `.sops.yaml` as `admin_ivy`. That private key lives only on
your own machine(s) — back it up somewhere durable, since losing it (without
still having a host that can decrypt) means re-encrypting from scratch.

New secrets: add the value via `sops`, then declare it in `modules/sops.nix`
(`sops.secrets.<name> = { };`) and reference it at
`config.sops.secrets.<name>.path` wherever it's consumed.
