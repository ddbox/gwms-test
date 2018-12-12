#!/usr/bin/env python

import os
import report_lib
from report_lib import print_row


if __name__ == '__main__':

    branch_name = os.environ.get('branch', 'master')
    file_check_cnt = os.environ.get('FILES_CHECKED_COUNT', 0)
    num_pylint_err_files = os.environ.get('PYLINT_ERROR_FILES_COUNT', 0)
    num_pylint_errs = os.environ.get('PYLINT_ERROR_COUNT', 0)
    num_pep8_errs = os.environ.get('PEP8_ERROR_COUNT', 0)
    num_unit_tests = os.environ.get('num_tests', 0)
    num_unit_tests_skipped = os.environ.get('skipped', 0)
    num_unit_test_errors = os.environ.get('error_count', 0)
    coverage = os.environ.get('coverage', '0%')
    num_to_refactor = os.environ.get('refactor_count', 0)
    arch = os.environ.get('arch', '?')
    build_number = os.environ.get('BUILD_NUMBER',0)

    print_row(branch_name,
              file_check_cnt,
              num_pylint_err_files,
              num_pylint_errs,
              num_pep8_errs,
              num_unit_tests,
              num_unit_tests_skipped,
              num_unit_test_errors,
              coverage,
              num_to_refactor,
              arch,
              build_number
              )
