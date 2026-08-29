#!/bin/bash
# chromeosfetch - Bash-only system fetch for ChromeOS

R='\033[0m'
RED='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
C='\033[1;36m'
W='\033[1;37m'

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

# Chrome-style ASCII logo + system info
printf "${RED}          .,:loool:,.           ${W}%s@%s${R}\n" "$user" "$host"
printf "${RED}      .,coooooooooooooc,.       ${W}------------------------${R}\n"
printf "${RED}    ,ooooooooooooooooooooo,     ${B}OS${R}: %s %s (%s)\n" "$os_name" "$os_version" "$arch"
printf "${RED}  ,ooooooooooooooooooooooo${Y}oo,   ${B}Host${R}: %s\n" "$hwid"
printf "${RED} ;ooooooooooooo${Y}oooooooooooo;  ${G}Kernel${R}: %s\n" "$kernel"
printf "${RED}:oooooooooooo${Y}oooooooooooooo: ${G}Uptime${R}: %s\n" "$uptime"
printf "${G}ooooooo${RED}ooooo${B}########${Y}ooooooo ${Y}Shell${R}: %s\n" "$shell_name"
printf "${G}ooooooo${RED}oooo${B}##########${Y}ooooooo ${Y}CPU${R}: %s\n" "$cpu"
printf "${G}ooooooo${RED}oooo${B}##########${Y}ooooooo ${C}GPU${R}: %s\n" "$gpu"
printf "${G}ooooooo${RED}ooooo${B}########${Y}ooooooo ${C}Memory${R}: %s\n" "$memory"
printf "${G}:oooooooooooo${B}oooooooooooooo: ${B}Display${R}: %s\n" "$displays"
printf "${G} ;oooooooooooo${B}oooooooooooo;  ${B}Battery${R}: %s\n" "$battery"
printf "${G}  ,ooooooooooooooooooooooo${B}oo,   ${G}Disk${R}: %s\n" "$disk"
printf "${G}    ,ooooooooooooooooooooo,${R}\n"
printf "${G}      .,coooooooooooooc,.${R}\n"
printf "${G}          .,:loool:,.${R}\n"
printf "${R}\n"
