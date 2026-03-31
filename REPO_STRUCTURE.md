repo/
├── infra/                      # Infrastructure (Terraform)
│   ├── modules/                # Reusable Terraform modules
│   │   ├── cloud-fabric/       # GCP Cloud Fabric modules
│   │   │   ├── bigquery/
│   │   │   ├── cloud-function-v2/
│   │   │   ├── cloud-run-v2/
│   │   │   ├── compute-mig/
│   │   │   ├── compute-vm/
│   │   │   ├── gcs/
│   │   │   ├── iam-service-account/
│   │   │   ├── pubsub/
│   │   │   ├── secret-manager/
│   │   │   └── spanner-instance/
│   │   ├── custom/             # Custom-built modules
│   │       ├── dataflow/
│   │       ├── redis-memorystore/
│   │       ├── scheduler/
│   │       └── workflows/
│   │   
│   │
│   └── envs/                   # Environment-specific configurations
│       ├── prod/
│       │   ├── backend.tf      # State configuration for Prod
│       │   ├── main.tf
│       │   ├── provider.tf
│       │   └── variables.tf
│       ├── udk-prj-l-b/
│       │   ├── backend.tf
│       │   ├── main.tf
│       │   └── variables.tf
│       └── udk-prj-l-b-newcircus/
│           ├── backend.tf
│           ├── main.tf
│           └── variables.tf
│
├── src/                        # Workflow and Application Code
│   ├── anomaly-detection-workflow/
│   ├── early-detection-workflow/
│   ├── feedback-collection-function/
│   └── utility/                # Utility scripts and tools
│
├── README.md
└── REPO_STRUCTURE.md
