# CloudWatch Alarms for SQS Queues

This module adds CloudWatch alarms for faster, low-latency alerting (≈5–10 minutes) compared to Datadog delays.

## Features

The CloudWatch alarms provide monitoring for:

1. **Main Queue Message Count**
   - Warning threshold alarm
   - Critical threshold alarm
2. **Dead Letter Queue Message Count**
   - Critical threshold alarm when any messages appear
3. **Dead Letter Queue Increasing Messages**
   - Alarm when messages are being added to DLQ (rate of increase)
   - Routed to Slack by default. Rootly paging can be enabled after testing (see note below).
4. Message Age alarm has been removed from this module

## Usage

### Basic Configuration

```hcl
module "my_sqs_queue" {
  source = "./aws-sqs-queue"
  
  # Standard SQS configuration
  service_name = "my-service"
  queue_name   = "my-queue"
  env          = "production"
  
  # Enable CloudWatch alarms
  enable_cloudwatch_alarms = true

  # SNS topics are auto-resolved by name via data sources
  # - cloudwatch-sqs-alarms-to-slack (Slack via AWS Chatbot)
  # - alerts-to-rootly (Rootly via Lambda) — optional, currently disabled in code pending testing

  # CloudWatch alarm thresholds
  queue_messages_warning  = 25
  queue_messages_critical = 100
  dlq_messages_critical   = 1  # Any message in DLQ is critical
  
  # Rate of increase threshold for DLQ
  dlq_messages_increase_threshold = 1  # messages per second
  
  # Tags applied to all AWS resources in this module (SQS + alarms)
  tags = {
    Team        = "platform"
    Environment = "production"
  }
}
```

### SNS Topic for Notifications

```hcl
# Example SNS topic for CloudWatch notifications
resource "aws_sns_topic" "sqs_alerts" {
  name = "sqs-cloudwatch-alerts"
  
  tags = {
    Purpose = "SQS CloudWatch alarms"
  }
}

# Subscribe to notifications (email, Slack, PagerDuty, etc.)
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.sqs_alerts.arn
  protocol  = "email"
  endpoint  = "alerts@yourcompany.com"
}
```

### Built-in data sources for routing

The module looks up these SNS topics by name and uses them for routing:

- `cloudwatch-sqs-alarms-to-slack` (Slack via AWS Chatbot)
- `alerts-to-rootly` (Rootly OnCall via Lambda)

If they do not exist in the account/region, create them or update the module to reference your naming.

### Hybrid Approach (Datadog + CloudWatch)

For testing or gradual migration, you can run both systems in parallel:

```hcl
module "my_sqs_queue" {
  source = "./aws-sqs-queue"
  
  # Standard configuration
  service_name = "my-service"
  queue_name   = "my-queue"
  env          = "production"
  
  # Keep Datadog monitoring
  datadog_tags = ["team:platform", "env:production"]
  
  # Add CloudWatch monitoring
  enable_cloudwatch_alarms    = true
  
  # Same thresholds for both systems
  queue_messages_warning  = 25
  queue_messages_critical = 100
  dlq_messages_critical   = 1
}
```

## Alarm Details

### Message Count Alarms
- **Period**: 1 minute (configurable via `cloudwatch_period_seconds`)
- **Evaluation**: 1 period by default (configurable via `cloudwatch_evaluation_periods`)
- **Statistic**: Average
- **Missing Data**: Not breaching

### Dead Letter Queue Rate Alarm
- Uses CloudWatch metric math with `RATE()` function
- Detects increasing trend in DLQ messages
- More sensitive than absolute count thresholds
- Requires two consecutive 1-minute breaches (datapoints_to_alarm=2, evaluation_periods≥2)
- By default routes to Slack only; Rootly can be enabled post‑testing

### Message Age Alarm
Removed from this module. If needed, implement it in your root module.

## Cost Considerations

- CloudWatch alarms cost $0.10 per alarm per month
- Each SQS queue with full monitoring = ~4-5 alarms = ~$0.40-0.50/month
- SNS notifications have additional costs per message

## Migration Strategy

1. **Phase 1**: Enable CloudWatch alarms alongside Datadog (current setup)
2. **Phase 2**: Test CloudWatch alerting in production
3. **Phase 3**: Gradually reduce Datadog monitoring scope
4. **Phase 4**: Disable Datadog SQS monitors when confident

## Outputs

The module provides CloudWatch alarm ARNs as outputs:

```hcl
output "sqs_warning_alarm" {
  value = module.my_sqs_queue.cloudwatch_alarm_sqs_messages_warning_arn
}

output "sqs_critical_alarm" {
  value = module.my_sqs_queue.cloudwatch_alarm_sqs_messages_critical_arn
}
```

## Benefits over Datadog

1. **Faster Alerting**: 5-10 minutes vs 15-20 minutes delay
2. **Cost Efficiency**: $0.10/alarm/month vs Datadog metric ingestion costs
3. **Native Integration**: Direct AWS service integration
4. **Reliability**: No external service dependencies for alerting
