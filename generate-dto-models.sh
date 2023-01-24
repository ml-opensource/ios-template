#!/bin/bash

# A script to autogenerate Swift DTO models from an OpenAPI spec file.
# Just provide a valid OpenAPI spec file (can be found in Swagger usually)
# and this script will autogenerate the model structs

# ❗️IMPORTANT: You must install the OpenAPI generator first to make this work:
# https://github.com/OpenAPITools/openapi-generator#1---installation
# TL;DR:
# brew install openapi-generator
# chmod +x generate-dto-models.sh


# -----------------------------------------------
# ❗️⬇️ PROJECT SPECIFIC VARS - CHANGE THESE ❗️⬇️
# -----------------------------------------------

# Path to the OpenAPI spec
# Spec is either .yaml or .json file
# Can be both a local path or a remote URL
OPEN_API_SPEC='https://raw.githubusercontent.com/openapitools/openapi-generator/master/modules/openapi-generator/src/test/resources/3_0/petstore.yaml'

# The folder to copy the generated models files to
# Script fails if this folder does not exist
OUTPUT_FOLDER='Modules/Sources/APIClientLive/DTO'


# ---------------------------------------------------
# ✅ OTHER VARS - PROBABLY NO NEED TO CHANGE THESE ✅
# ---------------------------------------------------

# Adds a suffix to the model name
# Eg.: Token -> TokenDto
MODEL_NAME_SUFFIX='Dto'
NC=$(tput sgr0) # No color
GREEN=$(tput setaf 2) # Green color


# ---------------------
# 👾 THE SCRIPT FLOW 👾
# ---------------------

prettyPrint () {
  printf "$GREEN \n ➡️  $1 $NC \n \n"
}

prettyPrint "VALIDATING THE SPEC FILE"

if openapi-generator validate --input-spec $OPEN_API_SPEC
then
    prettyPrint "✅ Spec file looks good"
else
    prettyPrint "❌ Spec file validation failed. Make sure you provided a path or URL to a valid .json or .yaml OpenAPI spec file. You provided this path: $NC $OPEN_API_SPEC"
    exit
fi

prettyPrint "GENERATING MODELS FROM THE SPEC FILE"

# run 'openapi-generator help generate' to see the parameter descriptions
if openapi-generator generate \
            --input-spec $OPEN_API_SPEC \
            --output $OUTPUT_FOLDER \
            --model-name-suffix $MODEL_NAME_SUFFIX \
            --generator-name swift5 \
            --global-property models \
            --model-package /'' \
            --additional-properties=useJsonEncodable=false \
            --additional-properties=swiftPackagePath='models' \
            # Additional properties are template specific.
            # See: https://github.com/OpenAPITools/openapi-generator/blob/031f0dcee692264681387bf8fbbece98f477801b/docs/generators/swift5.md
then
    prettyPrint "✅ Models created succesfully. Find them in this folder: $NC $OUTPUT_FOLDER"
else
    prettyPrint "❌ Models could not be generated. Check above log for errors."
    exit
fi
