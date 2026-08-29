# ChromeOSFetch

Fastfetch-style system information for **native ChromeOS**, written entirely in Bash.

ChromeOSFetch is designed for the ChromeOS developer shell and avoids needing a package manager or a compiled binary. That makes it useful on ChromeOS systems where directories such as `/home` or `/tmp` are mounted with `noexec`.

## What it shows

- ChromeOS version and architecture
- Chromebook board / HWID
- Kernel version
- Uptime
- Shell
- CPU
- GPU
- Memory usage
- Connected display resolutions
- Battery percentage and charging state
- Root filesystem usage

## Requirements

- ChromeOS in Developer Mode
- Access to the native developer shell (`chronos`)
- Bash
- `curl` for the download command

## Install

Download the script into your current directory:

```bash
curl -L -o chromeosfetch.sh https://raw.githubusercontent.com/Kaydn913/ChromeOSFetch/main/chromeosfetch.sh
```

## Run

```bash
bash chromeosfetch.sh
```

### Why `bash chromeosfetch.sh` instead of `./chromeosfetch.sh`?

ChromeOS commonly mounts user-writable locations with the `noexec` flag. Bash can still read and run the script directly even when the filesystem does not allow executing files from that location.

## Example

```text
chronos@chromebook
------------------------
OS: ChromeOS ... (x86_64)
Host: ...
Kernel: ...
Uptime: ...
Shell: /bin/bash
CPU: ...
GPU: ...
Memory: ...
Display: ...
Battery: ...
Disk: ...
```

## Notes

ChromeOSFetch reads system information from standard ChromeOS/Linux interfaces such as `/proc`, `/sys`, `/etc/lsb-release`, `crossystem`, and `lspci`. Some fields may show `Unknown` on hardware or ChromeOS builds that do not expose the relevant information.

ChromeOSFetch is not affiliated with Google, ChromiumOS, Fastfetch, or Neofetch.
