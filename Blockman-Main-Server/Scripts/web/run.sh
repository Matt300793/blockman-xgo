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

RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

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
    echo -e "${ORANGE}copy $ROOT_DIR/* to $BUILD_DIR ${NC}"
    \cp -rf $ROOT_DIR/* $BUILD_DIR

    if [ ${SERVICE} == 'auth-center' ]; then
        keyFile=$PWD/jks/enter-pm.jks
        if [ -e ${keyFile} ]; then
            cp ${keyFile} $BUILD_DIR/center/auth-center/src/main/resources/
        else
            echo -e "${RED}${keyFile} not exists.${NC}"
            exit 1
        fi
    fi

    if [ ${SERVICE} == 'game-service' ]; then
        keyFile=$PWD/jks/enter-pm.jks
        if [ -e ${keyFile} ]; then
            cp ${keyFile} $BUILD_DIR/service/game-service/src/main/resources/
        else
            echo -e "${RED}${keyFile} not exists.${NC}"
            exit 1
        fi
    fi
}

function replace_eureka_config() {
    if [ ! -z "$2" ]; then
        echo -e "replace eureka config:"
        echo -e "${ORANGE}sed -i -e \"s,{{ eureka_client_serviceUrl_defaultZone }},$2,g\" $1/src/main/resources/application.yml ${NC}"
        sed -i -e "s,{{ eureka_client_serviceUrl_defaultZone }},$2,g" $1/src/main/resources/application.yml
    else
        echo -e "${RED}no eureka config to replace ${NC}"
    fi
}

function build() {
    cd $1
    chmod +x ./gradlew
    ./gradlew clean build 2>&1 | tee $PWD/build.log

    gstatus=`cat $PWD/build.log | egrep "^BUILD FAILED* "`
    if [[ $gstatus == *"BUILD FAILED"* ]]
        echo "build $SERVICE successful"
        cp -f $1/build/libs/${SERVICE}${JAR} $APPS_DIR
        cd -;
        return 0
    then
        echo "build $SERVICE failed"
        cd -;
        return 1
    fi
}

if [[ "$2" =~ ^(start|stop|restart|remove|update|build|update_jar|stop_service)$ ]]; then
    echo "$2 $1 ..."
else
    echo "Usage 1: $0 $1 {start|stop|restart|remove|update|build|update_jar|stop_service} {spring_profile} {jvm_max_heap_memory} {jvm_min_heap_memory} {eureka_config}"
    exit 1
fi

if [[ "$2" == "remove)" ]]; then
    if [ $# -lt 6 ]; then 
        echo "Usage 2: $0 {service name} remove"
        exit 1
    fi
fi

if [[ "$2" == "build" ]]; then
    update_code_from_github
    copy_code_build_dir

    eureka_config=$3
    SERVICE_TYPE=$(sed -e  's/.*-\(.*\)/\1/' <<< $SERVICE)
    target=$BUILD_DIR/$SERVICE_TYPE/$SERVICE

    replace_eureka_config $target $eureka_config

    build $target
    if [ $? -eq 1 ]; then
        exit 1
    fi
elif [[ "$2" == "update_jar" ]]; then
    $AP -i ./hosts-all yml/update_service_jar.yml --extra-vars "playdir=$PWD service=$1"
elif [[ "$2" == "stop_service" ]]; then
    $AP -i ./hosts-all yml/stop_service.yml --extra-vars "playdir=$PWD service=$1"
else

    if [[ "$2" != "remove" ]]; then
        update_code_from_github
        copy_code_build_dir

        SERVICE_TYPE=$(sed -e  's/.*-\(.*\)/\1/' <<< $SERVICE)
        target=$BUILD_DIR/$SERVICE_TYPE/$SERVICE

        replace_eureka_config $target $eureka_config

        build $target
        if [ $? -eq 1 ]; then
            exit 1
        fi
        if [ ${SERVICE} == 'gamedata-service' ]; then
            $AP -i ./hosts-webservice ./yml/gamedata_service.yml --extra-vars "playdir=$PWD service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
        elif [ "${SERVICE:(-7)}" = "service" ]; then
            # eureka-service profile_name已经配置在hosts文件里面
            if [ ${SERVICE} == 'eureka-service' ]; then
                ips=`grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' ./hosts-webservice`
                if [[ $ips == 2 ]]
                then
                    $AP -i ./hosts-webservice yml/modify_host.yml -u ubuntu
                fi
                $AP -i ./hosts-webservice yml/service.yml --extra-vars "playdir=$PWD service=$1 action=$2 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
            else
                $AP -i ./hosts-webservice yml/service.yml --extra-vars "playdir=$PWD service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
            fi
        else
            $AP -i ./hosts-webservice yml/center.yml --extra-vars "playdir=$PWD service=$1 action=$2 profile_name=$3 jvm_max_heap_memory=$4 jvm_min_heap_memory=$5"
        fi
    else
        $AP -i ./hosts-webservice yml/remove_service.yml --extra-vars "playdir=$PWD service=$1"
    fi

fi