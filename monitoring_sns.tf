resource "aws_sns_topic" "alerts" {
name = "${var.project}-alerts"
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
alarm_name = "${var.project}-high-cpu"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = 120
statistic = "Average"
threshold = 80
alarm_description = "Alarm when CPU > 80%"
alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_sns_topic_subscription" "email_sub" {
topic_arn = aws_sns_topic.alerts.arn
protocol = "email"
endpoint = "ops-team@example.com" # change to your email
}