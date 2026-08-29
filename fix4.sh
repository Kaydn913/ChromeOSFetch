#!/bin/bash
# ChromeOSFetch test build using the classic Neofetch Chrom-style logo.
# Logo style adapted from Neofetch (MIT): https://github.com/dylanaraps/neofetch

R=$'\033[0m'
RED=$'\033[1;31m'
G=$'\033[1;32m'
Y=$'\033[1;33m'
B=$'\033[1;34m'
C=$'\033[1;36m'
W=$'\033[1;37m'

user="$(whoami)"
host="$(hostname 2>/dev/null)"

if [ -r /etc/lsb-release ]; then
    os_name="$(grep '^CHROMEOS_RELEASE_NAME=' /etc/lsb-release | cut -d= -f2-)"
    os_version="$(grep '^CHROMEOS_RELEASE_VERSION=' /etc/lsb-release | cut -d= -f2-)"
    board="$(grep '^CHROMEOS_RELEASE_BOARD=' /etc/lsb-release | cut -d= -f2-)"
fi
[ -z "$os_name" ] && os_name="ChromeOS"

kernel="$(uname -r)"
arch="$(uname -m)"
shell_name="${SHELL:-/bin/bash}"

if command -v crossystem >/dev/null 2>&1; then
    hwid="$(crossystem hwid 2>/dev/null)"
fi
[ -z "$hwid" ] && hwid="$board"

cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^[[:space:]]*//')"
[ -z "$cpu" ] && cpu="Unknown"

if command -v lspci >/dev/null 2>&1; then
    gpu="$(lspci 2>/dev/null | grep -Ei 'VGA|3D|Display' | head -n1 | sed 's/^[^ ]* //')"
fi
[ -z "$gpu" ] && gpu="Unknown"

mt="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
ma="$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)"
if [ -n "$mt" ] && [ -n "$ma" ]; then
    mu=$((mt-ma))
    memory="$((mu/1024)) MiB / $((mt/1024)) MiB ($((mu*100/mt))%)"
else
    memory="Unknown"
fi

up="$(cut -d. -f1 /proc/uptime 2>/dev/null)"
days=$((up/86400)); hours=$(((up%86400)/3600)); mins=$(((up%3600)/60))
if [ "$days" -gt 0 ]; then uptime="${days}d ${hours}h ${mins}m"
elif [ "$hours" -gt 0 ]; then uptime="${hours}h ${mins}m"
else uptime="${mins}m"; fi

displays=""
for f in /sys/class/drm/card*-*/modes; do
    [ -r "$f" ] || continue
    mode="$(head -n1 "$f")"
    [ -n "$mode" ] || continue
    case ",$displays," in *",$mode,"*) ;; *) displays="${displays:+$displays, }$mode" ;; esac
done
[ -z "$displays" ] && displays="Unknown"

battery="Unknown"
for bat in /sys/class/power_supply/BAT*; do
    [ -d "$bat" ] || continue
    cap="$(cat "$bat/capacity" 2>/dev/null)"
    stat="$(cat "$bat/status" 2>/dev/null)"
    if [ -n "$cap" ]; then battery="${cap}%${stat:+ [$stat]}"; break; fi
done

disk="$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
[ -z "$disk" ] && disk="Unknown"

row() {
    # $1 logo, $2 info color, $3 info text. Put info at a fixed terminal column.
    printf '%b\033[42G%b%s%b\n' "$1" "$2" "$3" "$R"
}

l1="${RED}            .,:loool:,.${R}"
l2="${RED}         .,coooooooooooooc,.${R}"
l3="${RED}      .,lllllllllllllllllllll,.${R}"
l4="${RED}     ;ccccccccccccccccccccccccc;${R}"
l5="${G}   '${RED}ccccccccccccccccccccccccccccc.${R}"
l6="${G}  ,oo${RED}c::::::::okO${W}000${Y}0OOkkkkkkkkkkk:${R}"
l7="${G} .ooool${RED};;;;:x${W}K0${B}kxxxxxk${W}0X${Y}K0000000000.${R}"
l8="${G} :oooool${RED};,;O${W}K${B}ddddddddddd${W}KX${Y}000000000d${R}"
l9="${G} lllllool${RED};l${W}N${B}dllllllllllld${W}N${Y}K000000000${R}"
l10="${G} lllllllll${RED}o${W}M${B}dccccccccccco${W}W${Y}K000000000${R}"
l11="${G} ;cllllllllX${W}X${B}c:::::::::c${W}0X${Y}000000000d${R}"
l12="${G} .ccccllllllO${W}Nk${B}c;,,,;cx${W}KK${Y}0000000000.${R}"
l13="${G}  .cccccclllllxOO${W}OOO${G}Okx${Y}O0000000000;${R}"
l14="${G}   .:ccccccccllllllllo${Y}O0000000OOO,${R}"
l15="${G}     ,:ccccccccclllcd${Y}0000OOOOOOl.${R}"
l16="${G}       '::ccccccccc${Y}dOOOOOOOkx:.${R}"
l17="${G}         ..,::cccc${Y}xOOOkkko;.${R}"
l18="${G}             ..,:${Y}dOkxl:.${R}"

row "$l1"  "$W" "$user@$host"
row "$l2"  "$W" "------------------------"
row "$l3"  "$B" "OS: $os_name $os_version ($arch)"
row "$l4"  "$B" "Host: $hwid"
row "$l5"  "$G" "Kernel: $kernel"
row "$l6"  "$G" "Uptime: $uptime"
row "$l7"  "$Y" "Shell: $shell_name"
row "$l8"  "$Y" "CPU: $cpu"
row "$l9"  "$C" "GPU: $gpu"
row "$l10" "$C" "Memory: $memory"
row "$l11" "$B" "Display: $displays"
row "$l12" "$B" "Battery: $battery"
row "$l13" "$G" "Disk: $disk"
row "$l14" "$R" ""
row "$l15" "$R" ""
row "$l16" "$R" ""
row "$l17" "$R" ""
row "$l18" "$R" ""
