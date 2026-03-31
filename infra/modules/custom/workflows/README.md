# Google Cloud Workflows Module

This module allows managing a Google Cloud Workflow.

<!-- BEGIN TOC -->
- [Basic Usage](#basic-usage)
- [Variables](#variables)
<!-- END TOC -->

## Basic Usage

```hcl
module "my_workflow" {
  source              = "./modules/tf-registry/workflows"
  project_id          = "my-project-id"
  name                = "my-workflow"
  region              = "us-central1"
  description         = "A sample workflow"
  service_account     = "my-service-account@my-project.iam.gserviceaccount.com"
  source_contents     = file("$${path.module}/sample_workflow.yaml")
  deletion_protection = false
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L21) | Name of the Workflow. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L16) | The project ID where the Workflow will be deployed. | <code>string</code> | ✓ |  |
| [region](variables.tf#L26) | Region of the Workflow. | <code>string</code> | ✓ |  |
| [deletion_protection](variables.tf#L43) | Whether to prevent Terraform from destroying the workflow. | <code>bool</code> |  | <code>false</code> |
| [description](variables.tf#L31) | Description of the Workflow. | <code>string</code> |  | <code>null</code> |
| [labels](variables.tf#L49) | Labels to attach to the workflow. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [service_account](variables.tf#L37) | Service account email or ID to be associated with the workflow. | <code>string</code> |  | <code>null</code> |
| [source_contents](variables.tf#L61) | The YAML or JSON execution instructions for the workflow. | <code>string</code> |  | <code>null</code> |
| [tags](variables.tf#L55) | Tags to attach to the workflow. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |

<!-- END TFDOC -->
