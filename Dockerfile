ARG rel=7
FROM scientificlinux/sl:${rel}
#FROM opensciencegrid/osg-wn:3.4-el${rel}
ARG rel
ENV rel ${rel} 
ENV TEST_DIR /test_dir

#RUN rpm -Uvh https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el${rel}-release-latest.rpm
#RUN yum -y -q update &&  yum -y -q install osg-ca-certs
RUN for PKG in epel epel-release ipc javascriptrrd m2crypto openssl findutils which file git tzdata rpm-build mock; do echo $PKG; yum -y -q install $PKG || true ; done 
RUN for PKG in epel epel-release ipc javascriptrrd m2crypto openssl findutils which file git tzdata rpm-build mock; do echo $PKG; yum -y -q reinstall $PKG || true ; done 
#RUN for PKG in epel javascriptrrd m2crypto openssl findutils which file git tzdata ; do echo installing-->$PKG; yum -y -q install $PKG; done 
RUN yum -y reinstall tzdata


#the test/lint remote commands
#RUN mkdir -p $TEST_DIR/output
COPY run_unit_tests  /usr/local/bin/run_gwms_coverage
COPY run_unit_tests  /usr/local/bin
COPY quick_tests     /usr/local/bin/gwms_quick_tests
COPY quick_tests     /usr/local/bin
COPY new_branches    /usr/local/bin/new_gwms_branches
COPY new_branches    /usr/local/bin
COPY setup_test_env  /usr/local/bin
COPY help            /usr/local/bin/help
COPY run_pylint      /usr/local/bin/run_gwms_pylint
COPY run_pylint      /usr/local/bin
COPY run_futurize    /usr/local/bin
COPY build_rpms      /usr/local/bin
COPY slow_tests      $TEST_DIR/slow_test_list


# set up code repo
#RUN cd $TEST_DIR && git clone https://github.com/glideinWMS/glideinwms.git && cd $TEST_DIR/glideinwms && git checkout dbox_ci && cd $TEST_DIR  && source glideinwms/build/jenkins/utils.sh && setup_python_venv 

# env vars needed by unit test scripts
RUN cd /root && echo "test -f $TEST_DIR/venv-2.${rel}/bin/activate && . $TEST_DIR/venv-2.${rel}/bin/activate" >> .bashrc
RUN cd /root && echo "test -f $TEST_DIR/venv-2.${rel}/bin/activate && . $TEST_DIR/venv-2.${rel}/bin/activate" >> .bash_profile
ENV VIRTUAL_ENV=$TEST_DIR/venv-2.${rel}
ENV PYTHONPATH=$TEST_DIR
ENV PROJECT=glideinwms
