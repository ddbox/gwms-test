# gwms-test
## Scientific Linux containers for unit testing and linting the GlideinWMS project

## Example Use Case:
<pre>

RECENT_BRANCHES=$(docker run  dbox/gwms-test new_gwms_branches 7)
for VER in 6 7; do
  CONTAINER=$(docker run -dit dbox/gwms-test:sl${VER} /bin/bash)
  for BRANCH in $RECENT_BRANCHES; do
    BRANCH_DIR=$(echo $BRANCH | sed -e 's/\//_/g')
    docker exec -it $CONTAINER run_gwms_unit_tests $BRANCH
    docker exec -it $CONTAINER run_gwms_pylint $BRANCH
    docker cp $CONTAINER:/test_dir/$BRANCH_DIR $BRANCH_DIR.sl${VER}
  done
  docker stop $CONTAINER
done
</pre>

## Example Build:
<pre>
export rel=7; docker build gwms-test --build-arg rel=$rel --tag $(whoami)/gwms-test:latest
export rel=7; docker build gwms-test --build-arg rel=$rel --tag $(whoami)/gwms-test:sl${rel}
export rel=6; docker build gwms-test --build-arg rel=$rel --tag $(whoami)/gwms-test:sl${rel}
</pre>




