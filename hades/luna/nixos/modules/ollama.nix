# Ollama module: NVIDIA GPU-accelerated LLM serving
# Model: qwen3:14b — fits in 16GB VRAM at default quantisation, supports 64k context
# GPU: NVIDIA (10de:2d04) passed through from host via VFIO
# NixOS 26.05 stable
{ config, lib, pkgs, ... }:

{
  # NVIDIA proprietary drivers
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;           # Proprietary driver (better CUDA perf than open kernel module)
    nvidiaSettings = false; # No GUI app needed on this machine
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # hardware.graphics replaces hardware.opengl on NixOS 24.11+
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (desktop.nix already enables xserver)
  services.xserver.videoDrivers = [ "nvidia" ];

  # Ollama with CUDA backend via pkgs.ollama-cuda
  # (services.ollama.acceleration is removed in NixOS 24.11+)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    # Listen on all interfaces so NPM on hades can proxy it
    host = "0.0.0.0";
    port = 11434;

    environmentVariables = {
      # 64k context window
      OLLAMA_NUM_CTX = "65536";
      # Keep model loaded 24h between requests
      OLLAMA_KEEP_ALIVE = "24h";
    };
  };

  # Pull qwen3:14b on first boot (oneshot, idempotent)
  systemd.services.ollama-pull-qwen3 = {
    description = "Pull qwen3:14b model for Ollama";
    after = [ "ollama.service" ];
    wants = [ "ollama.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "ollama-pull-qwen3" ''
        set -e
        # Wait for Ollama API to be ready (up to 60s)
        for i in $(seq 1 30); do
          if ${pkgs.curl}/bin/curl -sf http://localhost:11434/ > /dev/null 2>&1; then
            break
          fi
          sleep 2
        done
        # Pull only if not already present
        if ! ${pkgs.ollama-cuda}/bin/ollama list | grep -q 'qwen3:14b'; then
          echo "Pulling qwen3:14b..."
          ${pkgs.ollama-cuda}/bin/ollama pull qwen3:14b
        else
          echo "qwen3:14b already present, skipping"
        fi
      '';
      User = "ollama";
    };
  };

  environment.systemPackages = with pkgs; [
    pciutils      # lspci for GPU diagnostics
    ollama-cuda   # CLI access for model management
  ];
}
