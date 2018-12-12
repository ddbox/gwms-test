#!/bin/bash

function usage {
echo "usage: $0 /path/to/results/directory"
echo "merge pep8, pylint, coverage, and futurize test output "
echo "create html reports pointed to by \$html_test_report, \$html_coverage_browser"
echo "also create text report \$outfile all defined below"
echo "TODO assumes that tail directory in /path/to/etc is BUILD_NUMBER"
echo "which is a jenkins artifact"
exit 1
}

if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

PATHTO=../$(dirname $0)

export BUILD_NUMBER=$1

outfile=test_"$BUILD_NUMBER"_results.txt
html_test_report="$BUILD_NUMBER"_results.html
html_coverage_browser="$BUILD_NUMBER"_coverage_browser.html



cd $BUILD_NUMBER || usage

export hostname=$HOSTNAME
export distro='scientific linux 6 & 7'
export py_loc='virtualenv'
export pylint_ver='virtualenv'
export pep8_ver='virtualenv'

$PATHTO/print_header.py > $html_test_report


echo "test $BUILD_NUMBER on $(date)" > $outfile
for dir in $(find .  -type d -name xml_reports); do
    export branch=$(basename $(dirname $dir))
    export arch=$(basename $(dirname $(dirname $(dirname $dir))))
    export arch_branch="$branch - $arch"
    sum=0 
    for v in $(grep 'tests=' $dir/*.xml | sed -e 's/.*tests="/tests=/' -e 's/" time=.*//' ); do  
        eval $v
        sum=$(( $sum + $tests ))
    done
    export num_tests=$sum

    sum=0
    for v in $(grep 'tests=' $dir/*.xml | sed -e 's/.*time="/time=/' -e 's/".*//' ); do  
        eval $v
        sum=$(echo "$sum + $time" | bc -l)
    done
    export tot_time=$sum

    sum=0
    for v in $(grep errors $dir/*.xml | grep -v 'errors="0"'| sed -e 's/.*errors="/errors=/' -e 's/".*//'); do  
        eval $v
        sum=$(echo "$sum + $errors" | bc -l)
    done
    export error_count=$sum

    export skipped=$(grep skipped $dir/*.xml | wc -l)
    coverage=$(tail -1 $(find $dir/../ -name 'coverage.report.*')| awk '{print $4}')
    export coverage
    refactor_count=$(tail -5 $(find $dir/../ -name 'email.txt' )| head -1| sed -e 's/.*">//' -e 's/<.*//')
    export refactor_count
    for x in $(tail -4  $dir/../results.log); do  eval $x ; done
    export FILES_CHECKED_COUNT PYLINT_ERROR_FILES_COUNT PYLINT_ERROR_COUNT PEP8_ERROR_COUNT
    #export branch="$arch_branch"
    $PATHTO/print_row.py >> $html_test_report
    echo '' >> $outfile
    echo branch=$branch >>$outfile
    echo num_tests=$num_tests error_count=$error_count skipped=$skipped tot_time=$tot_time>>$outfile
    echo FILES_CHECKED_COUNT=$FILES_CHECKED_COUNT PYLINT_ERROR_FILES_COUNT=$PYLINT_ERROR_FILES_COUNT>>$outfile
    echo PYLINT_ERROR_COUNT=$PYLINT_ERROR_COUNT PEP8_ERROR_COUNT=$PEP8_ERROR_COUNT>>$outfile
    echo '' >> $outfile
done
echo "</table></body></html>" >> $html_test_report

#link all the html coverage reports together on page $html_coverage_browser
echo "<html><head>coverage report build $BUILD_NUMBER</head><body><h1>Build $BUILD_NUMBER Coverage by Branch</h1>" >$html_coverage_browser
for L in $(find . -name index.html); do 
    pct=$(grep pc_cov $L| sed -e 's/.*">//' -e's/<.*//') 
    branch=$(echo $L | sed -e 's/.*output\///' -e 's/\/htmlcov.*//') 
    arch=$(echo $L | sed -e 's/\/output.*//' -e 's/\.\///')
    echo "<li><a href=\"$L\"> $arch $branch $pct</a>" >> $html_coverage_browser
done
echo "</body></html>" >> $html_coverage_browser
