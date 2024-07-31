# ----------------------------------------------------------------------------------------------------------------------
# DEFINE S3 BUCKET
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket
  force_destroy = true
}

resource "aws_s3_object" "raw_data_zone" {
  bucket = aws_s3_bucket.this.id
  key    = var.s3_raw_data_key
}

resource "aws_s3_object" "processed_data_zone" {
  bucket = aws_s3_bucket.this.id
  key    = var.s3_processed_data_key
}

# ----------------------------------------------------------------------------------------------------------------------
# DEFINE SQS QUEUE AND ATTACH POLICY
# ----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_ingestion_event_policy" {

  statement {
    sid       = "AllowS3ToSendMessageToSQS"
    actions   = ["SQS:SendMessage"]
    effect    = "Allow"
    resources = ["arn:aws:sqs:*:*:s3-ingestion-event-queue"]
    condition {
      test     = "ArnEquals"
      values   = [aws_s3_bucket.this.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue" "s3_ingestion_event_queue" {
  name = "s3-ingestion-event-queue"
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.s3_ingestion_event_queue.id
  policy    = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "s3.amazonaws.com"
          },
          "Action": "sqs:SendMessage",
          "Resource": "arn:aws:sqs:*:*:s3-ingestion-event-queue",
          "Condition": {
            "ArnEquals": {
              "aws:SourceArn": "${aws_s3_bucket.this.arn}"
            }
          }
        }
      ]
    }
    POLICY

}

# ----------------------------------------------------------------------------------------------------------------------
# DEFINE S3 BUCKET NOTIFICATION
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  queue {
    queue_arn     = aws_sqs_queue.s3_ingestion_event_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "landing"
  }

}