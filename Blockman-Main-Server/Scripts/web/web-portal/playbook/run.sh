#!/bin/bash
BRANCH=master

PWD=$(pwd)
SERVICE=$1

CODE_DIR=~/src/pickaxe
ROOT_DIR=$CODE_DIR/server/com/sandbox
BUILD_DIR=$PWD/build
APPS_DIR=$PWD/apps
JAR=-0.0.1-SNAPSHOT.jar
AP=ansible-playbook

eureka_config=$6

function update_code_from_github(){
    cd $CODE_DIR
    git checkout $BRANCH
    git pull origin $BRANCH
    cd -;
    return 0;
}

function copy_code_build_dir() {
    mkdir -p $BUILD_DIR
    rm -rf $BUILD_DIR/*
    echo "copy $ROOT_DIR/* to $BUILD_DIR"
    \cp -rf $ROOT_DIR/* $BUILD_DIR
}

function replace_eureka_config() {
    if [ ! -z "$2" ]; then
        echo "replace eureka config:"
        echo "sed -i -e \"s,{{ eureka_client_serviceUrl_defaultZone }},$2,g\" $1/src/main/resources/application.yml"
        sed -i -e "s,{{ eureka_client_serviceUrl_defaultZone }},$2,g" $1/src/main/resources/application.yml
    else
        echo 'no eureka config to replace'
    fi
}

function build() {
    cd $1
    chmod +x ./gradlew
    ./gradlew clean build
    cp -f $1/build/libs/${SERVICE}${JAR} $APPS_DIR
    cd -;
}

if [[ "$2" =~ ^(start|stop|restart|remove)$ ]]; then 
    echo "$2 $1 ..."
else
    echo "Usage 1: $0 $1 {start|stop|restart|remove} {spring_profile} {jvm_max_heap_memory} {jvm_min_heap_memory} {eureka_config}"
    exit 1
fi

if [[ "$2" == "remove)" ]]; then
    if [ $# -lt 6 ]; then 
        echo "Usage 2: $0 {service name} {start|stop|restart|remove} {spring_profile} {jvm_max_heap_memory} {jvm_min_heap_memory} {eureka_config}"
        exit 1
    fi
fi

if [[ "$2" != "remove" ]]; then
    update_code_from_github
    copy_code_build_dir

    SERVICE_TYPE=$(sed -e  's/.*-\(.*\)/\1/' <<< $SERVICE)
    target=$BUILD_DIR/$SERVICE_TYPE/$SERVICE

    replace_eureka_config $target $eureka_config

    build $target
    if [ ${SERVICE} == 'gamedata-service' ]; then
        $AP -i ./hosts-webservice ./yml/gamedata_service.yml --extra-vars "service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
    elif [ "${SERVICE:(-7)}" = "service" ]; then
        # eureka-service profile_name已经配置在hosts文件里面
        if [ ${SERVICE} == 'eureka-service' ]; then
            $AP -i ./hosts-webservice yml/service.yml --extra-vars "service=$1 action=$2 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
        else
            $AP -i ./hosts-webservice yml/service.yml --extra-vars "service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
        fi
    else
        $AP -i ./hosts-webservice yml/center.yml --extra-vars "service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
    fi
else
    $AP -i ./hosts-webservice yml/remove_service.yml --extra-vars "service=$1"
fi
