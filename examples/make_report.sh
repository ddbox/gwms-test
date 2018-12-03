#!/bin/bash

PATHTO=../$(dirname $0)

export BUILD_NUMBER=$1
cd $BUILD_NUMBER

$PATHTO/print_header.py > report.html

outfile=test_"$BUILD_NUMBER"_results.txt
echo "test $BUILD_NUMBER on $(date)" > $outfile
for dir in $(find .  -type d -name xml_reports); 
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
    coverage=$(tail -1 $dir../coverage.report.* | awk '{print $4}')
    export coverage
    for x in $(tail -4  $dir/../results.log); do  eval $x ; done
    export FILES_CHECKED_COUNT PYLINT_ERROR_FILES_COUNT PYLINT_ERROR_COUNT PEP8_ERROR_COUNT
    export branch="$arch_branch"
    $PATHTO/print_row.py >> report.html
    echo '' >> $outfile
    echo branch=$branch >>$outfile
    echo num_tests=$num_tests error_count=$error_count skipped=$skipped tot_time=$tot_time>>$outfile
    echo FILES_CHECKED_COUNT=$FILES_CHECKED_COUNT PYLINT_ERROR_FILES_COUNT=$PYLINT_ERROR_FILES_COUNT>>$outfile
    echo PYLINT_ERROR_COUNT=$PYLINT_ERROR_COUNT PEP8_ERROR_COUNT=$PEP8_ERROR_COUNT>>$outfile
    echo '' >> $outfile
done
echo "</table></body></html>" >> report.html
outfile='coverage_report.html'
echo "<html><head>coverage report build $BUILD_NUMBER</head><body><h1>Build $BUILD_NUMBER Coverage by Branch</h1>" >$outfile
for L in $(find . -name index.html); do 
    pct=$(grep pc_cov $L| sed -e 's/.*">//' -e's/<.*//') 
    branch=$(echo $L | sed -e 's/.*output\///' -e 's/\/htmlcov.*//') 
    arch=$(echo $L | sed -e 's/\/output.*//' -e 's/\.\///')
    echo "<li><a href=\"$L\"> $arch $branch $pct</a>" >> $outfile 
done
echo "</body></html>" >> $outfile
