# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY get-trips FUNCTION TO AWS LAMBDA
# ----------------------------------------------------------------------------------------------------------------------

locals {
  layers = [aws_lambda_layer_version.requests_layer.arn]
}

# ----------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA EXPECTS A DEPLOYMENT PACKAGE
# A deployment package is a ZIP archive that contains your function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "this" {

  type        = "zip"
  source_file = "${path.root}/../aws/lambdas/functions/${var.function_name}/lambda_handler.py"
  output_path = "${path.root}/../aws/lambdas/artifacts/functions/${var.function_name}.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY THE LAMBDA FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "this" {

  function_name = var.function_name
  description   = var.description

  filename         = "${path.root}/../aws/lambdas/artifacts/functions/${var.function_name}.zip"
  source_code_hash = filebase64sha256("${path.root}/../aws/lambdas/artifacts/functions/${var.function_name}.zip")


  runtime = var.runtime
  handler = var.handler
  layers  = local.layers
  role    = aws_iam_role.lambda_iam_role.arn

  memory_size = var.memory_size
  timeout     = var.timeout

  environment {
    variables = {

    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_get_trips" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monthly_ingestion_event_rule.arn
}


# ----------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM LAMBDA EXECUTION ROLE WHICH WILL BE ATTACHED TO THE FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {

  name               = "${var.function_name}_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  depends_on = [data.aws_iam_policy_document.lambda_assume_role]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE CLOUDWATCH LOG GROUP
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 1
}

# ----------------------------------------------------------------------------------------------------------------------
# DEFINE AWS LAMBDA POLICY DOCUMENT
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_policy" {

  statement {
    sid       = "AllowS3PutActions"
    actions   = ["s3:Put*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.function_name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_iam_policy" {

  name   = "${var.function_name}_policy"
  role   = aws_iam_role.lambda_iam_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json

}