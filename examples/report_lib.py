#!/usr/bin/env python

#constants

BUILD_URL = "https://buildmaster.fnal.gov/job/gwms-run-test"

RED='#ff0000'
GREEN = '#00ff00'
BLUE = '#0000ff'
BLACK = 'solid black'
BL = 'border-left'
BR = 'border-right'
BC = 'background-collapse: collapse'
TEC = 'text-align: center'
BOLD = 'font-weight: bold'

HEAD_FMT="""
<html>
<head></head>
<h3>CI build of GlideinWMS workflow  Succeeded</h3> 
<br>Build number: <a href="{BUILD_URL}/ws/{build_number} "/>{build_number}</a>
<br>Jenkins : <a href="{BUILD_URL}" />Build Page </a>
<br> <b>HOSTNAME:</b> {hostname} <br/>
<b>LINUX DISTRO:</b>{distro}<br/>
<b>PYTHON LOCATION:</b>{py_loc}<br/>
<b>PYLINT:</b>{pylint_ver}<br/>
<b>PEP8:</b> {pep8_ver}<br/>
</p><table style="border: 1px solid black;{bc};">
<thead style="{bold};border: 0px solid black;background-color: #ffcc00;">
<tr style="padding: 5px;text-align: center;">
<th rowspan="2" style="background-color:  #757bff;padding: 8px;text-align: center;">GIT BRANCHES</th>
<th colspan=4 style="{bl}: 1px solid black;{br}:1px solid black;{bc};{bold};background-color: #757bff;padding: 8px;"> <b>PYLINT</b> </th>
<th colspan=4 style="{bl}: 1px solid black;{br}:1px solid black;{bc};{bold};background-color: #757bff;padding: 8px;"> <b>UNIT TESTS</b> </th>
<th colspan=1 style="{bl}: 1px solid black;{br}:1px solid black;{bc};{bold};background-color: #757bff;padding: 8px;"> <b>FUTURIZE</b> </th>
<tr style="padding: 5px;text-align: center;">
       <!--pylint-->
      <th style="{bl}:1px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">FILES CHECKED</th>
      <th style="{bl}:0px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">FILES WITH ERRORS</th>
      <th style="{bl}:0px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">TOTAL ERRORS</th>
      <th style="{bl}:0px solid black; {br}:1px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">PEP8 ERRORS</th>
      <!--unit tests-->
      <th style="{bl}:1px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">TESTS</th>
      <th style="{bl}:0px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">SKIPPED</th>
      <th style="{bl}:0px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">FAILED</th>
      <th style="{bl}:0px solid black; {br}:0px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">% COVERAGE</th>
      <!--futurize-->
      <th style="{bl}:1px solid black; {br}:1px solid black;{bc};{bold};background-color: #ffb300;padding: 8px;">FILES TO BE REFACTORED</th>
</tr> 
</thead>

"""


ROW_FMT = """
<tr style="padding: 5px;{tec};">
    <!--pylint-->
    <th style="{bl}:1px {black}; {br}:0px {black};{bc};{bold};background-color:#00ccff;padding: 8px;">{branch_name} - {arch}</th>
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {green};padding: 5px;{tec};">{files_checked}</td>
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {pnt_err_color};padding: 5px;{tec};">{pylint_error_files}</td>
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {pnt_err_color};padding: 5px;{tec};">{total_errors}</td>
    <td style="torder-left:0px {black}; {br}:1px {black};{bc};background-color: {pnt_err_color};padding: 5px;{tec};">{pep8_errors}
    <!--unit tests-->
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {green};padding: 5px;{tec};">{num_unit_tests}</td> 
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {green};padding: 5px;{tec};">{skipped}</td>
    <td style="{bl}:0px {black}; {br}:0px {black};{bc};background-color: {ut_err_color};padding: 5px;{tec};">
        <a href="{BUILD_URL}/ws/{build_number}/{arch}/output/{branch_name}/unit_test.log" />{unit_test_errors}</a>
    </td>
    <td style="torder-left:0px {black}; {br}:1px {black};{bc};background-color: {green};padding: 5px;{tec};">
        <a href="{BUILD_URL}/ws/{build_number}/{arch}/output/{branch_name}/htmlcov.{branch_name}/index.html "/>{coverage}</a>
    </td>
    <!--futurize-->
    <td style="{bl}:1px {black}; {br}:1px {black};{bc};background-color: {refact_color};padding: 5px;{tec};">{num_to_refactor}</td>
</tr>
"""

TAIL_FMT = """
</table></body>
</html>
"""
def get_color(acol):
    red = '#ff0000'
    green = '#00ff00'
    orange = '#ffb300'
    try:
        acol = int(acol)
        if acol:
            return red
        return green
    except:
        return orange


def print_head(rh_rel=7, build_number=0, gwms_ci_url='burp',
               jenkins_ci_url='burp', hostname='container', distro='burp',
               py_loc='virtualenv', pylint_ver='burp', pep8_ver='burp'):
    print(HEAD_FMT.format(bold=BOLD,
                          bl=BL,
                          br=BR,
                          bc=BC,
                          BUILD_URL=BUILD_URL,
                          release=rh_rel,
                          build_number=build_number,
                          gwms_ci_url=gwms_ci_url,
                          jenkins_ci_url=jenkins_ci_url,
                          hostname=hostname,
                          distro=distro,
                          py_loc=py_loc,
                          pylint_ver=pylint_ver,
                          pep8_ver=pep8_ver))
                          
def print_tail():
    print(TAIL_FMT)

def print_row(branch_name="master", file_check_cnt=0, num_pylint_err_files=0,
              num_pylint_errs=0, num_pep8_errs=0, num_unit_tests=0,
              num_unit_test_skipped=0, num_unit_test_errors=0, coverage='0%',
              num_to_refactor='0', arch='?', build_number=0):

    print(ROW_FMT.format(red=RED,
                         green=GREEN,
                         blue=BLUE,
                         black=BLACK,
                         bold=BOLD,
                         bl=BL,
                         br=BR ,
                         bc=BC,
                         tec=TEC,
                         BUILD_URL=BUILD_URL,
                         branch_name = branch_name,
                         files_checked = file_check_cnt,
                         pylint_error_files=num_pylint_err_files,
                         pnt_err_color = get_color(num_pylint_err_files),
                         total_errors = num_pylint_errs,
                         pep8_errors = num_pep8_errs,
                         num_unit_tests = num_unit_tests,
                         skipped = num_unit_test_skipped,
                         unit_test_errors = num_unit_test_errors,
                         ut_err_color=get_color(num_unit_test_errors),
                         coverage=coverage,
                         num_to_refactor = num_to_refactor,
                         refact_color = get_color(num_to_refactor),
                         arch=arch,
                         build_number=build_number))
    


if __name__ == '__main__':
    print_head()
    print_row()
    print_tail()
