.SILENT:

#
# terraform commands
#

init:
	scripts/init.sh

validate:
	scripts/validate.sh

apply:
	scripts/apply.sh

#
# tail (and follow) cloudwatch logs with saw
#

watch-uploads:
	scripts/watch-uploads.sh

watch-labels:
	scripts/watch-labels.sh

#
# upload image to s3://<bucket>/uploads
#

bird1.jpg:
	scripts/uploads.sh bird1.jpg

bird2.jpg:
	scripts/uploads.sh bird2.jpg

cat1.jpg:
	scripts/uploads.sh cat1.jpg

cat2.jpg:
	scripts/uploads.sh cat2.jpg

dog1.jpg:
	scripts/uploads.sh dog1.jpg

dog2.jpg:
	scripts/uploads.sh dog2.jpg

squirrel.jpg:
	scripts/uploads.sh squirrel.jpg

#
# upload json to s3://<bucket>/labels
#

bird1.json:
	scripts/labels.sh bird1.json

bird2.json:
	scripts/labels.sh bird2.json

cat1.json:
	scripts/labels.sh cat1.json

cat2.json:
	scripts/labels.sh cat2.json

dog1.json:
	scripts/labels.sh dog1.json

dog2.json:
	scripts/labels.sh dog2.json

squirrel.json:
	scripts/labels.sh squirrel.json

#
# invoke the `upload` lambda function with a JSON payload
#

invoke-upload-bird1:
	scripts/invoke-upload.sh bird1.jpg

invoke-upload-cat1:
	scripts/invoke-upload.sh cat1.jpg

invoke-upload-dog1:
	scripts/invoke-upload.sh dog1.jpg

invoke-upload-squirrel:
	scripts/invoke-upload.sh squirrel.jpg

#
# invoke the `label` lambda function with a JSON payload
#

invoke-label-bird1:
	scripts/invoke-label.sh bird1.json

invoke-label-cat1:
	scripts/invoke-label.sh cat1.json

invoke-label-dog1:
	scripts/invoke-label.sh dog1.json

invoke-label-squirrel:
	scripts/invoke-label.sh squirrel.json

#
# download converted
#

download:
	scripts/download.sh