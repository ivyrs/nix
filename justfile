# Rebuild and switch the current machine (aspen or elm) from this flake.
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{ os() }}" == "macos" ]]; then
        nh darwin switch --ask . -H "$(hostname -s)"
    else
        nh os switch --ask . -H "$(hostname -s)"
    fi

# Build and switch a remote NixOS host over SSH via Tailscale, e.g. `just deploy elm`.
deploy host:
    nh os switch -H {{ host }} --target-host "ivy@{{ host }}.ocelot-perch.ts.net" --build-host "ivy@{{ host }}.ocelot-perch.ts.net" .

# Evaluate the flake and run its checks.
check:
    nix flake check

# Update all flake inputs.
update:
    nix flake update
