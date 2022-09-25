#!/bin/bash

set -euo pipefail

TF_RELEASE_URL="https://releases.hashicorp.com/terraform"
TF_GITHUB_RELEASE_URL="https://api.github.com/repos/hashicorp/terraform/releases/latest"

function get_tf_latest_version() {
  curl -s "${TF_GITHUB_RELEASE_URL}" | jq -r '.tag_name ' | awk 'match($0, /([0-9]).([0-9]).([0-9])/, m){print m[0]}'
}

function tf_install_binary() {
  version="$(get_tf_latest_version)"
  echo "Downloading Terraform ${version}."
  curl -s -f -L "${TF_RELEASE_URL}/${version}/terraform_${version}_linux_amd64.zip" -o tf_binary_latest.zip
  
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "Failed to download Terraform binary."
    exit $retVal
  else
    echo "Downloaded successfully."
  fi

  echo "Installing Terraform in /usr/local/bin ..."
  unzip -oq tf_binary_latest.zip -d /usr/local/bin
  
  if ! command -v terraform &> /dev/null; then
    echo "Terraform installation failed."
    exit 0
  else
    echo "Terraform has installed at /usr/local/bin successfully."
  fi
  
  rm -rf tf_binary_latest.zip
}

function tf_main() {

  if [ -x "$(command -v terraform)" ]; then
    echo "Terraform is installed."
    # If Terraform is installed, get the local version of Terraform to compare with the function (get_tf_latest_version) in next conditionals.
    tf_local_version=$(terraform -v | awk 'FNR <= 1 {print $2}' | cut -d 'v' -f 2)

    # If the local version of Terraform is up to date, displays a message and ends the script.
    # If the local version of Terraform is out of date, displays a message to download and install the latest version.
    if [ "$tf_local_version" == "$(get_tf_latest_version)"  ]; then
      echo "Terraform is updated."
      exit 0
    elif [ "$tf_local_version" != "$(get_tf_latest_version)" ]; then
      echo "Terraform is out of date."
      tf_install_binary
    fi
  else
    # If Terraform is not installed, display a message and install the latest version.
    echo "Terraform is not installed, download and install the latest version."
    tf_install_binary
  fi

}

tf_main
