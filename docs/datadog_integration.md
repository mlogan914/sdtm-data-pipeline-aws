# Datadog Integration for AWS Serverless Data Pipeline

- This document outlines how to integrate [Datadog](https://www.datadoghq.com/) with an AWS-based serverless data pipeline project for monitoring, alerting, and observability.
- The project GitHub repo is [HERE](https://github.com/mlogan914/sdtm-data-pipeline-aws)
---

## Project Context

This event-driven pipeline uses:
- AWS services: e.g., Lambda, S3, Glue, Step Functions, ECS (Fargate)
- Terraform
- Logging with CloudWatch

Integrating Datadog provides performance monitoring, error tracking, and real-time alerts for anomalies in the system.

## Datadog Reference Documents:

- [Getting Stated with AWS](https://docs.datadoghq.com/getting_started/integrations/aws/#setup)
- [Setup](https://docs.datadoghq.com/getting_started/integrations/aws/#setup)
- [Datadog Forwarder](https://docs.datadoghq.com/logs/guide/forwarder/?tab=cloudformation)
- [Datadog AWS IAM Policy](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=manual#aws-iam-permissions)
- [Amazon ECS on AWS Fargate](https://docs.datadoghq.com/integrations/ecs_fargate/?tab=webui)

## About AWS Integration

### Default collection methods:

There are two primary methods that the Amazon Web Services integration uses to detect your AWS resources and collect their metrics and logs:
1.	Pulling metrics from AWS into your Datadog account.
    - Using an IAM role for Datadog in your account, Datadog will poll AWS CloudWatch metrics API endpoints every 10 minutes, on average.
2.	Pushing logs from your AWS account to Datadog.

### Other collection methods:
Metric streams and Kineses Firehose Destination:
- If you need to collect *low latency* metrics from AWS, you can configure metric streams, which use Amazon Kinesis Data Firehose to continuously push metrics to your Datadog account with a 3-minute latency.
- You can also send *high-volume* AWS service logs to Datadog using the Datadog Kinesis Firehose Destination.

### The Datadog Agent
The Datadog Agent can be installed on or alongside some AWS resource types, including: 

- EC2 instances (including RDS hosts and EC2 launch types in ECS)
- Containers in ECS Fargate tasks
- Containers in EKS clusters

Datadog recommends installing the Agent wherever possible, in addition to using the Amazon Web Services integration. This combination provides the most comprehensive insight into your AWS infrastructure.

> **NOTE:** Although the Datadog agent is recommended for collecting metrics, logs, and traces from ECS containers, it is not required for my event-driven pipeline. In my case, the containers are short-lived tasks that don’t persist long enough to run an agent continuously. To run the Datadog agent persistently, an ECS replica service would be necessary, which isn’t appropriate for this use case.

However, if you need to set up the Datadog agent in ECS Fargate for long-lived services, you can refer to the example in the appendix [HERE](#example-adding-datadog-agent-to-ecs-fargate-task-definitions).

## Integration Steps

### 1. Set Up a Datadog AWS Integration 

### Manual Setup (For reference)

- Go to [Datadog AWS Integration Configuration Page](https://app.datadoghq.com/account/settings#integrations/amazon-web-services)
- Configure the integration’s settings under the *Automatically using CloudFormation* option
- Select the AWS regions to integrate with.
- Add your Datadog API key.
- On the 'Metrics Collection' tab, enable the services you want to monitor. To view disabled resources, check the 'Disabled' tab. These are based on the current resources in your account.
- Optionally, send logs and other data to Datadog with the [Datadog Forwarder Lambda](https://docs.datadoghq.com/logs/guide/forwarder/?tab=cloudformation)
- Provide read-only IAM role access to Datadog

📝 *I used [this IAM policy](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=manual#aws-iam-permissions) for permissions.*

---

### 2. Enable CloudWatch Logs Forwarding (Optional but Recommended)
- Create a Lambda function using Datadog’s log forwarder blueprint (CloudFormation)
- Set up subscription filters from AWS services (e.g., Lambda, Glue, etc) to this function
- This forwards real-time logs to Datadog

---

### Terraform Setup (Completed)

- See [The AWS Integration with Terraform](https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/)

#### Project Directory Structure
```
├── data
├── docker
│   ├── transform
│   │   ├── dm.py
│   │   ├── dockerfile
│   │   └── requirements.txt
│   └── validate
│       ├── dockerfile
│       └── run_p21.py
├── docs
│   └── datadog_integration.md
├── terraform
│   ├── athena
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── *datadog
│   │   ├── forwarder.tf
│   │   ├── kms.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── roles.tf
│   │   └── variables.tf
│   ├── ecs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── roles.tf
│   │   └── variables.tf
│   ├── glue
│   │   ├── glue_data_quality.py
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── roles.tf
│   │   └── variables.tf
│   ├── lambda
│   │   ├── lambda_function.py
│   │   ├── lambda_function.zip
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── roles.tf
│   ├── main.tf
│   ├── providers.tf
│   ├── s3
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── sns
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── step_functions
│   │   ├── main.tf
│   │   ├── roles.tf
│   │   └── variables.tf
│   ├── terraform.secrets.auto.tfvars
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── vpc
│       ├── main.tf
│       └── outputs.tf
└── terraform.tfstate
```

### Datadog Integration using Terraform
### 1. Add the Datadog provider to the provider configuration in the Datadog module:

> **NOTE:** This is needed because provider source mappings are not inherited from the root module. Without this, Terraform will look for hashicorp/datadog (which doesn’t exist).

```
providers.tf

# =============================================================
# Terraform Configuration
# =============================================================
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}

# =============================================================
# Provider Configuration
# =============================================================

# NOTE: This can also be set via the DD_API_KEY environment variable.
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

```

### 2. Create an AWS integration IAM policy and Role

- To correctly set up the AWS Integration, you must attach the relevant IAM policies to the Datadog AWS Integration IAM Role in your AWS account
- The AWS IAM permissions are currently documented [HERE](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=manual#aws-iam-permissions)

Set up your Terraform configuration file using the example below as a base template. Ensure to update the following parameters before you apply the changes:

- `AWS_PERMISSIONS_LIST`: The IAM policies needed by Datadog AWS integrations. The current list is available in the Datadog AWS integration documentation.

> **NOTE:** Warning messages appear on the AWS integration tile in Datadog if you enable resource collection, but do not have the **AWS Security Audit Policy** attached to your Datadog IAM role.

```
roles.tf

# ================================================================
# Datadog Module - IAM Roles and Policies
# 
# This file defines roles and policies for the Datadog module.
# ===============================================================

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${datadog_integration_aws_account.datadog_integration.auth_config.aws_auth_config_role.external_id}"
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = [<AWS_PERMISSIONS_LIST>]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}

resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogIntegrationRole"
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_security_audit" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

```

### 3. Set up the Datadog Log Forwarder (Lambda)
- An overview of the Datadog Forwarder can be found [HERE](https://docs.datadoghq.com/logs/guide/forwarder/?tab=cloudformation)

- The Datadog Forwarder is an AWS Lambda function that ships logs from AWS to Datadog — in this case, specifically forwarding CloudWatch and S3 logs.

Install the Forwarder using the Terraform resource `aws_cloudformation_stack` as a wrapper on top of the provided CloudFormation template.

Datadog recommends creating separate Terraform configurations:

- Use the first one to store the Datadog API key in the AWS Secrets Manager, and note down the secrets ARN from the output of apply.
- Then, create a configuration for the forwarder and supply the secrets ARN through the DdApiKeySecretArn parameter.
- Finally, create a configuration to set up triggers on the Forwarder.

By separating the configurations of the API key and the forwarder, you do not have to provide the Datadog API key when updating the forwarder. To update or upgrade the forwarder in the future, apply the forwarder configuration again.

KMS Configuration:

```
kms.tf

# =============================================================
# Datadog KMS Resource for API Key Encryption
# =============================================================

resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "datadog_api_key"
  description = "Encrypted Datadog API Key"
}

resource "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key.id
  secret_string = var.datadog_api_key
}

output "datadog_api_key" {
  value = aws_secretsmanager_secret.datadog_api_key.arn
}

```

Forwarder Configuration:

> **NOTE:** Subscription filters are not created automatically by the DatadogForwarder. Create them directly on a Log Group.

```
forwarder.tf

# =============================================================
# Datadog Lambda Forwarder
#
# Use the Datadog Forwarder to ship logs from S3 and CloudWatch. 
# ============================================================

resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters   = {

    DdApiKeySecretArn  = aws_secretsmanager_secret.datadog_api_key.arn,
    DdApiKey  = var.datadog_api_key
    DdSite             = "datadoghq.com",
    FunctionName       = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

# Added Log Group Subscription Filters to Datadog Forwarder
resource "aws_cloudwatch_log_subscription_filter" "datadog_lambda_process_raw_subscription" {
  name            = "datadog-process-raw-subscription"
  log_group_name  = "/aws/lambda/process_raw_data"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

// Excluding Step Functions
# resource "aws_cloudwatch_log_subscription_filter" "datadog_stepfunctions_subscription" {
#   name            = "datadog-stepfunctions-subscription"
#   log_group_name  = "/aws/stepfunctions/state-machine-5201201"
#   filter_pattern  = ""
#   destination_arn = var.datadog_forwarder_arn
# }

resource "aws_cloudwatch_log_subscription_filter" "datadog_crawler_subscription" {
  name            = "datadog-crawler-subscription"
  log_group_name  = "/aws-glue/crawlers"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_glue_subscription" {
  name            = "datadog-glue-subscription"
  log_group_name  = "/aws-glue/jobs/output"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_ecs_transform_subscription" {
  name            = "datadog-ecs-transform-subscription"
  log_group_name  = "/ecs/sdtm-task-5201201-transform"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_ecs_validate_subscription" {
  name            = "datadog-ecs-validate-subscription"
  log_group_name  = "/ecs/sdtm-task-5201201-validate"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

```

### Copy the Datadog Forwarder ARN
After running `terraform apply`, copy the forwarder ARN from the terminal output. You’ll need to provide this ARN later when configuring the AWS integration for Datadog.

### Choosing Logs to Forward to Datadog

Be selective with the logs you choose to forward to Datadog. Sending everything can result in unnecessary noise and increased costs.

Focus on forwarding logs from key parts of the pipeline that involve:
- Data transformation
- Validation
- Errors or exceptions
- Alerts or anomalies

>**NOTE:** Be cautious with Step Functions logs — while helpful for debugging complex workflows, they can be extremely verbose and costly to store and analyze unless you apply proper filters.

#### Recommended Log Sources to Forward (For this project)
- Lambda logs – Especially useful for catching runtime errors and exception traces.
- Glue jobs & crawlers – Often include information about schema detection, data extraction, and transformation results.
- ECS task logs – Valuable for tasks that handle data transformation or validation.

### 4. Set up AWS Integration
Set up your Terraform configuration file using the example below as a base template. Ensure to update the following parameters before you apply the changes:

- `AWS_ACCOUNT_ID`: Your AWS account ID.
- `lambda_forwarder` (Block) nested under `logs_config` is required. 

See the [Terraform Registry](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account) for further example usage and the full list of optional parameters, as well as additional Datadog resources.

### Supply the Datadog Forwarder ARN
When deploying the forwarder Lambda function, supply the Datadog Forwarder ARN you copied from the previous step after running `terraform apply`:

Datadog Forwarder Lambda ARN Example:
```
...
logs_config {
    lambda_forwarder {
      lambdas = ["arn:aws:lambda:us-east-1:123456789012:function:my-lambda"]
      sources = ["s3"]
    }
...
```

AWS Integration Configuration:

```
main.tf

# ==================================================
#   Datadog AWS Integration
# ==================================================
#
#   NOTE: If using prebuilt Lambda functions, deploy them first, 
#         then provide the function ARN in root module.
# ==================================================

resource "datadog_integration_aws_account" "datadog_integration" {
  account_tags   = []
  aws_account_id = "${var.aws_account_id}"
  aws_partition  = "aws"
  aws_regions {
    include_all = true
  }
  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }
    resources_config {
    cloud_security_posture_management_collection = true
    extended_collection                          = true
  }
  traces_config {
    xray_services {
    }
  }
    logs_config {
        lambda_forwarder {
            lambdas = ["${var.datadog_forwarder_arn}"] 
            sources =["s3"]
        }
  }
  metrics_config {
    namespace_filters {
    }
  }
}

```

### Conclusion
With this integration, the AWS serverless data pipeline is now equipped for comprehensive observability using Datadog. Logs, metrics, and traces from key AWS services can be monitored in real time, enabling proactive issue detection, performance insights, and reliable alerting.

For further customization (e.g., dashboards, monitors, or custom metrics), refer to the Datadog documentation or explore additional Terraform modules within your stack.

---

### Appendix

#### Example: Adding Datadog Agent to ECS Fargate Task Definitions
This example demonstrates how to set up the Datadog agent container alongside the transformation and validation containers in ECS Fargate. The Datadog agent container will run as a sidecar in the same task definition to collect detailed ECS task-level metrics, logs, and traces.

> **NOTE:**: This would deploy the Datadog agent as a *persistent service* in ECS, suitable for long-lived services *but not* needed in an event-driven pipeline like mine.

ECS module: main.tf

```
# =============================================================
# ECR/ECS Configuration
# This provisions ECS resources for running transformation and compliance scripts.
# =============================================================

# ---------------------------------------
# Create an ECR Repository
# ---------------------------------------
resource "aws_ecr_repository" "ecr_repo_transform" {
  name = "ecr-repo-520120-transform"
}

resource "aws_ecr_repository" "ecr_repo_validate" {
  name = "ecr-repo-520120-validate"
}

# ---------------------------------------
# Create an ECS cluster
# ---------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-5201201"
}

# ---------------------------------------
# Create CloudWatch Log Groups
# ---------------------------------------
resource "aws_cloudwatch_log_group" "ecs_log_group_transform" {
  name = "/ecs/sdtm-task-5201201-transform"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs_log_group_validate" {
  name = "/ecs/sdtm-task-5201201-validate"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs_log_group_datadog" {
  name              = "/ecs/datadog-agent"
  retention_in_days = 30
}

# ---------------------------------------
# ECS Task Definition(s)
# This defines the transform and validation containers.
# ---------------------------------------
resource "aws_ecs_task_definition" "ecs_task_transform" {
  family                   = "sdtm-task-transform"
  container_definitions    = jsonencode([
    # Transform Container
    {
      name      = "sdtm-container-5201201-transform",
      image     = "${aws_ecr_repository.ecr_repo_transform.repository_url}:latest",
      memory    = 512,
      cpu       = 256,
      essential = true,
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group_transform.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    # Datadog Agent Container
    {
      name      = "datadog-agent",
      image     = "public.ecr.aws/datadog/agent:latest",
      memory    = 256,
      cpu       = 128,
      essential = true,
      environment = [
        {
          name  = "DD_API_KEY",
          value = var.datadog_api_key # Pass API key here
        },
        {
          name  = "ECS_FARGATE",
          value = "true"
        },
        {
          name  = "DD_SITE",
          value = "datadoghq.com"
        },
        {
          "name": "DD_ECS_TASK_COLLECTION_ENABLED", # Ensure that the Datadog Agent is actively collecting detailed ECS task-level metrics, not just container or cluster-level metrics.
          "value": "true"
        },
        {
        "name": "DD_LOGS_ENABLED",
        "value": "true"
        },
        {
        "name": "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL",
        "value": "true"
        }

      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${aws_cloudwatch_log_group.ecs_log_group_datadog.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "datadog"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"
  cpu                      = "512"
}

resource "aws_ecs_task_definition" "ecs_task_validate" {
  family                   = "sdtm-task-validate"
  container_definitions    = jsonencode([
    # Validation Container
    {
      name      = "sdtm-container-5201201-validate",
      image     = "${aws_ecr_repository.ecr_repo_validate.repository_url}:latest",
      memory    = 512,
      cpu       = 256,
      essential = true,
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group_validate.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    # Datadog Agent Container
    {
      name      = "datadog-agent",
      image     = "public.ecr.aws/datadog/agent:latest",
      memory    = 256,
      cpu       = 128,
      essential = true,
      environment = [
        {
          name  = "DD_API_KEY",
          value = var.datadog_api_key  # Pass API key here
        },
        {
          name  = "ECS_FARGATE",
          value = "true"
        },
        {
          name  = "DD_SITE",
          value = "datadoghq.com"
        },
        {
          "name": "DD_ECS_TASK_COLLECTION_ENABLED", # Ensure that the Datadog Agent is actively collecting detailed ECS task-level metrics, not just container or cluster-level metrics.
          "value": "true"
        },
        {
        "name": "DD_LOGS_ENABLED",
        "value": "true"
        },
        {
        "name": "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL",
        "value": "true"
        }

      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${aws_cloudwatch_log_group.ecs_log_group_datadog.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "datadog"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"
  cpu                      = "512"
}


# ---------------------------------------
# Create a Security Group
# ---------------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-5201201"
  description = "Allow inbound traffic to ECS containers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust if you want specific IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Needed for ECR, S3, Logs, etc.
  }
}

```

This configuration adds the Datadog agent container to the ECS task definition alongside the transformation container, allowing the agent to collect detailed metrics and logs. It uses AWS CloudWatch Logs for logging and requires the Datadog API key to be provided as an environment variable.

### How to Enable Replica Service (if needed)
If you need the Datadog agent to persist across ECS Fargate tasks and have it continuously monitor your services, you would need to run it as part of a replica service in ECS:

```
# Example of ECS Service for Datadog Agent Replica
resource "aws_ecs_service" "datadog_agent_service" {
  name            = "datadog-agent-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_transform.arn
  desired_count   = 1  # Keep one replica of the agent running
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
  }
}

```