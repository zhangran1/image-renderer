# Google Cloud Redis Memorystore Module

This module allows managing a Google Cloud Redis Memorystore instance along with its necessary private service connections.

<!-- BEGIN TOC -->
- [Basic Usage](#basic-usage)
- [Variables](#variables)
<!-- END TOC -->

## Basic Usage

```hcl
module "redis_cache" {
  source                  = "./modules/custom/redis-memorystore"
  name                    = "my-private-cache"
  tier                    = "STANDARD_HA"
  memory_size_gb          = 1
  location_id             = "us-central1-a"
  alternative_location_id = "us-central1-f"
  network                 = "projects/my-project/global/networks/my-network"
  redis_version           = "REDIS_7_2"
  display_name            = "My Redis Instance"
  service_range_name      = "redis-address-range"
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L18) | The ID of the instance or a fully qualified identifier for the instance. | `string` | ✓ | |
| [location_id](variables.tf#L33) | The zone where the instance will be provisioned. | `string` | ✓ | |
| [network](variables.tf#L44) | The fully qualified URL of the reserved IP range for peering. | `string` | ✓ | |
| [tier](variables.tf#L23) | The service tier of the instance. Must be one of these values: BASIC, STANDARD_HA | `string` | | `"STANDARD_HA"` |
| [memory_size_gb](variables.tf#L29) | Redis memory size in GiB. | `number` | | `1` |
| [alternative_location_id](variables.tf#L38) | The alternative zone where the instance will be provisioned. | `string` | | `null` |
| [redis_version](variables.tf#L49) | The version of Redis software. | `string` | | `"REDIS_7_2"` |
| [display_name](variables.tf#L55) | An arbitrary and optional user-provided name for the instance. | `string` | | `null` |
| [service_range_name](variables.tf#L61) | Name for the public compute global address resource for private service connection. | `string` | | `"redis-address"` |
| [prevent_destroy](variables.tf#L67) | Set to true to prevent destruction of the Redis instance. | `bool` | | `false` |

<!-- END TFDOC -->
