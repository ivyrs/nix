# Rebuild and switch the current machine from this flake.
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{ os() }}" == "macos" ]]; then
        nh darwin switch . -H "$(hostname -s)"
    else
        nh os switch . -H "$(hostname -s)"
    fi

# Build and switch a remote NixOS host over SSH via Tailscale, e.g. `just deploy elm`.
deploy host:
    nh os switch -e passwordless -H {{ host }} --target-host "ivy@{{ host }}.ocelot-perch.ts.net" --build-host "ivy@{{ host }}.ocelot-perch.ts.net" .

# Evaluate the flake and run its checks.
check:
    nix flake check

# Update all flake inputs.
update:
    nix flake update
