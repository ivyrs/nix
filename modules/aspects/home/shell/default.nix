# The interactive shell as one concern, composed from the
# individually-referenceable aspects in this directory: zsh + aliases
# (zsh.nix), the starship prompt (starship.nix), fzf/zoxide/direnv
# (integrations.nix), and hyfetch/macchina (fetch.nix).
{den, ...}: {
  den.aspects.shell.includes = [
    den.aspects.zsh
    den.aspects.starship
    den.aspects.shell-integrations
    den.aspects.fetch
  ];
}
