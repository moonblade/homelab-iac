# Hermes Agent module: NousResearch hermes-agent with Ollama (Luna GPU)
# Docs: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
{ config, lib, pkgs, ... }:

{
  # Add moonblade to the hermes group so the CLI can read /var/lib/hermes/.hermes/
  users.users.moonblade.extraGroups = [ "hermes" ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    settings = {
      model = {
        # Ollama running locally on Luna (direct, no proxy hop)
        base_url = "http://localhost:11434/v1";
        default  = "gemma4:latest";
        api_mode = "chat_completions";
      };

      auxiliary = {
        # Use the smaller/faster model for side tasks (compression, title gen, etc.)
        compression.model    = "gemma4:latest";
        title_generation.model = "gemma4:latest";
      };

      # 64K context (Ollama is configured with OLLAMA_NUM_CTX=65536 on Luna)
      model_context_length = 65536;

      terminal = {
        backend = "local";
        timeout = 180;
      };

      memory = {
        memory_enabled       = true;
        user_profile_enabled = true;
      };

      # Basic auth for dashboard when bound to 0.0.0.0 (required by hermes security policy)
      dashboard.basic_auth = {
        username      = "moonblade";
        password_hash = "scrypt$16384$8$1$5havU7CNxWDKQhC4cXLzjw==$wquAerGhFHqdeBe+d57x+aY8Xb6dQ1kkdv+/sand5Zc=";
      };
    };
  };

  # Hermes web dashboard — runs on port 9119, proxied via NPM
  # Docs: hermes dashboard --no-open --port 9119
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Web Dashboard";
    after       = [ "hermes-agent.service" "network.target" ];
    wants       = [ "hermes-agent.service" ];
    wantedBy    = [ "multi-user.target" ];
    environment = {
      HERMES_HOME = "/var/lib/hermes/.hermes";
    };
    serviceConfig = {
      Type        = "simple";
      User        = "moonblade";
      Group       = "hermes";
      Restart     = "always";
      RestartSec  = 10;
      ExecStart   = "/run/current-system/sw/bin/hermes dashboard --no-open --port 9119 --host 0.0.0.0";
      # Note: basic_auth must be set in hermes settings above for 0.0.0.0 binding to be allowed
    };
  };
}
