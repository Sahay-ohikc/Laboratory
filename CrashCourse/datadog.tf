#resource "datadog_integration_aws" "in_eks" {
#  account_id  = "093157296769"
#  role_name   = "DatadogAWSIntegrationRole"
#  filter_tags = ["key:value"]
#  host_tags   = ["key:value", "key2:value2"]
#  account_specific_namespace_rules = {
#    auto_scaling = false
#    opsworks     = false
#  }
#}


resource "datadog_monitor" "cpumonitor" {
  name    = "cpu monitor"
  type    = "metric alert"
  query   = "avg(last_1m):avg:system.cpu.user{*} by {host} > 90"
  message = "{{#is_alert}}CPU Monitor Panic!!!{{/is_alert}}@pagerduty-scalable-miner\n{{#is_warning}}CPU Monitor Alert!{{/is_warning}}@betep@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 90
       warning  = 80
  }
}

resource "datadog_monitor" "memory" {
  name  = "memory"
  type  = "metric alert"
  query = "avg(last_1m):avg:system.mem.used{*} by {host} > 3000000000"
  message = "{{#is_alert}}Memory Monitor Panic!!!{{/is_alert}}@pagerduty-scalable-miner\n{{#is_warning}}Memory Monitor Alert!  {{/is_warning}}@betep@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 3000000000
       warning  = 2600000000
  }
}

resource "datadog_monitor" "disk_usage" {
  name  = "disk usage"
  type  = "metric alert"
  query = "avg(last_1m):max:system.disk.in_use{*} by {host} > 80"
  message = "{{#is_alert}}Disk Monitor Panic!!!{{/is_alert}}@pagerduty-scalable-miner\n{{#is_warning}}Disk Monitor Alert!{{/is_warning}}@betep@mailinator.com"
  notify_audit           = true
  locked                 = false
  timeout_h              = 0
  new_host_delay         = 300
  require_full_window    = false
  notify_no_data         = false
  renotify_interval      = "0"
  escalation_message     = ""
  no_data_timeframe      = null
  include_tags           = true
  thresholds = {
       critical = 80
       warning  = 50
  }
}
