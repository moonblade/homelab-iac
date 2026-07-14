# Hermes Agent module: NousResearch hermes-agent with Ollama (Luna GPU)
# Docs: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
{ config, lib, pkgs, ... }:

{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    settings = {
      model = {
        # Ollama on Luna via NPM reverse proxy (OpenAI-compatible)
        base_url = "http://ollama.moonblade.work/v1";
        default  = "qwen3:14b";
        api_mode = "chat_completions";
      };

      auxiliary = {
        # Use the smaller/faster model for side tasks (compression, title gen, etc.)
        compression.model    = "qwen3.5:9b";
        title_generation.model = "qwen3.5:9b";
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
    };
  };
}
