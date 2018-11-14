ARG rel=7
FROM scientificlinux/sl:${rel}
ARG rel
ENV rel ${rel} 

#the test/lint remote commands
RUN mkdir gwms_test
COPY run_unit_tests /usr/local/bin/run_gwms_coverage
COPY quick_tests /usr/local/bin/gwms_quick_tests
COPY slow_tests /gwms_test/slow_test_list
COPY help       /usr/local/bin/help
COPY run_pylint /usr/local/bin/run_gwms_pylint
COPY new_branches /usr/local/bin/new_gwms_branches

RUN rpm -Uvh https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el${rel}-release-latest.rpm
RUN yum -y -q update &&  yum -y -q install osg-ca-certs
RUN yum -y -q install javascriptrrd
RUN yum -y -q install m2crypto
RUN yum -y -q install findutils
RUN yum -y -q install which
RUN yum -y -q install file
RUN yum -y -q install git

# set up code repo
RUN cd gwms_test && git clone https://github.com/glideinWMS/glideinwms.git
RUN cd gwms_test && source glideinwms/build/jenkins/utils.sh && setup_python_venv

#clean up
RUN cd gwms_test && rm -rf virtualenv-*

# env vars needed by unit test scripts
RUN cd /root && echo ". /gwms_test/venv-2.${rel}/bin/activate" >> .bashrc
ENV VIRTUAL_ENV=/gwms_test/venv-2.${rel}
ENV PYTHONPATH=/gwms_test

