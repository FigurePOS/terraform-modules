# Figure terraform modules

## aws-dynamodb-table

Creates DynamoDB table.

## aws-ecs-autoscaling

Creates target tracking autoscaling policy for ECS.

## aws-lambda-function

Creates Lambda function.

Lambda zip build uses the repo-installed `fgr` CLI (`@figurepos/platform-tooling`) via `find-fgr.sh` (walks up from `source_dir` for `node_modules/.bin/fgr`). Run `pnpm install` before `terraform apply`. Check: `aws-lambda-function/find-fgr.test.sh`.

## aws-sqs-queue

Creates SQS queue with its DeadLetterQueue.

## aws-s3-bucket

Creates S3 bucket.

## datadog-monitor-http-endpoint

Creates Datadog error-rate and latency monitors for HTTP routes (`fgr.http.server.request.*`).

## datadog-monitor-event-latency

Creates Datadog latency monitor for SQS event consumer handlers (`fgr.message.consumer.duration`).

## datadog-monitor-metric

Creates Datadog metric monitor.

## datadog-monitor-metric-slo

Creates Datadog metric monitor and SLO.

## datadog-sqs

Creates Datadog metric monitors for number of messages in SQS queue and its DLQ.

## ecs-service

Creates ECS Fargate service and load balancer.
Creates Datadog monitors for CPU and Memory utilization of ECS Service.

## grafana-dashboard-service

Grafana service dashboard (CloudWatch `aws.*` + Axiom `fgr.*` / event-loop / task count). Same call-site shape as `datadog-dashboard-service`. HTTP/event filters use OTEL `resource.name` (`POST /payments/payment/:id`).
