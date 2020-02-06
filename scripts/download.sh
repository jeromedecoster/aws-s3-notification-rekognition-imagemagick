#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"

cd "$dir"

source settings.sh

aws s3api list-objects-v2 \
    --region $REGION \
    --bucket $BUCKET \
    --query "Contents[?starts_with(Key, 'converted')].[Key]" \
    --output text \
    | xargs -I % bash -c "aws s3 cp s3://$BUCKET/% converted"
