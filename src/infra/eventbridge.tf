
# Create our schedule
resource "aws_cloudwatch_event_rule" "historical_ingestion_rule" {
  name        = "historical-data-ingestion-rule" #var.ingestion_event_rule_name
  description = "This rule triggers Historical data ingestion and is a One-Time Schedule event."

  schedule_expression = "rate(5 minutes)"
}

# Trigger our lambda based on the schedule
resource "aws_cloudwatch_event_target" "historical_ingestion_target" {

  rule = aws_cloudwatch_event_rule.historical_ingestion_rule.name
  arn  = aws_lambda_function.this.arn

  input = jsonencode({
    "source" : "custom_event",
    "action" : "historical_data_ingestion",
    "detail" : {
      "start_date" : "2023-01-01",
      "end_date" : "2023-12-31",
      "taxi_types" : ["yellow", "green"]
      "description" : "Historical ingestion of Yellow and Green taxi trips data for the year 2023."
    }

  })
}