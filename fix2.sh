#!/bin/bash
# ChromeOSFetch test build: clean Chrome logo, no backslash characters in logo

R=$'\033[0m'; RED=$'\033[1;31m'; G=$'\033[1;32m'; Y=$'\033[1;33m'; B=$'\033[1;34m'; C=$'\033[1;36m'; W=$'\033[1;37m'

user="$(whoami)"; host="$(hostname 2>/dev/null)"
if [ -r /etc/lsb-release ]; then
  os_name="$(grep '^CHROMEOS_RELEASE_NAME=' /etc/lsb-release | cut -d= -f2-)"
  os_version="$(grep '^CHROMEOS_RELEASE_VERSION=' /etc/lsb-release | cut -d= -f2-)"
  board="$(grep '^CHROMEOS_RELEASE_BOARD=' /etc/lsb-release | cut -d= -f2-)"
fi
[ -z "$os_name" ] && os_name="ChromeOS"
kernel="$(uname -r)"; arch="$(uname -m)"; shell_name="${SHELL:-/bin/bash}"
if command -v crossystem >/dev/null 2>&1; then hwid="$(crossystem hwid 2>/dev/null)"; fi
[ -z "$hwid" ] && hwid="$board"
cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^[[:space:]]*//')"; [ -z "$cpu" ] && cpu="Unknown"
if command -v lspci >/dev/null 2>&1; then gpu="$(lspci 2>/dev/null | grep -Ei 'VGA|3D|Display' | head -n1 | sed 's/^[^ ]* //')"; fi
[ -z "$gpu" ] && gpu="Unknown"
mt="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"; ma="$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)"
if [ -n "$mt" ] && [ -n "$ma" ]; then mu=$((mt-ma)); memory="$((mu/1024)) MiB / $((mt/1024)) MiB ($((mu*100/mt))%)"; else memory="Unknown"; fi
up="$(cut -d. -f1 /proc/uptime 2>/dev/null)"; days=$((up/86400)); hours=$(((up%86400)/3600)); mins=$(((up%3600)/60))
if [ "$days" -gt 0 ]; then uptime="${days}d ${hours}h ${mins}m"; elif [ "$hours" -gt 0 ]; then uptime="${hours}h ${mins}m"; else uptime="${mins}m"; fi
displays=""; for f in /sys/class/drm/card*-*/modes; do [ -r "$f" ] || continue; mode="$(head -n1 "$f")"; [ -n "$mode" ] || continue; case ",$displays," in *",$mode,"*) ;; *) displays="${displays:+$displays, }$mode" ;; esac; done; [ -z "$displays" ] && displays="Unknown"
battery="Unknown"; for bat in /sys/class/power_supply/BAT*; do [ -d "$bat" ] || continue; cap="$(cat "$bat/capacity" 2>/dev/null)"; stat="$(cat "$bat/status" 2>/dev/null)"; if [ -n "$cap" ]; then battery="${cap}%${stat:+ [$stat]}"; break; fi; done
disk="$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"; [ -z "$disk" ] && disk="Unknown"

# Each logo row is printed in separate segments so ANSI codes can never be interpreted as logo text.
print_logo_info() {
  printf '%b%s%b%b%s%b%b%s%b' "$1" "$2" "$R" "$3" "$4" "$R" "$5" "$6" "$R"
  printf '  %b%s%b\n' "$7" "$8" "$R"
}

print_logo_info "$RED" '          ##########          ' "$RED" '' "$RED" '' "$W" "$user@$host"
print_logo_info "$RED" '       ################       ' "$RED" '' "$RED" '' "$W" '------------------------'
print_logo_info "$RED" '     ####################     ' "$RED" '' "$RED" '' "$B" "OS: $os_name $os_version ($arch)"
print_logo_info "$RED" '    ############' "$Y" '########    ' "$RED" '' "$B" "Host: $hwid"
print_logo_info "$G" '   ########' "$W" '      ' "$Y" '########   ' "$G" "Kernel: $kernel"
print_logo_info "$G" '  ########' "$B" '######' "$Y" '########  ' "$G" "Uptime: $uptime"
print_logo_info "$G" '  ########' "$B" '######' "$Y" '########  ' "$Y" "Shell: $shell_name"
print_logo_info "$G" '  ########' "$B" '######' "$Y" '########  ' "$Y" "CPU: $cpu"
print_logo_info "$G" '   ########' "$W" '      ' "$Y" '########   ' "$C" "GPU: $gpu"
print_logo_info "$G" '    ####################    ' "$G" '' "$G" '' "$C" "Memory: $memory"
print_logo_info "$G" '      ################      ' "$G" '' "$G" '' "$B" "Display: $displays"
print_logo_info "$G" '         ##########         ' "$G" '' "$G" '' "$B" "Battery: $battery"
printf '%-30s  %b%s%b\n' '' "$G" "Disk: $disk" "$R"
