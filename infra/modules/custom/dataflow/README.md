# Google Cloud Dataflow Module

This module allows managing a Dataflow Flex Template Job.

<!-- BEGIN TOC -->
- [Basic Usage](#basic-usage)
- [Variables](#variables)
<!-- END TOC -->

## Basic Usage

```hcl
module "dataflow_job" {
  source                       = "./modules/tf-registry/dataflow"
  project_id                   = "my-project-id"
  region                       = "us-central1"
  gcs_template_path            = "gs://my-bucket/templates/FlexTemplate"
  big_data_job_subscription_id = "projects/my-project/subscriptions/my-sub-id"
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [big_data_job_subscription_id](variables.tf#L31) | The Pub/Sub subscription ID to be passed as an input parameter. | <code>string</code> | ✓ |  |
| [gcs_template_path](variables.tf#L26) | The GCS path to the Dataflow Flex Template. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L16) | The project ID where the Dataflow job will be deployed. | <code>string</code> | ✓ |  |
| [region](variables.tf#L21) | The region to deploy the Dataflow job. | <code>string</code> | ✓ |  |
| [labels](variables.tf#L36) | Labels to be attached to the Dataflow job. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |

<!-- END TFDOC -->
