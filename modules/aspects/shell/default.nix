# The interactive shell as one concern, composed from zsh + aliases
# (zsh.nix), nushell as an opt-in second shell (nu.nix), starship
# (starship.nix), fzf/zoxide/direnv (integrations.nix), and hyfetch/fastfetch
# (fetch.nix).
{den, ...}: {
  den.aspects.shell.includes = [
    den.aspects.zsh
    den.aspects.nu
    den.aspects.starship
    den.aspects.shell-integrations
    den.aspects.fetch
  ];
}
