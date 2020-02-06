#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"

cd "$dir"

PAYLOAD=$(bash scripts/s3-put-payload.sh uploads/$1)

source settings.sh

# filename (without the path)
BASENAME=$(basename $1)
# filename (also without the extension)
NOEXTNAME=${BASENAME%.*}

# create missing directories
mkdir --parents "invokes/upload"

aws lambda invoke \
    --region $REGION \
    --function-name $UPLOAD_FUNCTION \
    --payload "$PAYLOAD" \
    "invokes/upload/$NOEXTNAME.json"