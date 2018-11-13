# gwms-test
## Containers for unit testing and linting the GlideinWMS project

## Example Use Case:
<pre>
VER=6
BRANCH=master

BRANCH_DIR=$(echo $BRANCH | sed -e 's/\//_/g')

CONTAINER=$(docker run -dit dbox/gwms-test:sl${VER} /bin/bash)
docker exec -it $CONTAINER run_gwms_unit_tests $BRANCH
docker exec -it $CONTAINER run_gwms_pylint $BRANCH
docker cp $CONTAINER:/gwms_test/$BRANCH_DIR $BRANCH_DIR.sl${VER}
docker stop $CONTAINER
</pre>

## Example Build:
<pre>
export rel=6; docker build gwms-test --build-arg rel=$rel --tag ddbox/gwms-test:$rel
export rel=7; docker build gwms-test --build-arg rel=$rel --tag ddbox/gwms-test:$rel
</pre>




