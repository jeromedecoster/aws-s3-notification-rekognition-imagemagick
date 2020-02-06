locals {
  region = "eu-west-1"
}

provider aws {
  region = local.region
}
resource random_id random {
  byte_length = 3
}

variable project_name {
  type        = string
  default     = "imagemagick-rekognition"
}

output region {
  value = local.region
}

#
# write some variables to settings.sh
#

resource null_resource settings_sh {

  triggers = {
    #everytime = uuid()
    rarely = join("-", [
      local.region, 
      aws_s3_bucket.bucket.id, 
      aws_lambda_function.upload_function.function_name,
      aws_lambda_function.label_function.function_name,
      fileexists("../settings.sh")
    ])
  }

  provisioner local-exec {
    command = <<EOF
echo 'REGION=${local.region}
BUCKET=${aws_s3_bucket.bucket.id}
UPLOAD_FUNCTION=${aws_lambda_function.upload_function.function_name}
UPLOAD_LOG_GROUP=${aws_cloudwatch_log_group.upload_log_group.name}
LABEL_FUNCTION=${aws_lambda_function.label_function.function_name}
LABEL_LOG_GROUP=${aws_cloudwatch_log_group.label_log_group.name}' >> ../settings.sh;
awk --include inplace '!a[$0]++' ../settings.sh
EOF
  }
}