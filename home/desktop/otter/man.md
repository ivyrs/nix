# OTTER(1)

## NAME

otter-prompt - desktop command prompt powered by otter-launcher

## SYNOPSIS

    otter-prompt
    otter-launcher [OPTIONS] [PREFIX [ARGUMENT...]]

In the prompt:

    PREFIX [ARGUMENT...]
    SEARCH TEXT

## DESCRIPTION

Open Otter with Mod+/ in niri, or run `otter-prompt`. The wrapper opens
an independent, floating Foot window with a one-line `/ ` prompt.
The slash is decoration; do not type it before commands.

Type a command prefix, optionally followed by a space and its argument,
and press Enter. Prefixes are matched against the first word of input.
Commands without arguments should be entered on their own.

Unmatched input opens fsel with that text pre-filled as an application
search. Enter on an empty prompt opens fsel without a search. To search
for an app whose name is also a command prefix, use `s NAME` explicitly.

Most interactive tools open in a separate Ghostty window through `tui`.
The power menu uses its own Foot window. Other actions run directly.

This manual describes this repository's configuration, not upstream's
example modules.

## KEYS

    Enter       Submit the prompt.
    Tab         Complete the suggested command prefix.
    Tab again   Undo that completion, before further editing.
    Esc         Close the prompt without running a command.
    Ctrl+D      Close the prompt without running a command.
    Ctrl+U      Delete from the cursor to the start of the line.

Type `?` and press Enter for the built-in command cheat sheet.
Type `man` and press Enter to read this manual; press `q` to leave less.
The current configuration uses hint suggestions and default Emacs-style
editing, not vi mode. Ctrl+C is copy, not the cancel shortcut.

## COMMANDS

### Applications and shell

    s [TEXT]
        Search applications with fsel, pre-filling TEXT if supplied.
        This is also the default for unmatched or empty input.

    a NAME
        Launch an application directly using fsel's program lookup,
        rather than opening an interactive search.

    ai [DIRECTORY]
        Open a new Albedo session in DIRECTORY. With no argument, use
        the home directory. Supports ~ and ~/ paths. If changing to
        the directory fails, no session is started.

    sh COMMAND
        Run COMMAND using sh -c. Does not open a new terminal or keep
        output visible after the prompt closes. For interactive tools
        or output you want to keep, use `sh tui PROGRAM ARGUMENT...`.

    man
        Open this manual in less in a separate terminal.

### Network

    net         Network configuration (nmrs-tui).
    bt          Bluetooth configuration (bluetui).
    ts          Tailscale configuration (lazytailscale).

### Media and system tools

    mus         Music player (musikcube).
    vol         Audio mixer (wiremix).
    stat        System monitor (btop).
    kb          Flash the Moonlander keyboard (zapp update).

### Brightness

    bright VALUE
        Set screen brightness. VALUE is 0 through 100, up, or down.
        Up/down change brightness by 5 percentage points. Screen 0
        is clamped to 1% to avoid blacking out the panel.

    kbd VALUE
        Set keyboard backlight. Accepts the same values as bright,
        but 0 switches the backlight off.

### Desktop and notifications

    theme       Toggle light/dark mode, then randomise the wallpaper
                if the theme toggle succeeds.
    wall        Randomise the wallpaper.
    lock        Lock the screen (desktop-lock).
    dnd         Toggle do-not-disturb mode in mako.
    notif       Recall the last notification (makoctl restore).

### Power

    power
        Open a menu offering Cancel, Log out, Reboot, and Shut down.
        Each session action requires a second confirmation. Both menus
        select Cancel initially; cancellation never triggers an action.

## EXAMPLES

These are prompt contents, without the displayed `/ `:

    firefox                 Search apps for "firefox".
    s firefox               Explicitly search apps for "firefox".
    a firefox               Launch Firefox directly.
    ai ~/nix                Open Albedo in ~/nix.
    bright 50               Set screen brightness to 50%.
    bright down             Lower screen brightness by 5 points.
    kbd 0                   Turn the keyboard backlight off.
    sh tui journalctl -f    Follow the journal in a separate terminal.
    man                     Read this manual.

From a shell, bypass the prompt interface with:

    otter-launcher bright 50
    otter-launcher ai ~/nix

`otter-prompt` opens the interface only; it does not forward arguments.

## OPTIONS

Options apply to `otter-launcher`, not to `otter-prompt`:

    -c, --config FILE    Use an alternative TOML configuration file.
    -h, --help           Show command-line help.
    -v, --version        Show the launcher version.

Without prompt arguments, otter-launcher starts its terminal interface.
With arguments, it dispatches them directly using the same modules.

## FILES

    ~/.config/otter-launcher/config.toml
        User configuration. Checked before /etc/otter-launcher/config.toml;
        an explicit --config takes precedence over both.

    ~/.config/foot/otter.ini
        Foot appearance used by otter-prompt and the power menu.

Repository sources:

    home/desktop/otter/config.toml    Command definitions and prompt style.
    home/desktop/otter/default.nix    Packages and terminal wrappers.
    home/desktop/otter/foot.ini       Prompt terminal appearance.
    home/desktop/otter/man.md         This manual.
    home/desktop/niri/binds.kdl       Mod+/ launcher binding.
    home/desktop/niri/ux.kdl          Floating-window rules.

Edit the repository sources rather than Home Manager's generated files,
then apply the Home Manager configuration. The `man` command currently
expects this checkout at ~/nix/home/desktop/otter/man.md.

## NOTES

Commands execute through `sh -c`, and module arguments are substituted
into shell command strings without automatic escaping. Shell syntax,
including substitutions, can be evaluated even outside the `sh` module.
Only enter trusted input; this is not a sandbox or a literal-text API.

An unmatched program name is an app search, not a shell command. Use
`sh` explicitly for shell commands. Tools and hardware controls require
the corresponding programs, services, permissions, and devices.

## SEE ALSO

otter-launcher --help, fsel --help, foot(1), less(1), sh(1)
