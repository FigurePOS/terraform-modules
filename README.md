# Figure terraform modules

## aws-dynamodb-table

Creates DynamoDB table.

## aws-ecs-autoscaling

Creates target tracking autoscaling policy for ECS.

## aws-ecs-service

Creates ECS Fargate service and load balancer.
Creates CloudWatch alarms for CPU and Memory utilization of ECS Service.

## aws-ecs-task-definition

Creates ECS task definition with execution/task IAM roles.

## aws-lambda-function

Creates Lambda function.

Lambda zip build uses the repo-installed `fgr` CLI (`@figurepos/platform-tooling`) via `find-fgr.sh` (walks up from `source_dir` for `node_modules/.bin/fgr`). Run `pnpm install` before `terraform apply`. Check: `aws-lambda-function/find-fgr.test.sh`.

## aws-s3-bucket

Creates S3 bucket.

## aws-sqs-queue

Creates SQS queue with its DeadLetterQueue.

CloudWatch alarms cover the initial DLQ Slack alert (and increasing-rate paging). Grafana sends the 24h "still has messages" reminder (`destination=slack-platform-warnings`, `repeat=24h`); Slack re-notify interval is the monitoring notification policy in `infrastructure/aws/monitoring`. Requires the Grafana provider (`url` / `auth` minted by `fgr tf`).

## axiom-monitor-event-latency

Axiom-native twin of `grafana-alert-event-latency`. Same MPL on `fgr.message.consumer.duration`. Slack via `/axiom/platform_warnings_notifier_id`.

## axiom-monitor-http-client

Axiom-native twin of `grafana-alert-http-client`. Same MPL on `fgr.http.client.request`. Slack via `/axiom/platform_warnings_notifier_id`.

## axiom-monitor-http-endpoint

Axiom-native twin of `grafana-alert-http-endpoint`. Same MPL on `fgr.http.server.request.*`. Slack via `/axiom/platform_warnings_notifier_id`.

## axiom-monitor-ratio

Axiom-native twin of `grafana-alert-ratio`. Same MPL ratio query. Slack via `/axiom/platform_warnings_notifier_id`.

## axiom-monitor-redis

Axiom threshold monitors for ElastiCache memory and CPU.

## datadog-dashboard-service

Creates Datadog service dashboard.

## datadog-monitor-event-latency

Creates Datadog latency monitor for SQS event consumer handlers (`fgr.message.consumer.duration`).

## datadog-monitor-http-endpoint

Creates Datadog error-rate and latency monitors for HTTP routes (`fgr.http.server.request.*`).

## datadog-monitor-metric

Creates Datadog metric monitor.

## datadog-monitor-metric-slo

Creates Datadog metric monitor and SLO.

## grafana-alert-event-latency

Grafana latency alert rule for SQS consumer events (`fgr.message.consumer.duration`). Same required inputs as `datadog-monitor-event-latency`. OTEL `resource.name` is the event name as-is (`OrderPlaced`). Slack is routed by `labels.env` in `infrastructure/aws/monitoring`.

## grafana-alert-http-client

Grafana error-rate and latency alert rules for outbound HTTP client metrics (`fgr.http.client.request`). Slack is routed by `labels.env` in `infrastructure/aws/monitoring`.

## grafana-alert-http-endpoint

Grafana error-rate and latency alert rules for HTTP routes (`fgr.http.server.request.*`). Same required inputs as `datadog-monitor-http-endpoint`. Slack is routed by `labels.env` in `infrastructure/aws/monitoring` (`#platform-warnings` / `#platform-warnings-dev`).

## grafana-alert-ratio

Grafana alert for `100 * numerator / denominator` (e.g. delivery provider error rates). Slack is routed by `labels.env` in `infrastructure/aws/monitoring`.

## grafana-dashboard-service

Grafana service dashboard (CloudWatch `aws.*` + Axiom `fgr.*` / event-loop / task count). Same call-site shape as `datadog-dashboard-service`. HTTP/event filters use OTEL `resource.name` (`POST /payments/payment/:id`).
