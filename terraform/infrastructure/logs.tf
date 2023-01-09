resource "aws_cloudwatch_log_group" "foundry" {
    name = "foundry_lg"
    retention_in_days = 1
}