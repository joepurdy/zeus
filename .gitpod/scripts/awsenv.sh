#!/bin/bash

gp env -u AWS_ACCESS_KEY_ID
gp env -u AWS_SECRET_ACCESS_KEY

read -p "Enter AWS Access Key: " access_key
read -p "Enter AWS Secret Key: " secret_key

gp env AWS_ACCESS_KEY_ID=$access_key
gp env AWS_SECRET_ACCESS_KEY=$secret_key
gp env AWS_REGION=us-east-1

echo "eval \$(gp env -e)" >>~/.bashrc
