# Willow — Steam Deck OLED (draft)

Steam Gaming Mode boots automatically as `ivy`; **Switch to Desktop** opens
Plasma Wayland. Log out of Plasma to return to Gaming Mode. Autologin means
anyone holding an unlocked Deck can access this account.

Jovian supplies the Deck kernel, OLED/LCD hardware support, firmware, audio,
controls and session integration. Keep these host-specific: do not import the
workstation's Ly, Niri, generic audio/portal modules or full Home Manager profile.
Tailscale is enabled with `ivy` as its local operator; after installation, run
`tailscale up` as `ivy` and follow the sign-in link to join the tailnet. No auth
key is stored in this configuration, and Tailscale SSH is not enabled.
No Decky plugins, TLP, extra power-tuning daemon or SSH server are enabled.
The existing stable nixpkgs is used; Jovian normally tracks unstable, so evaluate
and build after input updates before deploying. Firmware flashing is not enabled
automatically by this draft.

## Finish before installing

This host is deliberately **not** in `flake.nix`'s `nixosConfigurations` list,
so an unfinished disk configuration does not break existing flake checks.
`hardware.nix` contains a failing assertion rather than invented disk UUIDs.

1. Back up SteamOS/data and decide on replacement versus dual boot. This draft
   supplies no partitioning recipe. Boot a NixOS installer, prepare your intended
   layout, mount root at `/mnt` and the EFI system partition at `/mnt/boot`.
   Review the systemd-boot choice for your layout, especially for dual boot.
2. From the repository root on the Deck, replace the placeholder:

   ```sh
   nixos-generate-config --root /mnt --show-hardware-config > hosts/nixos/willow/hardware.nix
   ```

   Review the generated filesystems, UUIDs, swap and encryption configuration.
   Preserve Jovian's kernel selection rather than copying workstation tweaks.
3. Add `"willow"` alongside `"alder"` and `"maple"` in `flake.nix`'s
   `nixosConfigurations` / `genAttrs` host list. Stage the new host files if using
   a Git checkout (flakes omit untracked files).
4. Evaluate and build on an x86_64 Linux machine or configured remote builder:

   ```sh
   nix eval .#nixosConfigurations.willow.config.system.build.toplevel.drvPath
   nix build .#nixosConfigurations.willow.config.system.build.toplevel
   ```

5. Install from the live environment with the prepared filesystems mounted:

   ```sh
   sudo nixos-install --flake .#willow
   sudo nixos-enter --root /mnt -c 'passwd ivy'
   ```

   The installer prompts for root's password; the second command sets `ivy`'s
   password for sudo and desktop authentication. Do not skip it. No default
   password is configured. Keep `system.stateVersion` at the initial install's
   version; it is not an upgrade switch.

After installation, `just build willow` and `just switch willow` use the normal
host workflow. Test Wi-Fi, Bluetooth, speakers/headphones, suspend/resume,
controller input, brightness/HDR, refresh rate, TDP controls, desktop switching
microSD access and Tailscale connectivity on the actual OLED before treating the
configuration as ready.
This draft does not claim verified OLED operation or a completed installation.

References: [Jovian configuration](https://jovian-experiments.github.io/Jovian-NixOS/configuration.html),
[Steam Deck hardware](https://jovian-experiments.github.io/Jovian-NixOS/devices/valve-steam-deck/).
