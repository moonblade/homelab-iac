# Ollama module: NVIDIA GPU-accelerated LLM serving
# Models: qwen3:14b (9.3GB), qwen3.8:27b (~17GB, may use up to 1GB RAM overflow)
# GPU: NVIDIA RTX 5060 Ti (10de:2d04) passed through from host via VFIO, 16GB VRAM
# ollama-cuda overridden from nixpkgs-unstable (0.32.x) to support qwen3.8:27b
# NixOS 26.05 stable
{ config, lib, pkgs, ... }:

{
  # NVIDIA proprietary drivers
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;            # RTX 5060 Ti (Blackwell/GB206) requires open kernel modules
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

  # Ollama with CUDA backend.
  # ollama-cuda builds from source (~40min) since it's not in the binary cache for 26.05.
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

  # Pull models on first boot (oneshot, idempotent)
  systemd.services.ollama-pull-models = {
    description = "Pull qwen3:14b and qwen3.8:27b models for Ollama";
    after = [ "ollama.service" ];
    wants = [ "ollama.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # qwen3.8:27b is ~17GB — allow plenty of time
      TimeoutStartSec = "3600";
      ExecStart = pkgs.writeShellScript "ollama-pull-models" ''
        set -e
        export HOME=/var/lib/ollama
        export OLLAMA_HOST=http://localhost:11434
        # Wait for Ollama API to be ready (up to 60s)
        for i in $(seq 1 30); do
          if ${pkgs.curl}/bin/curl -sf http://localhost:11434/ > /dev/null 2>&1; then
            break
          fi
          sleep 2
        done
        # Pull qwen3:14b if not already present
        if ! ${pkgs.ollama-cuda}/bin/ollama list | grep -q 'qwen3:14b'; then
          echo "Pulling qwen3:14b..."
          ${pkgs.ollama-cuda}/bin/ollama pull qwen3:14b
        else
          echo "qwen3:14b already present, skipping"
        fi
        # Pull qwen3.8:27b if not already present
        if ! ${pkgs.ollama-cuda}/bin/ollama list | grep -q 'qwen3.8:27b'; then
          echo "Pulling qwen3.8:27b..."
          ${pkgs.ollama-cuda}/bin/ollama pull qwen3.8:27b
        else
          echo "qwen3.8:27b already present, skipping"
        fi
      '';
      User = "ollama";
      Environment = "HOME=/var/lib/ollama OLLAMA_HOST=http://localhost:11434";
    };
  };

  environment.systemPackages = with pkgs; [
    pciutils     # lspci for GPU diagnostics
    ollama-cuda  # CLI access for model management
  ];
}
