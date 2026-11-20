# basic-memory-sync module
# Syncs ~/basic-memory/ ↔ /mnt/nas/basic-memory/ every 5 minutes via rsync,
# then runs qmd update to keep the search index current.
# qmd is installed via npm (hermes/node) at ~/.local/lib/node_modules/@tobilu/qmd/bin/qmd
{ config, lib, pkgs, ... }:

let
  syncScript = pkgs.writeShellScript "sync-basic-memory" ''
    LOCAL="$HOME/basic-memory/"
    REMOTE=/mnt/nas/basic-memory/
    LOGFILE="$HOME/.local/log/sync-basic-memory.log"
    LOCKFILE=/tmp/sync-basic-memory.lock

    mkdir -p "$(dirname "$LOGFILE")"

    # Trigger automount
    ls /mnt/nas/ >/dev/null 2>&1

    if [ ! -d "$REMOTE" ]; then
      echo "$(date): /mnt/nas/basic-memory not accessible, skipping." >> "$LOGFILE"
      exit 0
    fi

    # PID-based lock — stale locks from kill-9 are cleared automatically
    if [ -e "$LOCKFILE" ]; then
      OLD_PID=$(cat "$LOCKFILE" 2>/dev/null)
      if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "$(date): Already running (pid $OLD_PID), skipping." >> "$LOGFILE"
        exit 0
      else
        echo "$(date): Clearing stale lock (pid $OLD_PID)." >> "$LOGFILE"
        rm -f "$LOCKFILE"
      fi
    fi
    echo $$ > "$LOCKFILE"
    trap 'rm -f "$LOCKFILE"' EXIT

    echo "$(date): ── Starting basic-memory sync ──" >> "$LOGFILE"

    # Local → NAS
    echo "$(date): Local → NAS" >> "$LOGFILE"
    ${pkgs.rsync}/bin/rsync -rlvuh --checksum --times --no-perms --no-group \
      --exclude='*.tmp' "$LOCAL" "$REMOTE" >> "$LOGFILE" 2>&1

    # NAS → Local
    echo "$(date): NAS → Local" >> "$LOGFILE"
    ${pkgs.rsync}/bin/rsync -rlvuh --checksum --times --no-perms --no-group \
      --exclude='*.tmp' "$REMOTE" "$LOCAL" >> "$LOGFILE" 2>&1

    echo "$(date): ── Sync complete ──" >> "$LOGFILE"

    # Update qmd index after sync
    QMD="$HOME/.local/lib/node_modules/@tobilu/qmd/bin/qmd"
    if [ -x "$QMD" ]; then
      echo "$(date): Updating qmd index..." >> "$LOGFILE"
      node "$QMD" update -c basic-memory >> "$LOGFILE" 2>&1
      echo "$(date): qmd update done." >> "$LOGFILE"
    fi
  '';
in
{
  # Deploy sync script to moonblade's local bin
  system.activationScripts.basicMemorySyncScript = ''
    mkdir -p /home/moonblade/.local/bin
    cp ${syncScript} /home/moonblade/.local/bin/sync-basic-memory.sh
    chmod +x /home/moonblade/.local/bin/sync-basic-memory.sh
    chown moonblade:users /home/moonblade/.local/bin/sync-basic-memory.sh
  '';

  # User systemd service + timer (runs as moonblade)
  systemd.user.services.basic-memory-sync = {
    description = "Sync basic-memory to NAS";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.rsync "/home/moonblade/.local" ];
    environment = {
      PATH = "/home/moonblade/.local/bin:${pkgs.rsync}/bin:${pkgs.bash}/bin:/run/current-system/sw/bin:/usr/bin:/bin";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/moonblade/.local/bin/sync-basic-memory.sh";
    };
  };

  systemd.user.timers.basic-memory-sync = {
    description = "basic-memory NAS sync timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "60";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
}
