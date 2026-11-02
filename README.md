# ivy's Nix Configuration

NixOS desktop hosts, the Aspen nix-darwin host, and reusable Home Manager
modules. Host service lists remain explicit; shared system capabilities live
under `modules/`, and user applications and dotfiles live under `home/`.

Server infrastructure (Elm, Houseplants) lives in a separate flake,
[hp-nix](https://codeberg.org/houseplants/nix), which depends on this repo's
`homeModules` for its home-manager profile. Yew and Scarecrow were
decommissioned rather than migrated.

## Hosts

| Host | Platform | Purpose |
| --- | --- | --- |
| Alder | aarch64 Linux | Asahi desktop |
| Maple | x86_64 Linux | Desktop |
| Aspen | aarch64 Darwin | macOS desktop |
| installer | x86_64 Linux | Installation ISO |

## Local Workflow

- `just build` builds for the current hostname and platform.
- `just switch` builds and activates for the current hostname and platform.
- `just build aspen` and `just switch aspen` explicitly select a host.
- `just check` evaluates the flake and builds checks for the current platform.
- `just fmt` formats the configuration.
- `just update` explicitly updates the flake lock.

Build and switch require `nh`; the configured hosts install it after initial
activation. Initial macOS bootstrap still requires an existing Nix installation
and nix-darwin's bootstrap procedure, explicitly selecting `#aspen`.

Alder additionally requires its local `/etc/nixos/asahi-firmware` directory.
Its build/switch recipes pass `--impure`; a full firmware-dependent build cannot
be performed on another machine merely by adding that flag. Apple firmware must
not be published. **Alder currently enables an automatic Cachix store uploader**
in `modules/system/nix/cachix.nix`. Review/disable uploads before firmware builds;
cache downloads do not require the uploader. Removing the declaration without
activating a new configuration does not stop an already running uploader.

## x86 Applications

Alder uses [nix-x86-on-aarch64](https://github.com/rowanG077/nix-x86-on-aarch64)
for x86 and x86-64 Linux applications, Steam, and Wine. On Asahi's 16 KiB-page
kernel, the runtime automatically uses muvm and native DRM graphics forwarding.
After rebuilding and starting a new login session (for KVM group membership):

```sh
x86-arm doctor
nix-shell -p x86pkgs.hello --run hello
steam
x86-arm-wine /path/to/windows-installer.exe
```

`x86-arm stop` stops the runtime's VM and its applications. Wine defaults to
`~/.local/share/x86-on-arm/wineprefix`; set `WINEPREFIX` to use another prefix.
The runtime owns both x86 ELF handlers, replacing Alder's QEMU binfmt setup.
It does not advertise x86 build support to the Nix daemon, so uncached x86
packages and the installer ISO need a suitable builder.

## Secrets and Recovery

SOPS creation rules are in `.sops.yaml`. Changing those rules does not update
recipients on existing documents; reconcile them with `sops updatekeys` using an
authorized administrator identity. Do not manually remove recipient metadata.
After removing access, rotate credentials if historical ciphertext was available
to the removed recipient.

Service secrets have restart hooks where consumers snapshot them at startup.
Changing Nextcloud's initial administrator-password file does not reset an
existing administrator password. Application encryption/signing-key changes
still require the application's supported rotation procedure.

Outstanding work is tracked in `TODO.md`: credential rotation, Aspen PIM
credentials, backup/restore coverage, and privilege-policy decisions. Clearing a
credential from this checkout does not remove it from Git history or old store
paths.

The [cleanup audit](AUDIT.md) records input usage, retained dependency pins,
verification results, and prioritized follow-ups.

## Home Manager Exports

The `homeModules` output exposes shell, Git, tmux, Neovim, Niri, Ghostty,
Noctalia, and combined profiles. Modules that use flake inputs require consumers
to pass `inputs = ivy-nix.inputs` through `home-manager.extraSpecialArgs`.
Noctalia imports the nvf option definitions without enabling Neovim itself.
Generated themes remain mutable, with static Lazygit settings layered separately
and Niri's generated theme include optional for first startup.
