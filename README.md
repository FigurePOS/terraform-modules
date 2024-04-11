# Figure terraform modules

## ecs-autoscaling-cpu

Creates autoscaling policy for ECS task based on CPU utilization.


## ecs-service

Creates ECS Fargate service and load balancer. 
Creates Datadog monitors for CPU and Memory utilization of ECS Service.

## terraform-datadog-metric

Creates Datadog metric monitor.


## terraform-datadog-metric-slo

Creates Datadog metric monitor and SLO.

## terraform-datadog-monitor-event-handler

Creates Datadog latency monitor for event handlers.


## terraform-datadog-monitor-express-endpoint

Creates Datadog latency and error rate monitor for Rest API endpoints.


## terraform-datadog-monitor-graphql-endpoint

Creates Datadog latency and error rate monitor for GraphQL endpoints.


## terraform-datadog-sqs

Creates Datadog metric monitors for number of messages in SQS queue and its DLQ.
