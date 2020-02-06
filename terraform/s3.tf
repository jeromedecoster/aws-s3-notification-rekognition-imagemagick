locals {
  imagemagick_source = "../layers/imagemagick-7.0.9-20.zip"
  imagemagick_key = "layers/imagemagick-7.0.9-20.zip"
}

resource aws_s3_bucket bucket {
  bucket = "${var.project_name}-${random_id.random.hex}"
  acl    = "private"

  force_destroy = true
}

output bucket {
  value = aws_s3_bucket.bucket.id
}

#
# bucket notifications
#

resource aws_s3_bucket_notification bucket_upload_notification {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.label_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "labels/"
  }
}

#
# lambda permissions
#

resource aws_lambda_permission upload_permission {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource aws_lambda_permission label_permission {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.label_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

#
# imagemagick lambda layer
#

resource aws_s3_bucket_object imagemagick {
  bucket = aws_s3_bucket.bucket.id
  key    = local.imagemagick_key
  source = local.imagemagick_source
  etag = filemd5(local.imagemagick_source)
}

resource aws_lambda_layer_version imagemagick_layer {
  layer_name = "imagemagick"
  s3_bucket = aws_s3_bucket.bucket.id
  s3_key = aws_s3_bucket_object.imagemagick.id
  compatible_runtimes = ["nodejs12.x"]
}
