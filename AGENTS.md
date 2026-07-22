# AGENTS.md

Guidance for AI agents working in this repo. See `README.md` first for the
overall layout.

## Den — how this flake is wired

This flake is built on [Den](https://github.com/denful/den) (`inputs.den`,
imported in `modules/den.nix`). Every `.nix` file under `modules/` and
`hosts/` is still auto-imported by `import-tree` (wired in `flake.nix`), and
files register reusable feature modules under `flake.modules.<class>.<name>`,
e.g.:

```nix
{
  flake.modules.nixos.syncthing = { ... };
}
```

`<class>` is one of `nixos`, `darwin`, `homeManager`. That part is unchanged
from before Den. What Den replaced is the layer above it:

- **`den.hosts.<system>.<name>`** (in `modules/den.nix`) declares each
  machine and its users. Den turns these into real `darwinConfigurations.*` /
  `nixosConfigurations.*` outputs — there is no more hand-written
  `modules/configurations.nix` assembling them.
- **`den.aspects.<name>`** is a feature as a function of context
  (`{ host, user }`), holding config for every Nix class it touches at once.
  Each host's `default.nix` (`hosts/aspen/`, `hosts/elm/`,
  `hosts/houseplants/`) defines that host aspect's `darwin`/`nixos` owned
  config; each host's `home.nix` defines its `provides.to-users.homeManager`
  (delivered to every user on the host — currently just `ivy`).
  `modules/den.nix` defines the shared `ivy` user aspect, which only wires
  `den.batteries.define-user` and `den.batteries.primary-user` (OS user
  creation, primary-user groups/`system.primaryUser`) — genuinely
  cross-host, cross-platform content.

Implications for edits:
- **Adding a reusable module**: same as before — create a new file under
  `modules/`, give it a `flake.modules.<class>.<name>` attribute, picked up
  automatically.
- **Using a module inside a host aspect**: reference it via
  `config.flake.modules.<class>.<name>` in the aspect's owned-config
  `imports`, same pattern as before Den.
- **Third-party OS modules** (sops-nix, nix-homebrew, home-manager itself)
  are imported directly into a host aspect's owned-config `imports`, e.g.
  `inputs.sops-nix.darwinModules.sops` in `hosts/aspen/default.nix`. Only
  `home-manager`'s own OS module is handled by Den automatically (because
  `ivy` has `homeManager` in its classes); Den forwards
  `den.aspects.<host>.provides.to-users.homeManager` into
  `home-manager.users.ivy` for you.
- **Module-arg gotcha**: functions nested inside an aspect's owned config
  (e.g. the `({ pkgs, ... }: { ... })` blocks in `hosts/*/default.nix`) are
  evaluated by the underlying `darwinSystem`/`nixosSystem` call, which does
  **not** get `inputs`/`den`/`config` as specialArgs the way the outer
  aspect-definition file does. Reference `inputs`/`config` from the
  **outer** file-level function's arguments via lexical closure — don't
  re-request them as a parameter on the nested function, it'll error with
  `attribute 'inputs' missing` (or `'self' missing` — use `inputs.self`,
  not bare `self`).
- **Don't** build a manual `imports = [ ./foo.nix ./bar.nix ]` list anywhere
  under `modules/`/`hosts/` — that defeats the point of import-tree.

## Three very different targets

`aspen` is nix-darwin + home-manager (macOS, personal machine). `elm` and
`houseplants` are both plain NixOS, but play opposite roles: `elm` is the
home server sitting behind the tailnet (Syncthing, glance, miniflux,
pocket-id, vaultwarden, Nextcloud, GoToSocial, Forgejo — all on bare ports,
no public exposure), while `houseplants` is a Hetzner VPS that's the *only*
host with `networking.firewall.allowedTCPPorts = [80 443]` open to the real
internet — it runs Caddy (`modules/services/caddy.nix`) and reverse-proxies
each public hostname to the matching port on `elm.<tailnet>` over Tailscale.
Adding a new elm service that needs public exposure means two edits: the
service itself on elm, and a new `virtualHosts."..."` block in
`modules/services/caddy.nix` pointing at its port.

