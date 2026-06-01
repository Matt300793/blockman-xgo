#!/bin/bash

BRANCH=$1
PUBLISH_ENV=$2
SERVICES="${@:3}"

GIT_DIR=/home/ubuntu/src/pickaxe
BUILD_DIR=$GIT_DIR/server/com/sandbox
JAR=-0.0.1-SNAPSHOT.jar
SERVICE_APPLICATION_YML=
CURREN_JAR_FILE=

function update_code_from_github(){
    cd $GIT_DIR
    git checkout $BRANCH
    git pull origin $BRANCH
    cd -;
    return 0;
}

function build() {
    service=$1
    service_type=$(sed -e  's/.*-\(.*\)/\1/' <<< $service)
    target=$BUILD_DIR/$service_type/$service
    
    cd $target
    chmod +x gradlew
    ./gradlew clean build 2>&1 | tee $PWD/gradlew.log
    gstatus=`cat ./gradlew.log | egrep "^BUILD FAILED* "`
    if [[ $gstatus == *"BUILD FAILED"* ]]
        echo "build $service successful"
    then
         cat ./gradlew.log
         return 1
    fi

    SERVICE_APPLICATION_YML=$target/src/main/resources/$service.yml
    CURREN_JAR_FILE=$target/build/libs/${service}${JAR}
    cd -;
    return 0
}

function upload_jar() {
    svc=$1
    echo "=================================="
    echo "uploading $CURREN_JAR_FILE"
    echo "=================================="

    s3_destination=s3://bmg-version-test/app/sg-beta/
    if [[ $PUBLISH_ENV == "pr" ]]; then
        s3_destination=s3://bmg-version-test/app/pr/
    fi
    if [[ $PUBLISH_ENV == "rev" ]]; then
        s3_destination=s3://bmg-version-test/app/IOSReview/
    fi
    if [[ $PUBLISH_ENV == "activity" ]]; then
        s3_destination=s3://bmg-version-test/app/activity/
    fi

    AWS_DEFAULT_REGION=ap-southeast-1 AWS_ACCESS_KEY_ID=AKIA3GAMCOURAZUGUJZC AWS_SECRET_ACCESS_KEY=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 aws s3 cp $CURREN_JAR_FILE $s3_destination
    if [[ $? != 0 ]]; then
        echo "upload $CURREN_JAR_FILE failed."
        exit 1
    fi
    if [[ -f $SERVICE_APPLICATION_YML ]]; then
        AWS_DEFAULT_REGION=ap-southeast-1 AWS_ACCESS_KEY_ID=AKIA3GAMCOURAZUGUJZC AWS_SECRET_ACCESS_KEY=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 aws s3 cp $SERVICE_APPLICATION_YML $s3_destination
        if [[ $? != 0 ]]; then
            echo "upload $SERVICE_APPLICATION_YML failed."
            exit 1
        fi
    fi
}

function build_and_upload_jar_to_s3() {

    update_code_from_github

    for svc in $SERVICES; do
        echo "=================================="
        echo "processing $svc"
        echo "=================================="

        build $svc
        if [[ $? == 1 ]]; then
            echo "build $svc failed, please retry $svc again."
            exit 1
        fi

        echo "=================================="
        echo "build $svc successful."
        echo "$CURREN_JAR_FILE"
        echo "$SERVICE_APPLICATION_YML"
        echo "=================================="

        upload_jar $svc
    done

}

function usage() {
    echo ""
    echo "Usage: $1 [branch_name] {env:test/pr/rev/activity} {services:auth-center}"
    echo "支持多个服务，例如：$1 garena-test test auth-center user-center user-service"
    echo ""
    exit 1
}

if [ "$#" -lt 3 ]; then
    usage $0
else
    envs=("test pr rev activity")
    if [[ ! " ${envs[*]} " =~ " $2 " ]]; then
        echo "env not valid"
        usage $0
    fi
fi

start_time=`date +%s`

build_and_upload_jar_to_s3

end_time=`date +%s`
echo execution time was `expr $end_time - $start_time` s.
