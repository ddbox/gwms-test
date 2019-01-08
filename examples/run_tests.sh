#!/bin/bash -x

if [ "$IMAGE" = "" ]; then
    IMAGE=dbox/gwms-test
fi

if [ "$1" = "" ]; then
    DAYS=14
else
    DAYS=$1
fi

DOCKER=""
if [ -e "$HOME/docker" ]; then
   docker=${HOME}/docker
   DOCKER="$docker  -H tcp://131.225.67.229:2375"
   $DOCKER images > /dev/null 2>&1
   if [ $? -ne 0 ]; then
       DOCKER="$docker"
       $DOCKER images > /dev/null 2>&1
       if [ $? -ne 0 ]; then
           DOCKER=""
       fi
   fi 
fi
if [ "x$DOCKER" = "x"  ] ; then
   docker=$(which docker)
   DOCKER="$docker "
   $DOCKER images > /dev/null 2>&1
   if [ $? -ne 0 ]; then
       DOCKER=""
   fi
fi

if [ "x$DOCKER" = "x"  ] ; then
   echo docker not found
   exit 1
fi
echo "for I in $($DOCKER images | grep dbox | awk '{print $3}'); do $DOCKER rmi -f $I; done"
for I in $($DOCKER images | grep dbox | awk '{print $3}'); do $DOCKER rmi -f $I; done

$DOCKER images | grep gwms
$DOCKER pull $IMAGE
$DOCKER pull $IMAGE:sl6
$DOCKER pull $IMAGE:sl7
$DOCKER images | grep gwms

if [ "$SAVE_OLD_CONTAINERS_1" = "" ]; then
    for C in $($DOCKER ps -a | grep v3  | awk '{print $1}'); do $DOCKER rm -f "$C"; done
fi

BRANCHES=$($DOCKER run --rm $IMAGE new_branches "$DAYS")
CLIST=""
PERSIST="while [ 0 -eq 0 ]; do date; sleep 60; done;"
for rh in 6 7; do
    for branch in $BRANCHES; do 
        container=$(echo "$branch"| sed -e's/\//_/g' -e's/-/_/g')_sl$rh;  
        CLIST="$CLIST $container"
        if $DOCKER run -d --name "$container"  $IMAGE:sl$rh /bin/bash -c "$PERSIST" ; then
            echo "started containter $container"
        else
            echo "failed to start $container in [ $CLIST ] " 
            echo "project branch $branch" 
            exit 1
        fi
    done
done
echo "running jobs in the following containters:"
echo "$CLIST"

for rh in 6 7; do
    for branch in $BRANCHES; do
        container=$(echo "$branch"| sed -e's/\//_/g' -e's/-/_/g')_sl$rh;
        $DOCKER exec  -i "$container" setup_test_env  "$branch"
        $DOCKER exec -d "$container" run_unit_tests "$branch"
        $DOCKER exec -d "$container" run_pylint "$branch"
        $DOCKER exec -d "$container" run_futurize "$branch"
    done
done

#wait for jobs to finish
#PS_CMD='ps auxww | grep -iE "run_pylint|run_unit_tests|run_futurize" | grep local | grep -v grep'
PS_CMD='ps auxww | grep \/usr\/local\/bin | grep -v grep'
RUNNING=$(for C in $CLIST; do $DOCKER exec -i "$C" /bin/bash -c "$PS_CMD"; done | wc -l)

while [ "$RUNNING" -ne  0 ]; do
    echo "waiting on $RUNNING processes"
    date
    sleep 60
    RUNNING=$(for C in $CLIST; do $DOCKER exec -i "$C" /bin/bash -c "$PS_CMD"; done | wc -l)
done

#copy all the results back
#rm -rf output_6 output_7
test -d output_7 && mv output_7 "output_7.$(date +%s)"
test -d output_6 && mv output_6 "output_6.$(date +%s)"
mkdir -p output_6/output output_7/output

for C in $CLIST; do
    if [ "$(echo "$C" | grep sl7)" = "" ]; then
        #echo $DOCKER cp "$C":/test_dir/output output_6  
        $DOCKER cp "$C":/test_dir/output output_6
    else
        #echo $DOCKER cp "$C":/test_dir/output output_7 
        $DOCKER cp "$C":/test_dir/output output_7
    fi
done


if [ "$SAVE_OLD_CONTAINERS_2" = "" ]; then
    for C in $CLIST; do $DOCKER kill "$C" ; $DOCKER rm "$C"; done
fi

if [ "$TRAVIS_BUILD_NUMBER" != "" ]; then
    WORKSPACE=$TRAVIS_BUILD_DIR
    BUILD_NUMBER=$TRAVIS_BUILD_NUMBER
fi

if [ "$WORKSPACE/$BUILD_NUMBER" != "/" ]; then
    mkdir -p $WORKSPACE/$BUILD_NUMBER
    mv output_7 $WORKSPACE/$BUILD_NUMBER/sl7
    mv output_6 $WORKSPACE/$BUILD_NUMBER/sl6
fi

