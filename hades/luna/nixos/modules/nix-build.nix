# nix-build: Prevent nix builds from OOM-killing the desktop
# Context: Luna has 20GB RAM, no swap by default. Heavy nix builds (ML libs like
# pytorch, alltalk) + Chrome + Steam caused OOM on 2026-11-14.
# Fix 1: zram swap — compressed in-memory swap, safety net for spikes
# Fix 2: nix build limits — cap parallelism and RAM so builds don't starve the desktop
{ config, lib, pkgs, ... }:

{
  # --- zram swap ---
  # Compressed in-memory swap device. No disk needed.
  # At ~3:1 compression ratio, 8GB zram ≈ ~24GB effective swap for typical data.
  # Algorithm: zstd (best compression/speed tradeoff for this use case)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Use 40% of RAM for zram device (8GB on a 20GB VM)
    memoryPercent = 40;
  };

  # --- nix build limits ---
  nix.settings = {
    # Max parallel build jobs. Each job can use multiple cores.
    # 2 jobs = nix won't fork more than 2 builders simultaneously.
    max-jobs = 2;

    # Cores per build job. With 6 vCPUs total, give builds 3 cores each.
    # Leaves 3 cores for the desktop/Steam/browser during builds.
    cores = 3;
  };

  # --- nix build RAM limit via systemd cgroup ---
  # Caps the total RAM the nix-daemon (and all its build children) can use.
  # 8GB = enough for most builds; Nix will slow down but won't OOM the desktop.
  systemd.services.nix-daemon = {
    serviceConfig = {
      MemoryHigh = "8G";   # Soft limit: start throttling at 8GB
      MemoryMax  = "10G";  # Hard limit: OOM-kill build, not the desktop
    };
  };
}
