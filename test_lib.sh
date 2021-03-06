# some utility functions for testing
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$@"; "$@" || die "FAILED $*"; }

checkout_branch() {
    branch=$1
    if [ "x$branch" = "x" ]; then
        branch=master
    fi
    PDIR="$TEST_DIR/$PROJECT"
    if ! test -d "$PDIR" ; then
        cd $TEST_DIR
        git clone https://github.com/glideinWMS/glideinwms.git
    fi
    cd $PDIR
    currbranch=$(thisbranch)
    if [ "$branch" != "$currbranch" ]; then
        git checkout -f $branch
    fi
} 

thisbranch() {
  cd "$TEST_DIR/$PROJECT"
  echo $(git branch | grep '\*' | awk '{print $2}')
  cd -
}

prep_branch() {
    ci_br=$1
    orig=$(thisbranch)
    if [ "x$ci_br" = "x" ]; then
        ci_br='master'
    fi
    if [ "$ci_br" != "$orig" ]; then
        cd "$TEST_DIR/$PROJECT"/build/jenkins
        FILES=*
        for fn in $FILES; do
            git checkout $ci_br $fn
        done
    fi
}

prep_venv () {
    if ! test -f "$TEST_DIR/$PROJECT/LICENSE" ; then
        checkout_branch master
    fi

    if ! test -f "$TEST_DIR/$VIRTUAL_ENV"/bin/activate ; then
        prep_branch master
        cd $TEST_DIR
        source $PROJECT/build/jenkins/utils.sh
        setup_python_venv
    fi

}



