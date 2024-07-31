# ----------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA FUNCTION VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

variable "function_name" {
  description = "(Required) A unique name for the Lambda function."
  type        = string
}

variable "handler" {
  description = "(Required) The function entrypoint in the code."
  type        = string
}

variable "runtime" {
  description = "(Required) The runtime the Lambda function should run in."
  type        = string
}

variable "description" {
  description = "(Optional) A description of what the Lambda function does."
  type        = string
  default     = null
}

variable "filename" {
  description = "(Optional) The path to the .zip file that contains the Lambda function source code."
  type        = string
  default     = null
}

variable "memory_size" {
  description = "(Optional) Amount of memory in MB the Lambda function can use at runtime. For details see https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "(Optional) The amount of time the Lambda function has to run in seconds. For details see https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html"
  type        = number
  default     = 3
}

# ----------------------------------------------------------------------------------------------------------------------
# REQUESTS LAYER VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

variable "requests_layer_root" {
  description = "This is the root path to the requests layer"
  type        = string
  default     = "src/aws/lambdas/layers/requests"
}

variable "requests_layer_name" {
  description = "Name of the python_requests layer"
  type        = string
  default     = "python_requests"
}

variable "compatible_layer_runtimes" {
  description = "Compatible layer runtimes"
  type        = list(string)
}

variable "compatible_architectures" {
  description = "Compatible layer architectures"
  type        = list(string)
}

# ----------------------------------------------------------------------------------------------------------------------
# S3 VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

variable "bucket" {
  description = "Name of the S3 Bucket where the data should be stored."
  type        = string
}

variable "bucket_prefix" {
  description = "The Bucket prefix to be used."
  type        = string
}

variable "s3_raw_data_key" {
  description = "Name of the S3 Key where the raw parquet files should be stored after Ingestion."
  type        = string
}

variable "s3_processed_data_key" {
  description = "Name of the S3 Key where the processed parquet files should be stored after Processing."
  type        = string
}

