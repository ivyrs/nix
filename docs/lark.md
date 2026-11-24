# Lark on Alder

`home/media/lark.nix` is imported by Alder's Home Manager profile. It uses packaged
source/frontend launchers and a separate `~/.config/lark/nix.toml`, preserving
the existing handmade `config.toml` and rmpc configuration. It currently mirrors
the non-secret source settings from that existing config. No password is copied.

## Source pin

Lark development is in `/home/ivy/projects/code/lark`. The signed local checkpoint
`0f696a1ab3a8179e5630dc75dde0042ba010a003` is pinned by the `lark`
input in `flake.lock`; nothing was pushed. The input follows the local `main`
branch only when explicitly updated with `nix flake update lark`.

This `git+file:///home/ivy/projects/code/lark` input is deliberately machine-local;
replace it with a published URL/revision before using this flake elsewhere.
Alder imports `../../../home/media/lark.nix` in its host Home Manager module.
Other in-flight host/gaming edits are preserved and not committed here.
The integration is configured but has **not been activated**.

## Before activation

- Provision `~/.config/lark/environment` privately (0600), or change
  `services.lark.environmentFile` to a suitable runtime sops-managed environment
  file. Never put its contents in a Nix expression or the Nix store. The expected
  assignment name is the Navidrome plugin's `password_env` (normally
  `NAVIDROME_PASSWORD`). See Lark's `nix/README.md` for safe provisioning.
- Review `home/media/lark.nix` and include an explicit local source if wanted:
  `name = "local"; exec = [ "${larkPackage}/bin/lark-source-local" ];`
  with `config.music_dir = "~/Music";` inside the plugin list.
- Stop the manually launched larkd before starting the service, to avoid owning
  the same Unix socket and MPD port twice. Existing library/history/plugin state
  is reused. Queue persistence is not implemented, so a restart clears it.
- The password file is intentionally not created by Home Manager. The user unit
  skips startup until it exists; it still needs the correct variables/password.

Then use the normal review/build/switch workflow (not automatically run here),
followed by `systemctl --user start lark`, `systemctl --user status lark`,
`journalctl --user -u lark -f`, and `lark sources`.

The existing PipeWire/ALSA setup is sufficient. No root daemon, firewall change,
or automatic lingering is needed. Existing playerctl media-key routing is not
changed; Lark has no MPRIS frontend yet. Remember the repository's existing
Asahi firmware/Cachix warning before a full Alder system build.
