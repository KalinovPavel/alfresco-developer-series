#!/bin/sh

export COMPOSE_FILE_PATH=${PWD}/target/classes/docker/docker-compose.yml

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

start() {
    docker volume create maven-sdk-tutorial-acs-volume
    docker volume create maven-sdk-tutorial-db-volume
    docker volume create maven-sdk-tutorial-ass-volume
    docker-compose -f $COMPOSE_FILE_PATH up --build -d
}

start_share() {
    docker-compose -f $COMPOSE_FILE_PATH up --build -d maven-sdk-tutorial-share
}

start_acs() {
    docker-compose -f $COMPOSE_FILE_PATH up --build -d maven-sdk-tutorial-acs
}

down() {
    docker-compose -f $COMPOSE_FILE_PATH down
}

purge() {
    docker volume rm maven-sdk-tutorial-acs-volume
    docker volume rm maven-sdk-tutorial-db-volume
    docker volume rm maven-sdk-tutorial-ass-volume
}

build() {
    docker rmi alfresco-content-services-maven-sdk-tutorial:development
    docker rmi alfresco-share-maven-sdk-tutorial:development
    $MVN_EXEC clean install -DskipTests=true
}

build_share() {
    docker-compose -f $COMPOSE_FILE_PATH kill maven-sdk-tutorial-share
    yes | docker-compose -f $COMPOSE_FILE_PATH rm -f maven-sdk-tutorial-share
    docker rmi alfresco-share-maven-sdk-tutorial:development
    $MVN_EXEC clean install -DskipTests=true -pl maven-sdk-tutorial-share-jar
}

build_acs() {
    docker-compose -f $COMPOSE_FILE_PATH kill maven-sdk-tutorial-acs
    yes | docker-compose -f $COMPOSE_FILE_PATH rm -f maven-sdk-tutorial-acs
    docker rmi alfresco-content-services-maven-sdk-tutorial:development
    $MVN_EXEC clean install -DskipTests=true -pl maven-sdk-tutorial-platform-jar
}

tail() {
    docker-compose -f $COMPOSE_FILE_PATH logs -f
}

tail_all() {
    docker-compose -f $COMPOSE_FILE_PATH logs --tail="all"
}

test() {
    $MVN_EXEC verify -pl integration-tests
}

case "$1" in
  build_start)
    down
    build
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  reload_share)
    build_share
    start_share
    tail
    ;;
  reload_acs)
    build_acs
    start_acs
    tail
    ;;
  build_test)
    down
    build
    start
    test
    tail_all
    down
    ;;
  test)
    test
    ;;
  *)
    echo "Usage: $0 {build_start|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
esac