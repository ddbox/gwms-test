#!/usr/bin/env python

import os
import report_lib
from report_lib import print_head




if __name__ == '__main__':
    rh_rel=os.environ.get('arch', 7)
    build_number = os.environ.get('BUILD_NUMBER',3)
    gwms_ci_url = os.environ.get('gwms_ci_url','burp')
    jenkins_ci_url = os.environ.get('jenkins_ci_url','burp')
    hostname = os.environ.get('hostname','burp')
    distro = os.environ.get('distro','burp')
    py_loc = os.environ.get('py_loc','burp')
    pylint_ver = os.environ.get('pylint_ver','burp')
    pep8_ver = os.environ.get('pep8_ver','burp')

    print_head(rh_rel,
            build_number,
            gwms_ci_url,
            jenkins_ci_url,
            hostname,
            distro,
            py_loc,
            pylint_ver,
            pep8_ver
            )
