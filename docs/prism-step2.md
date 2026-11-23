# Prism migration: host wiring

Prism is locked to `2a4792ce009bf67dc7c03417d70b5649fdf80de6` from
`git+https://tangled.org/poacher.dev/prism`. Its nixpkgs input follows this flake's
stable nixpkgs; its other dependencies use upstream lock pins. No pre-existing
lock node or root input reference changed.

`prism/default.nix` declares four explicitly buildable leaf tags and preserves
constructor platform arguments and Aspen's user metadata. `prism/hosts.nix`
imports the existing Linux host modules. Aspen uses the tag's `extraModules`
hook: nesting its module in a Prism section reordered system packages relative
to nix-darwin defaults, so retaining the original module depth avoids that churn.
Prism does not supply a preconstructed `pkgs`; existing overlays and unfree policy
remain owned by the ordinary system modules.

The public NixOS/Darwin host names and all other output definitions remain intact.
No host, Home Manager, hardware, secret, desktop, or state-version configuration
was reorganized in this step. Hermes remains disabled as prepared in step one.

## Verification

- All four host equivalence assertions passed: Alder, Maple, Aspen, installer.
- All three Home Manager derivations also match the Hermes-disabled step-one
  baseline exactly. Alder and Maple system derivations match it exactly too.
- Platforms, home directories, state versions, Hermes absence, and public host
  names passed the checked-in assertions.
- Existing lock nodes/root input references, hardware files, and metadata are
  unchanged; the lockfile only adds Prism and its upstream dependency graph.
- The pinned nixfmt 1.4.0 was available after resuming verification; direct
  formatting checks pass for the changed Nix files. The full flake formatting
  derivation was not rebuilt (its earlier dependency-fetch failure is separate).


`tests/prism-equivalence.nix` constructs both the old-style and Prism systems
from the same current source and inputs, and asserts equal system/Home Manager
derivations, platforms, state versions, home directories, and Hermes status.
It also asserts the exact public host sets. Run each host separately:

```sh
nix eval --offline --no-write-lock-file --impure --json \
  --file tests/prism-equivalence.nix --apply 'check: check { host = "alder"; }'
```

Repeat for `maple`, `aspen`, and `installer`. These checks evaluate derivations;
they do not build or activate systems. The installer derivation includes source
files and therefore differs from the historical step-one snapshot; compare the
legacy and migrated constructors against the same current source instead.
Aspen's revision metadata may also differ between path and Git flake invocations.

Shared-tag extraction is the next step, not part of this change.
