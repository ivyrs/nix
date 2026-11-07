# Print the first system battery; peripheral batteries must not win detection.
for supply in "${1:-/sys/class/power_supply}"/*; do
  [ -r "$supply/type" ] || continue
  read -r supply_type < "$supply/type" || continue
  [ "$supply_type" = Battery ] || continue

  if [ -r "$supply/scope" ]; then
    read -r scope < "$supply/scope" || continue
    [ "$scope" != Device ] || continue
  fi

  [ -r "$supply/capacity" ] || continue
  read -r capacity < "$supply/capacity" || continue
  case "$capacity" in
    ''|*[!0-9]*) continue ;;
  esac
  printf '[ BAT %s%% ]  ' "$capacity"
  break
done
