#!/bin/bash

set -euo pipefail

TF_RELEASE_URL="https://releases.hashicorp.com/terraform"
TF_DOWNLOAD_URL="https://www.terraform.io/downloads"

function tf_download_binary() {
  latest_version=$(curl -s -N ${TF_DOWNLOAD_URL} | grep -o 'latest.*$' | cut -d ">" -f 3 | awk '{print $2}')
  curl -sO ${TF_RELEASE_URL}/"${latest_version}"/terraform_"${latest_version}"_linux_amd64.zip
}

function tf_install_binary {
  unzip -oq terraform_"${latest_version}"_linux_amd64.zip -d /usr/local/bin
  rm -rf terraform_"${latest_version}"_linux_amd64.zip
  echo "Terraform $(terraform -v | head -1 | awk '{print $2}') is installed."
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
