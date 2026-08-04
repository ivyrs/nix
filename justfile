# Rebuild and switch the current machine from this flake.
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    host="$(hostname -s)"
    extra_args=()
    if [[ "$host" == "alder" ]]; then
        # alder's peripheralFirmwareDirectory points outside the flake tree, which
        # always needs --impure to evaluate — see AGENTS.md for why.
        extra_args=(-- --impure)
    fi
    if [[ "{{ os() }}" == "macos" ]]; then
        nh darwin switch . -H "$host" "${extra_args[@]}"
    else
        nh os switch . -H "$host" "${extra_args[@]}"
    fi

# Build and switch a remote NixOS host over SSH via Tailscale, e.g. `just deploy elm`.
deploy host:
    nh os switch -e passwordless -H {{ host }} --target-host "ivy@{{ host }}.ocelot-perch.ts.net" --build-host "ivy@{{ host }}.ocelot-perch.ts.net" . {{ if host == "alder" { "-- --impure" } else { "" } }}

# Format the repo with alejandra.
fmt:
    nix fmt -- .

# Evaluate the flake and run its checks.
check:
    nix flake check

# Update all flake inputs.
update:
    nix flake update

