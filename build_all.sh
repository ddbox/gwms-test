#!/bin/bash
if [ "$builder" = "" ];then
    builder=$(whoami)
fi
rm -rf glideinwms
git clone https://github.com/glideinWMS/glideinwms.git
cd glideinwms
git checkout dbox_ci
cd ..
for rel in 6 7; do  
    docker build . --build-arg rel="$rel" --tag "${builder}/gwms-test:sl${rel}"; 
    echo build status: $?
done
rel=7
docker build . --build-arg rel="$rel" --tag "${builder}/gwms-test:latest"
echo build status: $?
