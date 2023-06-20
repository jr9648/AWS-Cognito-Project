output "dynamo_db_read" {
  value       =  aws_iam_policy.dynamo_db_read.arn
}

output "dynamo_db_write" {
  value       =  aws_iam_policy.dynamo_db_write.arn
}

output "dynamo_db_delete" {
  value       =  aws_iam_policy.dynamo_db_delete.arn
}

#output "s3_bucket_write" {
#  value       =  aws_iam_policy.s3_bucket_write.arn
#}
#
output "cloud_watch_put_metrics" {
  value       =  aws_iam_policy.cloud_watch_put_metrics.arn
}