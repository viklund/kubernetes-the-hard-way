#!/usr/bin/env bash

for CMD in cfssl cfssljson; do
    curl -o bin/$CMD https://pkg.cfssl.org/R1.2/${CMD}_darwin-amd64
    chmod +x bin/$CMD
done

curl -o bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/darwin/amd64/kubectl
chmod +x bin/kubectl
