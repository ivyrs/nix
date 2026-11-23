# Prism migration baseline

This records step one, before Prism was added. See [step two](prism-step2.md) for the subsequent host-wiring change.
The machine-readable before/after results are in [prism-baseline.json](prism-baseline.json).

## Source and scope

- Original clean revision: `317931258a64715cea2b82f1b8243fb9f5d79fc7`.
- `flake.lock`, metadata, hardware files, and all state versions are unchanged.
- The usable migration baseline is **after disabling Hermes**, not the broken
  original Maple/Aspen evaluations. No lockfile update was performed.
- No build/switch or service stop was performed. Existing runtime services are
  not disabled until the new configuration is activated (or stopped separately).

## Hermes preparation

Removed Hermes's Home Manager module import, service/gateway/backend configuration,
CLI enablement, and required `hermesEnvFile` argument. Removed the system-to-home
secret argument as well, so Maple no longer needs SOPS just to evaluate the AI module.
Albedo remains installed.

The existing `hermes-agent` input and lock pin, Alder's encrypted `hermes-env`
secret/declaration, and all runtime data are retained for the upcoming move.
The old settings can be recovered from the original revision above. No credential
values were read or copied into this report.

## Results

| Host | Original evaluation | Hermes-disabled evaluation |
| --- | --- | --- |
| Alder | System + Home Manager pass | System + Home Manager pass |
| Maple | Missing `sops` through Hermes secret argument | System + Home Manager pass |
| Aspen | Missing `hermesEnvFile` module argument | System + Home Manager pass |
| Installer | System passes | System passes |

For all three managed homes, the Hermes program module is absent and no
Hermes-named Home Manager systemd user units are generated. Aspen retains
`/Users/ivy`; Linux homes retain `/home/ivy`. System state versions remain Alder
`25.11`, Maple/installer `26.05`, Aspen `6`; Home Manager remains `25.11`.

These are derivation **evaluations**, not successful system builds. The installer
ISO was not built. Its system derivation includes the repository contents and
therefore changes when configuration or report files are included; do not require
an identical installer derivation hash after a structural migration. Darwin's
configuration revision can also change with Git revision/dirty state.

The installer emits an existing `boot.zfs.forceImportRoot` default-value warning.
The flake formatting check was attempted but failed before reaching the formatter:
a keyutils dependency fetch from `lore.kernel.org` returned HTTP 403. There is no
standalone `nixfmt` on PATH. Formatting is therefore unverified, not passed.

## Repeat before changing host construction

From the repository root, evaluate each Linux desktop separately (replace `alder`
with `maple` for the second host):

```sh
nix eval --offline --no-write-lock-file --impure --json \
  .#nixosConfigurations.alder --apply 's: {
    system = s.config.system.build.toplevel.drvPath;
    home = s.config.home-manager.users.ivy.home.activationPackage.drvPath;
  }'

nix eval --offline --no-write-lock-file --impure --json \
  .#darwinConfigurations.aspen --apply 's: {
    system = s.system.drvPath;
    home = s.config.home-manager.users.ivy.home.activationPackage.drvPath;
  }'

nix eval --offline --no-write-lock-file --impure --raw \
  .#nixosConfigurations.installer.config.system.build.toplevel.drvPath
```

Use the Hermes-disabled results for the next pass. Keep the lockfile fixed; compare
Home Manager derivations and generated system configuration, investigating changes
rather than accepting them solely because evaluation succeeds. Build on suitable
platforms before activation. Alder requires local Asahi firmware; review its
Cachix uploader before firmware-dependent builds and retain a known-good generation.

Raw evaluation and formatting logs from this preparation were saved locally in
`/tmp/prism-baseline-20261113-223516`; the summary and derivation paths in this
directory are durable, but those temporary logs are not.
