#!/usr/bin/env bash

for CMD in cfssl cfssljson; do
    [ -e bin/$CMD ] || curl -o bin/$CMD https://pkg.cfssl.org/R1.2/${CMD}_darwin-amd64
    [ -x bin/$CMD ] || chmod +x bin/$CMD
done

[ -e bin/$CMD ] || curl -o bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/darwin/amd64/kubectl
[ -x bin/$CMD ] || chmod +x bin/kubectl

if [ ! -x bin/terraform ]; then
    ZIPFILE=terraform_0.12.3_darwin_amd64.zip
    curl -O https://releases.hashicorp.com/terraform/0.12.3/$ZIPFILE
    unzip $ZIPFILE
    rm $ZIPFILE
    mv terraform bin/
    chmod +x bin/terraform
fi

[ -d venv ] || virtualenv --prompt='(k8shard) ' venv
source venv/bin/activate
pip install ansible
