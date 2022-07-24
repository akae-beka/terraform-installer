#!/bin/bash

set -euo pipefail

TF_RELEASE_URL="https://releases.hashicorp.com/terraform"
TF_GITHUB_RELEASE_URL="https://api.github.com/repos/hashicorp/terraform/releases/latest"

function tf_download_binary() {
  latest_version=$(curl -s "${TF_GITHUB_RELEASE_URL}" | jq -r ' . | .tag_name ' | cut -d 'v' -f 2)
  curl -s -f -L ${TF_RELEASE_URL}/"${latest_version}"/terraform_"${latest_version}"_linux_amd64.zip \
   -o tf_binary_latest.zip
}

function tf_install_binary {
  unzip -oq tf_binary_latest.zip -d /usr/local/bin
  rm -rf tf_binary_latest.zip
  echo "$(terraform -v | head -1) is installed."
}

function tf_run() {
  if [ -x "$(command -v terraform)" ]; then
    echo "Terraform is installed."
    tf_version_lines=$(terraform -v | wc -l)
    if [ "$tf_version_lines" -eq 2 ]; then
      echo "Terraform is updated."
      exit 0
    elif [ "$tf_version_lines" -gt 2 ]; then
      echo "Terraform is out of date."
      tf_download_binary
      tf_install_binary
    fi
  else
    echo "Terraform is not installed, downloading latest version."
    tf_download_binary
    tf_install_binary
  fi
}

tf_run
