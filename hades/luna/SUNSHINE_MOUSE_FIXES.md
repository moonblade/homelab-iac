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

### 4. libvirtualhid Absolute mouse + Touchscreen desync (v2026.914+)
- **Cause**: Sunshine v2026.914 always creates `libvirtualhid Mouse (Absolute)` and `libvirtualhid Touchscreen` for macOS Moonlight clients, regardless of `native_pen_touch = disabled`. These fight the relative mouse.
- **Fix**: udev rule `LIBINPUT_IGNORE_DEVICE=1` fires on device creation — works on every reconnect, can't be skipped
  ```
  SUBSYSTEM=="input", ATTRS{name}=="libvirtualhid Mouse (Absolute)", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  SUBSYSTEM=="input", ATTRS{name}=="libvirtualhid Touchscreen", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  ```
- **File**: `hades/luna/nixos/modules/sunshine.nix` → `services.udev.extraRules`

### 5. Software encoding CPU starvation (beachball/lag)
- **Cause**: Sunshine using 115% CPU on software x264 encoding, starving the input thread
- **Fix**: Pull sunshine from `nixpkgs-unstable` (v2026.914) which has `autoAddDriverRunpath` — bakes `/run/opengl-driver/lib` into binary RPATH so `libcuda.so.1` can be found by the setcap wrapper (LD_LIBRARY_PATH is stripped for cap_sys_admin binaries)
- **Config**: `encoder = nvenc`, `capture = x11`, `config.cudaSupport = true` in flake.nix
- **Result**: CPU 115% → ~1% idle. h264_nvenc, hevc_nvenc, av1_nvenc all available.

## Current Config (sunshine.conf)
```
min_bitrate = 20000
fps = 60
qp = 20
adapter_name = NVIDIA GeForce RTX 5060 Ti
capture = x11
encoder = nvenc
resolutions = [1920x1200, 1920x1080, 1440x900, 1280x720]
audio_sink = sink-sunshine-stereo
native_pen_touch = disabled
key_repeat_delay = -1
global_prep_cmd = [{"do":"/home/moonblade/.local/bin/sunshine-mice-disable","undo":"/home/moonblade/.local/bin/sunshine-mice-enable"}]
```

## Emergency Recovery
If mouse stops working after a session:
```bash
ssh luna "/home/moonblade/.local/bin/sunshine-mice-enable"
ssh luna "systemctl --user restart sunshine"
```

## Key Facts
- Luna IP: 192.168.1.199, SSH alias: `ssh luna`
- Sunshine version: v2026.914 (from nixpkgs-unstable)
- Two clients connect interchangeably (two laptops), usually lid-close to disconnect
- VMware mice IDs: 8 and 9 (Proxmox-emulated, always present)
- libvirtualhid devices get new IDs on every session
