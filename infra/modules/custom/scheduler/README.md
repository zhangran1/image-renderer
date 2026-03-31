# Google Cloud Scheduler Module

This module allows managing a Cloud Scheduler Job for HTTP targets.

<!-- BEGIN TOC -->
- [Basic Usage](#basic-usage)
- [Variables](#variables)
<!-- END TOC -->

## Basic Usage

```hcl
module "scheduler_job" {
  source                = "./modules/tf-registry/scheduler"
  project_id            = "my-project-id"
  region                = "us-central1"
  name                  = "my-scheduler-job"
  schedule              = "*/5 * * * *"
  uri                   = "https://example.com/api"
  service_account_email = "my-sa@my-project-id.iam.gserviceaccount.com"
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L25) | The name of the Cloud Scheduler job. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L15) | Project ID where the Cloud Scheduler job will be deployed. | <code>string</code> | ✓ |  |
| [region](variables.tf#L20) | Region where the Cloud Scheduler job will be deployed. | <code>string</code> | ✓ |  |
| [schedule](variables.tf#L36) | The schedule in cron format. | <code>string</code> | ✓ |  |
| [service_account_email](variables.tf#L82) | The service account email to use for OIDC authentication. | <code>string</code> | ✓ |  |
| [uri](variables.tf#L66) | The full URI to send the request to. | <code>string</code> | ✓ |  |
| [attempt_deadline](variables.tf#L47) | The deadline for job attempts. | <code>string</code> |  | <code>&#34;320s&#34;</code> |
| [body](variables.tf#L71) | The HTTP request body. It will be base64 encoded automatically. | <code>string</code> |  | <code>null</code> |
| [description](variables.tf#L30) | The description of the Cloud Scheduler job. | <code>string</code> |  | <code>null</code> |
| [headers](variables.tf#L77) | HTTP headers to send with the request. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [http_method](variables.tf#L60) | The HTTP method to use for the request. | <code>string</code> |  | <code>&#34;POST&#34;</code> |
| [retry_count](variables.tf#L53) | The number of retries. | <code>number</code> |  | <code>1</code> |
| [time_zone](variables.tf#L41) | The timezone for the schedule. | <code>string</code> |  | <code>&#34;Etc/UTC&#34;</code> |

<!-- END TFDOC -->
