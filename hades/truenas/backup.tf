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

  also_include_naming_schema = ["auto-%Y-%m-%d_%H-%M"]

  schedule = jsonencode({
    minute = "30"
    hour   = "2"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

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

resource "truenas_pool_snapshottask" "kestra_daily" {
  dataset        = "primary/root/storage/kestra"
  recursive      = true
  enabled        = true
  lifetime_value = 14
  lifetime_unit  = "DAY"
  naming_schema  = "auto-%Y-%m-%d_%H-%M"

  schedule = jsonencode({
    minute = "0"
    hour   = "4"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  depends_on = [truenas_pool_dataset.primary_root_storage_kestra]
}

resource "truenas_replication" "kestra_to_secondary" {
  name            = "kestra-to-secondary"
  direction       = "PUSH"
  transport       = "LOCAL"
  source_datasets = ["primary/root/storage/kestra"]
  target_dataset  = "secondary/kestra-backup"
  recursive       = true
  auto            = true

  also_include_naming_schema = ["auto-%Y-%m-%d_%H-%M"]

  schedule = jsonencode({
    minute = "30"
    hour   = "4"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  retention_policy = "CUSTOM"
  lifetime_value   = 30
  lifetime_unit    = "DAY"

  readonly   = "SET"
  properties = true
  compressed = true

  depends_on = [
    truenas_pool_dataset.secondary_kestra_backup,
    truenas_pool_snapshottask.kestra_daily
  ]
}

# Authentik daily snapshots (at 3 AM, staggered from config at 2 AM)
resource "truenas_pool_snapshottask" "authentik_daily" {
  dataset        = "primary/root/storage/authentik"
  recursive      = true
  enabled        = true
  lifetime_value = 14
  lifetime_unit  = "DAY"
  naming_schema  = "auto-%Y-%m-%d_%H-%M"

  schedule = jsonencode({
    minute = "0"
    hour   = "3"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  depends_on = [truenas_pool_dataset.primary_root_storage_authentik]
}

# Authentik replication to secondary (at 3:30 AM, after snapshot)
resource "truenas_replication" "authentik_to_secondary" {
  name            = "authentik-to-secondary"
  direction       = "PUSH"
  transport       = "LOCAL"
  source_datasets = ["primary/root/storage/authentik"]
  target_dataset  = "secondary/authentik-backup"
  recursive       = true
  auto            = true

  also_include_naming_schema = ["auto-%Y-%m-%d_%H-%M"]

  schedule = jsonencode({
    minute = "30"
    hour   = "3"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  retention_policy = "CUSTOM"
  lifetime_value   = 30
  lifetime_unit    = "DAY"

  readonly   = "SET"
  properties = true
  compressed = true

  depends_on = [
    truenas_pool_dataset.secondary_authentik_backup,
    truenas_pool_snapshottask.authentik_daily
  ]
}