A module meant for one host will generally not evaluate on another (e.g.
`system.defaults` is darwin-only, `boot.loader` is NixOS-only). When adding
something intended to be shared across hosts, check it's platform-neutral
before wiring it into each host's aspect definition.

## Guardrails already left in the code — read before touching

- `hosts/elm/_hardware-configuration.nix` and
  `hosts/houseplants/{_hardware-configuration,_disko}.nix` are
  generated (by `nixos-generate-config` / `nixos-anywhere`); never hand-edit
  them.
- `hosts/elm/default.nix` and `hosts/houseplants/default.nix`:
  `system.stateVersion` has a "don't fuck with this" comment on both — leave
  it alone even during unrelated refactors.
- `modules/den.nix`: `den.default.homeManager.home.stateVersion` is "set
  once, don't bump casually" — same rule, applies to all three hosts (hoisted
  here since it was identical everywhere).
- `networking.firewall.interfaces."tailscale0".allowedTCPPorts` entries on
  elm (glance, vaultwarden, nextcloud, miniflux, etc.) are effectively
  no-ops: Tailscale's own iptables `ts-input` chain accepts all traffic on
  `tailscale0` before NixOS's `networking.firewall` is ever evaluated, so
  every port on elm is already reachable tailnet-wide regardless of these
  lists. Don't treat them as real access control, and don't "fix" a security
  concern by adding one — real per-service restriction needs a Tailscale ACL
  in the admin console, not a NixOS firewall change.
- Comments flagged `verify this` / `confirm this` mark values the user
  hasn't independently confirmed against the real machine — flag rather than
  silently trust when reasoning about them.
- `modules/darwin/homebrew.nix`: `cleanup = "zap"` means anything not listed
  in `brews`/`casks` gets uninstalled on activation — adding a cask means
  adding it here, not installing it out-of-band.
- `secrets/secrets.yaml` is sops-encrypted and safe to commit as-is — never
  write a decrypted value into it directly or into any other tracked file.
  Edit it with `sops secrets/secrets.yaml`; see the README's Secrets section.
- Nix flakes only see git-tracked files. A new file under `modules/`/`hosts/`
  (or `secrets/`) is invisible to `nix eval`/`nix build` until it's at least
  `git add`ed, even uncommitted — a "no matching creation rules found" or
  "attribute ... missing" error after adding a new file usually means this.
- `modules/services/glance/_*.nix` are underscore-prefixed **on purpose**:
  import-tree skips them, and they are plain functions/attrsets imported
  explicitly by `glance/default.nix`, not flake-parts modules. Conversely,
  any non-underscored `.nix` file under `modules/`/`hosts/` WILL be
  auto-imported as a flake-parts module and must register via
  `flake.modules.*`/`den.aspects.*` — don't drop a helper file there without
  the underscore.
- Shared constants come from `config.flake.lib.meta` (`modules/meta.nix`).
  Read it at the **file level** and close over it — inside a nested
  `({ pkgs, ... }: ...)` block, `config` is the OS/HM config, not the flake's
  (same class of gotcha as the module-arg one above).
- `modules/sops.nix`: the darwin `placeholder` secret is a canary, not dead
  code — sops-nix's darwin module is a no-op with zero secrets, so it keeps
  host-key decryption exercised on aspen. Don't delete it.

## Sanity-checking changes

There's no CI in this repo. Before considering a change done, at minimum run:

```
nix flake check
```

and, if you have access to the target machine, a real rebuild — `just switch`
from the host itself, or `just deploy elm`/`just deploy houseplants` from
another machine on the tailnet (works fine unattended/non-interactively;
see the README's Usage section). `nix flake check` alone won't catch every
activation-time issue (e.g. Homebrew/darwin-only assertions on aspen).
`darwin-rebuild build --flake .#aspen` / `nixos-rebuild build --flake
.#<host>` (build without activating) is a good middle ground when you can't
activate directly.
