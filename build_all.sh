#!/bin/bash
docker run --rm dbox/gwms-test /bin/sh -c "ls /gwms_test/glideinwms/build/jenkins" > jenkins_scripts
if [ "$builder" = "" ];then
    builder=$(whoami)
fi
for rel in 6 7; do  
    docker build . --build-arg rel=$rel --tag $builder/gwms-test:sl$rel; 
done
rel=7
docker build . --build-arg rel=$rel --tag $builder/gwms-test:latest
