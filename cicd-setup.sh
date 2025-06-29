#!/bin/bash
set -euo pipefail

source ./.env
base_name=${BASE_NAME}

# Log all outputs and errors to a log file
log_file="cicd_setup_${base_name}_$(date +"%Y%m%d_%H%M%S").log"
exec > >(tee -a "$log_file")
exec 2>&1

# Set the paths to the Terraform files
CICD_SETUP_TMP_ENV_FILE="cicd_setup_tmp.env"

echo "Checking if required environment variables exists..."
missing_env_vars=()

required_env_vars=(GITHUB_ORGANIZATION_NAME GITHUB_REPO_NAME CICD_SP_CLIENT_ID CICD_SP_CLIENT_SECRET TENANT_ID)
for var in "${required_env_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_env_vars+=("$var")
    fi
done

if [ ${#missing_env_vars[@]} -ne 0 ]; then
    echo "Error: The following required environment variables are not set:"
    for var in "${missing_env_vars[@]}"; do
        echo "  - $var"
    done
    exit 1
else
    echo "All required environment variables are set."
fi
echo "-------------------------------------"



# Function to check if a file exists
check_file_exists() {
  if [ ! -f "$1" ]; then
    echo "Error: File $1 does not exist."
    exit 1
  else
    echo "File $1 exists. Proceeding..."
  fi
}



# Export these values as environment variables
echo "Exporting variables to $CICD_SETUP_TMP_ENV_FILE file..."
# Initialize cicd_temp.env as an empty file
echo "" > $CICD_SETUP_TMP_ENV_FILE
cat >> $CICD_SETUP_TMP_ENV_FILE << EOF
TENANT_ID=$TENANT_ID
CICD_SP_CLIENT_ID=$CICD_SP_CLIENT_ID
EOF


echo "Extraction complete. Variables have been exported to $CICD_SETUP_TMP_ENV_FILE"
echo "-------------------------------------"
echo "Contents of $CICD_SETUP_TMP_ENV_FILE:$(cat $CICD_SETUP_TMP_ENV_FILE)"
echo "-------------------------------------"


###################################GITHUB Variables and Secret Related Steps##################################################
# Set GitHub variables using the values from the temp env file
echo "Setting GitHub variables..."

# Load the environment variables from the temp env file
source $CICD_SETUP_TMP_ENV_FILE

# Loop through the values in $CICD_SETUP_TMP_ENV_FILE and set GitHub variables
while IFS='=' read -r key value; do
    if [ -n "$key" ] && [ -n "$value" ]; then
        echo "Setting GitHub variable: $key"
        gh variable set "$key" --repo "$GITHUB_ORGANIZATION_NAME/$GITHUB_REPO_NAME" --body "$value"
    fi
done < "$CICD_SETUP_TMP_ENV_FILE"

echo "GitHub variables have been successfully set."
gh secret set CICD_SP_CLIENT_SECRET --repo $GITHUB_ORGANIZATION_NAME/$GITHUB_REPO_NAME --body $CICD_SP_CLIENT_SECRET
echo "GitHub secrets have been successfully set."
echo "-------------------------------------"

# Remove the temporary environment file
echo "Cleaning up temporary files..."
rm -f "$CICD_SETUP_TMP_ENV_FILE"
echo "Temporary file $CICD_SETUP_TMP_ENV_FILE has been removed."
echo "-------------------------------------"