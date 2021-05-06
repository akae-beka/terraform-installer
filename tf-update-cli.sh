#!/bin/bash

#set -xe

# variables
RELEASE_URL="https://releases.hashicorp.com/terraform/"

function verify_terraform() {
    
    if [ -x "$(command -v terraform)" ]; then
      #echo "Terraform is installed"
      :
    else
      echo "Terraform is not installed"
    fi
}

function verify_version() {
    getVersion=$(terraform -v | head -1 | awk '{print $2}' | tr -d "v")
    getLatestVersion=$(curl -s -N $RELEASE_URL | grep "/terraform/" | head | cut -d "/" -f 3 | sort | tail -n 1)
    if [ $getVersion == $getLatestVersion ]; then
      echo "Your version of Terraform is updated!"
    elif [ $getVersion != $getLatestVersion ]; then
      echo "Downloading Terraform latest version ..."
      downloadLatestVersion=$(curl -sO ${RELEASE_URL}${getLatestVersion}/terraform_${getLatestVersion}_linux_amd64.zip)
      if [ "$?" -eq "0" ]; then
        clear
        rm -rf /usr/local/bin/terraform
        unzip -o terraform_${getLatestVersion}_linux_amd64.zip -d /usr/local/bin
        rm -rf terraform_${getLatestVersion}_linux_amd64.zip
        terraform -v
      else
        echo "Download error!"
      fi
    else
      echo "Operation error!"
    fi
}

function terraform_update() {
  if [ -x "$(command -v terraform)" ]; then
    echo "Terraform is installed"
  else
    echo "Terraform is not installed, downloading Terraform latest version..."
    getLatestVersion=$(curl -s -N $RELEASE_URL | grep "/terraform/" | head | cut -d "/" -f 3 | sort | tail -n 1)
    downloadLatestVersion=$(curl -sO ${RELEASE_URL}${getLatestVersion}/terraform_${getLatestVersion}_linux_amd64.zip)
    if [ "$?" -eq "0" ]; then
      unzip -oq terraform_${getLatestVersion}_linux_amd64.zip -d /usr/local/bin
      rm -rf terraform_${getLatestVersion}_linux_amd64.zip
      terraform -v | head -n 1
    else
      echo "Download error!"
    fi
  fi 
}

#verify_terraform
#verify_version
terraform_update
