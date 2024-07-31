#!/bin/bash

# This script creates a Python virtual environment, installs required packages from a requirements.txt file,
# and then packages the virtual environment's libraries into a ZIP file suitable for use as an AWS Lambda layer.
#
# Usage:
#   ./create_lambda_layer_artifact.sh <root_path> <artifact_file_name>
#
# Arguments:
#   <root_path>         The path where the virtual environment will be created and where the requirements.txt file is located.
#   <artifact_file_name> the name of the output ZIP file to be created.

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error and exit immediately

################################################################################
# Usage                                                                         #
################################################################################
usage() {
    echo "Create a Python virtual environment, installs the libraries listed in 'requirements.txt' file,"
    echo "and then packages the virtual environment's libraries into a ZIP file suitable for use as an AWS Lambda layer."
    echo ""
    echo "Usage: $0 <root_path> <artifact_file_name>"
    echo ""
    echo "Arguments:"
    echo "  <root_path> The root path where the Python Virtual environment will be created."
    echo "  <artifact_file_name>  The name of the output ZIP file to be created."
    exit 1
}

#######################################
# Create and activate a Python virtual environment named .venv.
# Arguments:
#   The root directory where the Python virtual environment will be created.
#######################################
create_and_activate_venv() {
    local root_dir=$1
    python3.12 -m venv "$root_dir/.venv"
    source "$root_dir/.venv/bin/activate"
}

#######################################
# Install Python libraries specified in the requirements file.
# Arguments:
#   Root directory of the requirements file.
#######################################
install_requirements() {
    local root_dir=$1
    pip install -q -r "$root_dir/requirements.txt"
}

#######################################
# Create a zip artifact for the Lambda layer.
# Arguments:
#   The root directory of the Python virtual environment.
#   The name of the zip artifact to be created.
#######################################
create_layer_zip() {
    local target_path=$1
    local artifact_file_name=$2
    local layer_dir="python"

    cd "$target_path"
    mkdir -p "$layer_dir"
    cp -r .venv/lib "$layer_dir/"
    zip -q -r "$artifact_file_name" "$layer_dir"
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Variables
root_path=$1
artifact_file_name=$2

# Main script execution
echo "Creation of Python virtual environment..."
create_and_activate_venv "$root_path"

echo "Installing Python libraries..."
install_requirements "$root_path"

echo "Zip of Python packages..."
create_layer_zip "$root_path" "$artifact_file_name"

echo "The Lambda layer has been successfully created under: $root_path"‚