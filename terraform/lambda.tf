locals {
  upload_source = "../lambda/upload.js"
  upload_output = "../lambda/upload.zip"
  label_source = "../lambda/label.js"
  label_output = "../lambda/label.zip"
}

#
# upload
#

data archive_file upload_zip {
  type        = "zip"
  source_file = local.upload_source
  output_path = local.upload_output
}

resource aws_lambda_function upload_function {
  filename         = data.archive_file.upload_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.upload_zip.output_path)

  function_name = "${var.project_name}-upload-${random_id.random.hex}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "upload.handler"
  runtime       = "nodejs12.x"
  timeout       = 10
}

resource aws_cloudwatch_log_group upload_log_group {
  name = "/aws/lambda/${aws_lambda_function.upload_function.function_name}"
}

output upload_function {
  value = aws_lambda_function.upload_function.function_name
}

output upload_log_group {
  value = aws_cloudwatch_log_group.upload_log_group.name
}

#
# label
#

data archive_file label_zip {
  type        = "zip"
  source_file = local.label_source
  output_path = local.label_output
}

resource aws_lambda_function label_function {
  filename         = data.archive_file.label_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.label_zip.output_path)

  function_name = "${var.project_name}-label-${random_id.random.hex}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "label.handler"
  runtime       = "nodejs12.x"
  memory_size   = 256
  timeout       = 10

  layers = [aws_lambda_layer_version.imagemagick_layer.arn]
}

resource aws_cloudwatch_log_group label_log_group {
  name = "/aws/lambda/${aws_lambda_function.label_function.function_name}"
}

output label_function {
  value = aws_lambda_function.label_function.function_name
}

output label_log_group {
  value = aws_cloudwatch_log_group.label_log_group.name
}

