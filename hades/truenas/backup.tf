resource "truenas_pool_snapshottask" "config_daily" {
  dataset        = "primary/root/config"
  recursive      = true
  enabled        = true
  lifetime_value = 14
  lifetime_unit  = "DAY"
  naming_schema  = "auto-%Y-%m-%d_%H-%M"

  schedule = jsonencode({
    minute = "0"
    hour   = "2"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  depends_on = [truenas_pool_dataset.primary_root_config]
}

resource "truenas_replication" "config_to_secondary" {
  name            = "config-to-secondary"
  direction       = "PUSH"
  transport       = "LOCAL"
  source_datasets = ["primary/root/config"]
  target_dataset  = "secondary/config-backup"
  recursive       = true
  auto            = true

  periodic_snapshot_tasks = [truenas_pool_snapshottask.config_daily.id]

  retention_policy = "CUSTOM"
  lifetime_value   = 30
  lifetime_unit    = "DAY"

  readonly   = "SET"
  properties = true
  compressed = true

  depends_on = [
    truenas_pool_dataset.secondary_config_backup,
    truenas_pool_snapshottask.config_daily
  ]
}
