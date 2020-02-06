#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"

cd "$dir"

source settings.sh

aws s3 cp labels/$1 s3://$BUCKET/labels/