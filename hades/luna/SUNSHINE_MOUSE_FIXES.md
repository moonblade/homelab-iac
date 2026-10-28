# Luna Sunshine Mouse Fix History

## Problem
Mouse desync, infinite key repeat, and cursor lag when streaming via Moonlight.

## Root Causes & Fixes Applied

### 1. uinput device accumulation (native_pen_touch bug)
- **Cause**: Pre-v2026.906 Sunshine didn't destroy Touch/Pen uinput devices on disconnect → devices accumulated → duplicate input events
- **Fix**: `native_pen_touch = disabled` in sunshine.conf
- **Status**: Still set as belt-and-suspenders even on v2026.914

### 2. Infinite key repeat
- **Cause**: Sunshine's software key repeat fires independently; if key-up is dropped on network hiccup, repeat gets stuck
- **Fix**: `key_repeat_delay = -1` in sunshine.conf (disables Sunshine's repeat, lets X11 handle it)

### 3. VMware VMMouse desync
- **Cause**: Two Proxmox-emulated VirtualPS/2 VMware VMMouse devices (id=8, id=9) compete with Sunshine's relative mouse passthrough
- **Fix**: `global_prep_cmd` runs `~/.local/bin/sunshine-mice-disable` on stream start, `sunshine-mice-enable` on end
- **Gotcha**: `global_prep_cmd` only fires on FIRST session after idle (not on lid-close reconnects)
- **Fix for gotcha**: disable script does enable-then-disable to reset stale state from previous abrupt disconnect

### 4. libvirtualhid Touchscreen desync (v2026.914+)
- **Cause**: Sunshine v2026.914 creates `libvirtualhid Touchscreen` for macOS Moonlight clients — spurious touch events
- **Fix**: udev rule `LIBINPUT_IGNORE_DEVICE=1` on Touchscreen only (fires on device creation every reconnect)
  ```
  SUBSYSTEM=="input", ATTRS{name}=="libvirtualhid Touchscreen", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  ```
- **Note**: `libvirtualhid Mouse (Absolute)` udev rule was REMOVED — needed for absolute mouse mode

### 5. Software encoding CPU starvation (beachball/lag)
- **Cause**: Sunshine using 115% CPU on software x264 encoding, starving the input thread
- **Fix**: Pull sunshine from `nixpkgs-unstable` (v2026.914) which has `autoAddDriverRunpath` — bakes `/run/opengl-driver/lib` into binary RPATH so `libcuda.so.1` can be found by the setcap wrapper (LD_LIBRARY_PATH is stripped for cap_sys_admin binaries)
- **Config**: `encoder = nvenc`, `capture = x11`, `config.cudaSupport = true` in flake.nix (unstable pkgs only, NOT stable pkgs)
- **Result**: CPU 115% → ~1% idle. h264_nvenc, hevc_nvenc, av1_nvenc all available.

### 6. Absolute mouse mode not working (in progress, Oct 28 2026)
- **Symptom**: Moonlight "optimize for remote desktop" (absolute mouse) → cursor doesn't move
- **Root cause**: Moonlight sends absolute coordinate packets; Sunshine injects them via `move_absolute()` on `libvirtualhid Mouse` (a relative EV_REL device) → X11 ignores EV_ABS events on a relative device
- **What was tried**:
  - Removing udev `LIBINPUT_IGNORE_DEVICE` rule for `libvirtualhid Mouse (Absolute)` → device still not created (controlled by `native_pen_touch`, not udev)
  - Setting `native_pen_touch = enabled` → creates `libvirtualhid Mouse (Absolute)` but absolute mode still broken; also risks device accumulation bug
  - Switching to stable 26.05 sunshine package with `cudaSupport = true` → triggered full CUDA rebuild from source (hours, 100% CPU) — **DO NOT DO THIS**
- **Status**: Investigating. Relative mouse (games mode) works correctly.
- **Workaround**: Use Moonlight "optimize for games" (relative mouse) — works fine for desktop use too

## ⚠️ NEVER DO THIS
- **Never set `nixpkgs.config.cudaSupport = true` on stable pkgs** — it triggers a full local CUDA build from source (hours, pegs all CPUs). `cudaSupport = true` is only safe on `pkgsUnstable` because unstable sunshine is pre-built in the binary cache with CUDA support.
- Always use `package = pkgsUnstable.sunshine` — never `pkgs.sunshine` (stable has no cached CUDA build)

## Current Config (sunshine.conf)
```
min_bitrate = 20000
qp = 20
adapter_name = NVIDIA GeForce RTX 5060 Ti
capture = x11
encoder = nvenc
audio_sink = sink-sunshine-stereo
native_pen_touch = disabled
key_repeat_delay = -1
global_prep_cmd = [{"do":"/home/moonblade/.local/bin/sunshine-mice-disable","undo":"/home/moonblade/.local/bin/sunshine-mice-enable"}]
```
Note: `fps` and `resolutions` are unrecognized options in v2026.914 (config format changed).

## Emergency Recovery
If mouse stops working after a session:
```bash
ssh luna "/home/moonblade/.local/bin/sunshine-mice-enable"
ssh luna "systemctl --user restart sunshine"
```

## Key Facts
- Luna IP: 192.168.1.199, SSH alias: `ssh luna`
- Sunshine version: v2026.914 (from nixpkgs-unstable) — pre-built with NVENC/CUDA in binary cache
- Two clients connect interchangeably (two laptops), usually lid-close to disconnect
- VMware mice IDs: 8 and 9 (Proxmox-emulated, always present)
- libvirtualhid devices get new IDs on every session
- Moonlight "games mode" = relative mouse (EV_REL) = works
- Moonlight "remote desktop mode" = absolute mouse (EV_ABS) = broken on Linux/X11 (cursor doesn't move)
