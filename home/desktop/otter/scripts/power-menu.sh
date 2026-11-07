# Cancellation (including Escape) must never trigger a session action.
action=$(printf '%s\n' 'Cancel' 'Log out' 'Reboot' 'Shut down' |
  fsel --dmenu --only-match --select-index 0) || exit 0

case "$action" in
  'Log out'|'Reboot'|'Shut down') ;;
  *) exit 0 ;;
esac

confirmation=$(printf '%s\n' 'Cancel' "Confirm: $action" |
  fsel --dmenu --only-match --select-index 0) || exit 0
[ "$confirmation" = "Confirm: $action" ] || exit 0

case "$action" in
  'Log out') exec niri msg action quit --skip-confirmation ;;
  'Reboot') exec systemctl reboot ;;
  'Shut down') exec systemctl poweroff ;;
esac
