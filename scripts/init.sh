#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")/.."; pwd)"


# imagemagick lambda layer
ZIP=imagemagick-7.0.9-20.zip

if [[ ! -f "$dir/layers/$ZIP" ]]; then
    cd "$dir/layers"
    curl --location \
        --remote-name \
        "https://github.com/jeromedecoster/imagemagick-lambda-layer/releases/download/v7.0.9-20/$ZIP"
fi


# terraform
cd "$dir/terraform"

terraform init
