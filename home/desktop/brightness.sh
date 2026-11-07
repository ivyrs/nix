target=${1:-screen}
value=${2:-info}
case "$target" in
  screen) options=(--class=backlight --min-value=1) ;;
  keyboard) options=(--class=leds '--device=*kbd*' --min-value=0) ;;
  *) echo 'Usage: desktop-brightness {screen|keyboard} {up|down|0..100|info}' >&2; exit 2 ;;
esac

case "$value" in
  info) exec brightnessctl "${options[@]}" info ;;
  up) value='5%+' ;;
  down) value='5%-' ;;
  *)
    if [[ ! "$value" =~ ^(100|[1-9]?[0-9])$ ]]; then
      echo 'Brightness must be up, down, info, or a percentage from 0 to 100.' >&2
      exit 2
    fi
    # Never black out the laptop panel; keyboard backlight may be switched off.
    if [ "$target" = screen ] && [ "$value" = 0 ]; then value=1; fi
    value="$value%"
    ;;
esac
exec brightnessctl "${options[@]}" set "$value"
