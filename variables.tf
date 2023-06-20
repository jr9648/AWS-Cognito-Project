variable "table_name" {
  description = "The name of the DyanamoDB table"
  type        = string
  default = "Dev_Dynamo"
}

variable "code_bucket_name" {
  description = "The name of the S3 bucket to store Lambda source code"
  type        = string
  default = "implant-wise-lambda-code"
}