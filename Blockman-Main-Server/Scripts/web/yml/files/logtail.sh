#!/bin/bash
INSTALLER_VERSION="1.3.0"

##Region
INTERNET_POSTFIX="-internet"
INNER_POSTFIX="-inner"
FINANCE_POSTFIX="-finance"
ACCELERATION_POSTFIX="-acceleration"

CN_HANGZHOU_FINANCE="cn-hangzhou-finance"
CN_SHANGHAI_FINANCE="cn-shanghai-finance"
CN_SHENZHEN_FINANCE="cn-shenzhen-finance"

##logtail package
PACKAGE_NAME="logtail-linux64.tar.gz"

##ilogtaild script
CONTROLLER_DIR="/etc/init.d"
CONTROLLER_FILE="ilogtaild"

##ilogtail binary
BIN_DIR="/usr/local/ilogtail"
BIN_FILE="ilogtail"

##config file
README_FILE="README"
CA_CERT_FILE="ca-bundle.crt"
CONFIG_FILE="ilogtail_config.json"

##arch
X64="x86_64"
X32="i386"

##os version
CENTOS_OS="CentOS"
UBUNTU_OS="Ubuntu"
DEBIAN_OS="Debian"
ALIYUN_OS="Aliyun"
OPENSUSE_OS="openSUSE"
OTHER_OS="other"

CURRENT_DIR=`dirname "$0"`
CURRENT_DIR=`cd $CURRENT_DIR; pwd`
cd $CURRENT_DIR

logError()
{
    echo -n '[Error]:   '  $*
    echo -en '\033[120G \033[31m' && echo [ Error ]
    echo -en '\033[0m'
}

REGION=""
ALIUID=""
HAS_META_SERVER=-1

refresh_meta()
{
    timeout=$1
    curl -s --connect-timeout $timeout http://100.100.100.200/latest/meta-data/region-id > /dev/null
    HAS_META_SERVER=$?
    if [ $HAS_META_SERVER -eq 0 ] && [ -z "$ALIUID" ]; then
        ALIUID=`curl -s http://100.100.100.200/latest/meta-data/owner-account-id`
        echo "fetch aliuid from meta server: $ALIUID"
    fi
}

# Test (with shorter timeout) if meta server is existing? If yes, fetch aliuid.
refresh_meta 1

normalize_region()
{
    # Convert all _ in $REGION to -.
    REGION=`echo $REGION | sed 's/_/-/g'`
    # Remove -vpc
    REGION=`echo $REGION | sed 's/-vpc//g'`
}

download_file()
{
    if [ $1 = "auto" ]; then
        if [ $HAS_META_SERVER -ne 0 ]; then
            # Double check, curl with longer timeout.
            refresh_meta 5
            if [ $HAS_META_SERVER -ne 0 ]; then
                echo "[FAIL] Sorry, fail to get region automatically, please specify region and try again."
                echo "[NOTE] 'auto' can only work on ECS VM."
                exit 1
            fi
        fi
        REGION=`curl -s http://100.100.100.200/latest/meta-data/region-id`
    fi
    echo "download file from region $REGION"

    package_address=""
    if [ `echo $REGION | grep "\b$CN_HANGZHOU_FINANCE_INTERNET\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-hangzhou-finance-1.oss-cn-hzfinance.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$CN_HANGZHOU_FINANCE\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-hangzhou-finance-1.oss-cn-hzfinance-internal.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$CN_SHENZHEN_FINANCE_INTERNET\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-shenzhen-finance-1.oss-cn-szfinance.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$CN_SHENZHEN_FINANCE\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-shenzhen-finance-1.oss-cn-szfinance-internal.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$CN_SHANGHAI_FINANCE_INTERNET\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-shanghai-finance-1.oss-cn-shanghai-finance-1.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$CN_SHANGHAI_FINANCE\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-shanghai-finance-1.oss-cn-shanghai-finance-1-internal.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$INTERNET_POSTFIX\b" | wc -l` -ge 1 ] \
        || [ `echo $REGION | grep "\b$ACCELERATION_POSTFIX\b" | wc -l` -ge 1 ]; then
        region_id=`echo $REGION | sed "s/$INTERNET_POSTFIX//g"`
        region_id=`echo $region_id | sed "s/$ACCELERATION_POSTFIX//g"`
        package_address="http://logtail-release-$region_id.oss-$region_id.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    elif [ `echo $REGION | grep "\b$INNER_POSTFIX\b" | wc -l` -ge 1 ]; then
        package_address="http://logtail-release-cn-hangzhou.oss-cn-hangzhou.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    else
        package_address="http://logtail-release-$REGION.oss-$REGION-internal.aliyuncs.com/linux64/logtail-linux64.tar.gz"
    fi
    wget $package_address -O $PACKAGE_NAME -t 1
    if [ $? != 0 ]; then
        logError "Download logtail install file from $package_address failed."
        logError "Can not find available package address for region {$REGION}."
        logError "Please confirm the region you specified and try again."
        rm -f $PACKAGE_NAME
        exit 1
    fi
}

# $1: config file path, must exist.
# return: install param, such as cn-hangzhou, cn-hangzhou-acceleration, etc.
# If can not find endpoint or region_id, echo nothing and return 1.
# If corp in cluster, echo config info and return 1.
get_install_param_from_config_file()
{
    install_param=""
    CONFIG_FILE_PATH=$1

    # Differentiate network type according to config_server_address and endpoint.
    # Step 1. endpoint == log-global.aliyuncs.com
    #   - true: Acceleration.
    #   - false: Step 2.
    # Step 2. config_server_address
    #   - *intranet/vpc.log.aliyuncs.com: VPC or traditional.
    #   - *share.log.aliyuncs.com: inner.
    #   - rest: internet.
    network_type=""
    endpoint=`cat $CONFIG_FILE_PATH | grep "endpoint" | head -n 1 \
        | awk -F\: '{print $2}' | sed 's/ //g' | sed 's/\"//g'`
    config_server_address=`cat $CONFIG_FILE_PATH | grep "config_server_address" \
        | awk -F\: '{print $2 ":" $3}' | sed 's/ //g' | sed 's/\"//g' | sed 's/,//g'`
    cluster=`cat $CONFIG_FILE_PATH | grep "cluster" | head -n 1 \
        | awk -F\: '{print $2}' | sed 's/ //g' | sed 's/\"//g' | sed 's/,//g'`
    region_id=`echo $config_server_address | awk -F. '{print $2}'`
    config_info="config_server_address($config_server_address), endpoint($endpoint), cluster($cluster)"

    if [ "$endpoint" = "" ] || [ "$region_id" = "" ] || [ "$cluster" = "" ]; then
        return 1
    elif [ `echo $cluster | grep "\bcorp\b" | wc -l` -ge 1 ]; then
        echo $config_info
        return 1
    fi

    if [ `echo $endpoint | grep "\blog-global.aliyuncs.com\b" | wc -l` -ge 1 ]; then
        network_type="acceleration"
    else
        if [ `echo $region_id | grep "\b-intranet\b" | wc -l` -ge 1 ] \
            || [ `echo $region_id | grep "\b-vpc\b" | wc -l` -ge 1 ]; then
            network_type="vpc"
            region_id=`echo $region_id | sed 's/-intranet//g'`
            region_id=`echo $region_id | sed 's/-vpc//g'`
        elif [ `echo $region_id | grep "\b-share\b" | wc -l` -ge 1 ]; then
            network_type="inner"
            region_id=`echo $region_id | sed 's/-share//g'`
        else
            network_type="internet"
        fi
    fi
    install_param=$region_id
    if [ "$network_type" != "vpc" ]; then
        install_param=$region_id-$network_type
    fi

    if [ "`echo $install_param | grep -E "^[0-9a-z\-]+$"`" = "" ]; then
        echo $config_info
        return 1
    fi
    echo $install_param
}

# Upgrade logtail according to local information.
do_upgrade()
{
    # Some necessary checks.
    $CONTROLLER_DIR/$CONTROLLER_FILE status
    if [ $? -ne 0 ]; then
        logError "Logtail status is not ok, stop upgrading"
        exit 1
    fi
    CONFIG_FILE_PATH=$BIN_DIR/$CONFIG_FILE
    if [ ! -f $CONFIG_FILE_PATH ]; then
        logError "Can not find config file: $CONFIG_FILE_PATH"
        exit 1
    fi
    if [ ! -f $BIN_DIR/ilogtail ]; then
        logError "Can not find logtail binary"
        exit 1
    fi

    # Download latest package according to install param.
    install_param=$(get_install_param_from_config_file $CONFIG_FILE_PATH)
    if [ $? -ne 0 ]; then
        if [ "$install_param" != "" ]; then
            logError "Can not upgrade for logtail with config like $install_param"
        else
            logError "Can not get install_param according to $CONFIG_FILE_PATH"
        fi
        exit 1
    fi
    REGION=$install_param
    rm -f $PACKAGE_NAME
    download_file $install_param
    if [ -f $PACKAGE_NAME ]; then
        echo $PACKAGE_NAME" download success"
    else
        logError $PACKAGE_NAME" download fail, exit"
        exit 1
    fi

    # Check if the latest logtail has already existed.
    tar -zxf $PACKAGE_NAME
    new_binary_version=`ls $CURRENT_DIR/logtail-linux64/bin/ilogtail_* | awk -F"_" '{print $NF}'`
    if [ -f $BIN_DIR/$BIN_FILE"_"$new_binary_version ]; then
        logError "Already up to date."
        rm -rf logtail-linux64
        rm -f $PACKAGE_NAME
        exit 1
    fi

    # Stop logtail and start upgrading.
    echo "Try to stop logtail..."
    for ((i=0;i<3;i++)) do
        $CONTROLLER_DIR/$CONTROLLER_FILE stop
        if [ $? -eq 0 ]; then
            break
        fi
        if [ $i -ne 2 ]; then
            logError "Stop logtail failed, sleep 3 seconds and retry..."
            sleep 3
        else
            rm -rf logtail-linux64
            rm -f $PACKAGE_NAME
            sleep 3
            $CONTROLLER_DIR/$CONTROLLER_FILE start
            logError "Stop logtail failed, exit: ",$status
            exit 1
        fi
    done
    echo "Stop logtail successfully."

    # If dir of current version is not exist, create and backup.
    current_binary_version=`ls -lh $BIN_DIR/$BIN_FILE | awk -F"_" '{print $NF}'`
    CURRENT_VERSION_DIR=$BIN_DIR/$current_binary_version
    if [ "$current_binary_version" != "" ] && [ ! -d $CURRENT_VERSION_DIR ]; then
        mkdir -p $CURRENT_VERSION_DIR
        cp $BIN_DIR/libPluginAdapter.so $CURRENT_VERSION_DIR/
        cp $BIN_DIR/libPluginBase.so $CURRENT_VERSION_DIR/
    fi
    # Create dir for new version.
    NEW_VERSION_DIR=$BIN_DIR/$new_binary_version
    mkdir -p $NEW_VERSION_DIR
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginAdapter.so $NEW_VERSION_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginBase.so $NEW_VERSION_DIR/

    # Override current version.
    cp $CURRENT_DIR/logtail-linux64/bin/$BIN_FILE"_"$new_binary_version $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/LogtailInsight $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginAdapter.so $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginBase.so $BIN_DIR/
    rm $BIN_DIR/$BIN_FILE
    ln -s $BIN_DIR/$BIN_FILE"_"$new_binary_version $BIN_DIR/$BIN_FILE
    cp $CURRENT_DIR/logtail-linux64/$README_FILE $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/resources/$CA_CERT_FILE $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/$CONTROLLER_FILE $CONTROLLER_DIR/
    chmod 755 $BIN_DIR -R
    chown root $BIN_DIR -R
    chgrp root $BIN_DIR -R
    chmod 755 $CONTROLLER_DIR/$CONTROLLER_FILE
    chown root $CONTROLLER_DIR/$CONTROLLER_FILE
    chgrp root $CONTROLLER_DIR/$CONTROLLER_FILE

    # Start logtail, print the latest info.
    $CONTROLLER_DIR/$CONTROLLER_FILE start
    if [ $? -eq 0 ]; then
        echo "Upgrade logtail success"
    else
        logError "Start logtail fail, you'd better reinstall logtail."
        rm -rf logtail-linux64
        rm -f $PACKAGE_NAME
        exit 1
    fi
    sleep 0.5
    appinfo=$BIN_DIR"/app_info.json"
    if [ -f $appinfo ]; then
        cat $appinfo
    fi
    rm -rf logtail-linux64
    rm -f $PACKAGE_NAME
}

do_install()
{
    REGION=$2
    normalize_region
    if [ $3 = "install" ]; then
        rm -f $PACKAGE_NAME
        download_file $2
    fi
    if [ -f $PACKAGE_NAME ]; then
        echo $PACKAGE_NAME" download success"
    else
        logError $PACKAGE_NAME" download fail, exit"
        exit 1
    fi
    tar -zxf $PACKAGE_NAME
    binary_version=`ls $CURRENT_DIR/logtail-linux64/bin/ilogtail_* | awk -F"_" '{print $NF}'`
    if [ ! -f $CURRENT_DIR/logtail-linux64/conf/$REGION"/"$CONFIG_FILE ]; then
        logError "Can not find specific config file " $CURRENT_DIR/logtail-linux64/conf/$REGION"/"$CONFIG_FILE
        rm -rf logtail-linux64
        rm -f $PACKAGE_NAME
        exit 1
    fi
    mkdir -p $BIN_DIR
    mkdir -p $CONTROLLER_DIR
    cp $CURRENT_DIR/logtail-linux64/bin/$BIN_FILE"_"$binary_version $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/LogtailInsight $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginAdapter.so $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/bin/libPluginBase.so $BIN_DIR/
    ln -s $BIN_DIR/$BIN_FILE"_"$binary_version $BIN_DIR/$BIN_FILE
    cp $CURRENT_DIR/logtail-linux64/$README_FILE $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/resources/$CA_CERT_FILE $BIN_DIR/
    cp $CURRENT_DIR/logtail-linux64/conf/$REGION"/"$CONFIG_FILE $BIN_DIR/$CONFIG_FILE
    cp $CURRENT_DIR/logtail-linux64/bin/$CONTROLLER_FILE $CONTROLLER_DIR
    echo "install logtail files success"
    chmod 755 $BIN_DIR -R
    chown root $BIN_DIR -R
    chgrp root $BIN_DIR -R
    chmod 755 $CONTROLLER_DIR/$CONTROLLER_FILE
    chown root $CONTROLLER_DIR/$CONTROLLER_FILE
    chgrp root $CONTROLLER_DIR/$CONTROLLER_FILE
    if [ ! -z "$ALIUID" ]; then
        mkdir -p /etc/ilogtail/users
        touch /etc/ilogtail/users/$ALIUID
    fi

    if [ $1 = $ALIYUN_OS ] || [ $1 = $CENTOS_OS ] || [ $1 = $OPENSUSE_OS ]; then
        chkconfig --add $CONTROLLER_FILE
        chkconfig $CONTROLLER_FILE on
        echo "chkconfig add ilogtaild success"
    elif [ $1 = $DEBIAN_OS ] || [ $1 = $UBUNTU_OS ]; then
        update-rc.d $CONTROLLER_FILE start 55 2 3 4 5 . stop 45 0 1 6 .
        echo "update-rc.d add ilogtaild success"
    else
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc0.d/K45$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc1.d/K45$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc2.d/S55$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc3.d/S55$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc4.d/S55$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc5.d/S55$CONTROLLER_FILE
        ln -s $CONTROLLER_DIR/$CONTROLLER_FILE /etc/rc.d/rc6.d/K45$CONTROLLER_FILE
        echo "add ilogtail into /etc/rc.d/ success"
    fi
    echo "install logtail success"
    $CONTROLLER_DIR/$CONTROLLER_FILE start
    if [ $? -eq 0 ]; then
        echo "start logtail success"
    else
        logError "start logtail fail"
    fi
    sleep 0.5
    appinfo=$BIN_DIR"/app_info.json"
    if [ -f $appinfo ]; then
        cat $appinfo
    fi
    rm -rf logtail-linux64
    rm -f $PACKAGE_NAME
}

do_uninstall()
{
    if [ -f $CONTROLLER_DIR/$CONTROLLER_FILE ]; then
        $CONTROLLER_DIR/$CONTROLLER_FILE stop
        if [ $? -eq 0 ]; then
            echo "stop logtail success"
        else
            logError "stop logtail fail"
        fi
    fi

    if [ $0 = $ALIYUN_OS ] || [ $1 = $CENTOS_OS ] || [ $1 = $OPENSUSE_OS ]; then
        chkconfig $CONTROLLER_FILE off
        chkconfig --del $CONTROLLER_FILE
        echo "chkconfig del ilogtaild success"
    elif [ $1 = $DEBIAN_OS ] || [ $1 = $UBUNTU_OS ]; then
        update-rc.d -f $CONTROLLER_FILE remove
        echo "update-rc.d del ilogtaild success"
    else
        if [ -f /etc/rc.d/rc0.d/K45$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc0.d/K45$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc1.d/K45$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc1.d/K45$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc2.d/S55$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc2.d/S55$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc3.d/S55$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc3.d/S55$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc4.d/S55$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc4.d/S55$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc5.d/S55$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc5.d/S55$CONTROLLER_FILE
        fi
        if [ -f /etc/rc.d/rc6.d/K45$CONTROLLER_FILE ]; then
            unlink /etc/rc.d/rc6.d/K45$CONTROLLER_FILE
        fi
        echo "del ilogtaild from /etc/rc.d/ success"
    fi

    if [ -d $BIN_DIR ] || [ -f $BIN_DIR ]; then
        rm -rf $BIN_DIR
    fi
    if [ -f $CONTROLLER_DIR/$CONTROLLER_FILE ]; then
        rm -f $CONTROLLER_DIR/$CONTROLLER_FILE
    fi
    echo "uninstall logtail success"
}

CN_BEIJING="cn-beijing"
CN_BEIJING_INTERNET=$CN_BEIJING$INTERNET_POSTFIX
CN_BEIJING_INNER=$CN_BEIJING$INNER_POSTFIX
CN_BEIJING_ACCELERATION=$CN_BEIJING$ACCELERATION_POSTFIX

CN_QINGDAO="cn-qingdao"
CN_QINGDAO_INTERNET=$CN_QINGDAO$INTERNET_POSTFIX
CN_QINGDAO_INNER=$CN_QINGDAO$INNER_POSTFIX
CN_QINGDAO_ACCELERATION=$CN_QINGDAO$ACCELERATION_POSTFIX

CN_SHANGHAI="cn-shanghai"
CN_SHANGHAI_INTERNET=$CN_SHANGHAI$INTERNET_POSTFIX
CN_SHANGHAI_INNER=$CN_SHANGHAI$INNER_POSTFIX
CN_SHANGHAI_FINANCE=$CN_SHANGHAI$FINANCE_POSTFIX
CN_SHANGHAI_FINANCE_INTERNET=$CN_SHANGHAI_FINANCE$INTERNET_POSTFIX
CN_SHANGHAI_ACCELERATION=$CN_SHANGHAI$ACCELERATION_POSTFIX

CN_HANGZHOU="cn-hangzhou"
CN_HANGZHOU_INTERNET=$CN_HANGZHOU$INTERNET_POSTFIX
CN_HANGZHOU_FINANCE=$CN_HANGZHOU$FINANCE_POSTFIX
CN_HANGZHOU_FINANCE_INTERNET=$CN_HANGZHOU_FINANCE$INTERNET_POSTFIX
CN_HANGZHOU_INNER=$CN_HANGZHOU$INNER_POSTFIX
CN_HANGZHOU_ACCELERATION=$CN_HANGZHOU$ACCELERATION_POSTFIX

CN_SHENZHEN="cn-shenzhen"
CN_SHENZHEN_INTERNET=$CN_SHENZHEN$INTERNET_POSTFIX
CN_SHENZHEN_FINANCE=$CN_SHENZHEN$FINANCE_POSTFIX
CN_SHENZHEN_FINANCE_INTERNET=$CN_SHENZHEN_FINANCE$INTERNET_POSTFIX
CN_SHENZHEN_INNER=$CN_SHENZHEN$INNER_POSTFIX
CN_SHENZHEN_ACCELERATION=$CN_SHENZHEN$ACCELERATION_POSTFIX

AP_NORTHEAST_1="ap-northeast-1"
AP_NORTHEAST_1_INTERNET=$AP_NORTHEAST_1$INTERNET_POSTFIX
AP_NORTHEAST_1_INNER=$AP_NORTHEAST_1$INNER_POSTFIX
AP_NORTHEAST_1_ACCELERATION=$AP_NORTHEAST_1$ACCELERATION_POSTFIX

EU_CENTRAL_1="eu-central-1"
EU_CENTRAL_1_INTERNET=$EU_CENTRAL_1$INTERNET_POSTFIX
EU_CENTRAL_1_INNER=$EU_CENTRAL_1$INNER_POSTFIX
EU_CENTRAL_1_ACCELERATION=$EU_CENTRAL_1$ACCELERATION_POSTFIX

ME_EAST_1="me-east-1"
ME_EAST_1_INTERNET=$ME_EAST_1$INTERNET_POSTFIX
ME_EAST_1_INNER=$ME_EAST_1$INNER_POSTFIX
ME_EAST_1_ACCELERATION=$ME_EAST_1$ACCELERATION_POSTFIX

US_WEST_1="us-west-1"
US_WEST_1_INTERNET=$US_WEST_1$INTERNET_POSTFIX
US_WEST_1_INNER=$US_WEST_1$INNER_POSTFIX
US_WEST_1_ACCELERATION=$US_WEST_1$ACCELERATION_POSTFIX

print_help()
{
    echo "Usage:"
    echo -e "\tlogtail.sh [install <REGION>] [uninstall] [install-local <REGION>] [upgrade]"
    echo "Parameter:"
    echo -e "\t<REGION>:"
    echo -e "\t(for all ECS VM in VPC) you can use 'auto' to ask logtail.sh decide your region automatically (./logtail.sh install auto)."
    echo -e "\t(for ECS VM if 'auto' not work) $CN_BEIJING $CN_QINGDAO $CN_SHANGHAI $CN_HANGZHOU $CN_SHENZHEN $AP_NORTHEAST_1 $EU_CENTRAL_1 $ME_EAST_1 $US_WEST_1, etc (./logtail.sh install $CN_BEIJING)."
    echo -e "\t(for Non-ECS VM or other IDC) $CN_BEIJING_INTERNET $CN_QINGDAO_INTERNET $CN_SHANGHAI_INTERNET $CN_HANGZHOU_INTERNET $CN_SHENZHEN_INTERNET $AP_NORTHEAST_1_INTERNET $EU_CENTRAL_1_INTERNET $ME_EAST_1_INTERNET $US_WEST_1_INTERNET, etc."
    echo -e "\t(for ECS VM in Finance) $CN_HANGZHOU_FINANCE $CN_HANGZHOU_FINANCE_INTERNET $CN_SHANGHAI_FINANCE $CN_SHANGHAI_FINANCE_INTERNET $CN_SHENZHEN_FINANCE $CN_SHENZHEN_FINANCE_INTERNET."
    echo -e "\t(for Machine inner Alibaba Group) $CN_BEIJING_INNER $CN_QINGDAO_INNER $CN_SHANGHAI_INNER $CN_HANGZHOU_INNER $CN_SHENZHEN_INNER $AP_NORTHEAST_1_INNER $EU_CENTRAL_1_INNER $ME_EAST_1_INNER $US_WEST_1_INNER, etc."
    echo -e "\t(for Global Acceleration) $CN_BEIJING_ACCELERATION $CN_QINGDAO_ACCELERATION $CN_SHANGHAI_ACCELERATION $CN_HANGZHOU_ACCELERATION $CN_SHENZHEN_ACCELERATION $AP_NORTHEAST_1_ACCELERATION $EU_CENTRAL_1_ACCELERATION $ME_EAST_1_ACCELERATION $US_WEST_1_ACCELERATION, etc."
    echo "Commands:"
    echo -e "\tinstall $CN_BEIJING:\t (recommend) auto download package, install logtail to /usr/local/ilogtail, for $CN_BEIJING region"
    echo -e "\tuninstall:\t uninstall logtail from /usr/local/ilogtail"
    echo -e "\tupgrade:\t upgrade logtail to latest version"
}

echo "logtail.sh version: "$INSTALLER_VERSION
echo
ARCH=$X64
arch_issue=`uname -m | tr A-Z a-z`
if [ `uname -m | tr A-Z a-z` = "x86_64" ]; then
    ARCH=$X64
else
    ARCH=$X32
    echo "linux x86 not supported, exit"
    exit 1
fi

OS_VERSION=$OTHER_OS
os_issue=`cat /etc/issue | tr A-Z a-z`

get_os_version()
{
    if [ `echo $os_issue | grep debian | wc -l` -ge 1 ]; then
        OS_VERSION=$DEBIAN_OS
    elif [ `echo $os_issue | grep ubuntu | wc -l` -ge 1 ]; then
        OS_VERSION=$UBUNTU_OS
    elif [ `echo $os_issue | grep centos | wc -l` -ge 1 ]; then
        OS_VERSION=$CENTOS_OS
    elif [ `echo $os_issue | grep 'red hat' | wc -l` -ge 1 ]; then
        OS_VERSION=$CENTOS_OS
    elif [ `echo $os_issue | grep aliyun | wc -l` -ge 1 ]; then
        OS_VERSION=$ALIYUN_OS
    elif [ `echo $os_issue | grep opensuse | wc -l` -ge 1 ]; then
        OS_VERSION=$OPENSUSE_OS
    fi
}

get_os_version
if [ $OS_VERSION = $OTHER_OS ]; then
    echo -e "Can not get os version from /etc/issue, try lsb_release"
    os_issue=`lsb_release -a`
    get_os_version
fi

if [ $OS_VERSION = $OTHER_OS ]; then
    echo -e "Can not get os version from lsb_release, try check specific files"
    if [ -f "/etc/redhat-release" ]; then
        OS_VERSION=$CENTOS_OS
    elif [ -f "/etc/debian_version" ]; then
        OS_VERSION=$DEBIAN_OS
    else
        logError "Can not get os verison"
    fi
fi

echo -e "OS Arch:\t"$ARCH
echo -e "OS Distribution:\t"$OS_VERSION
case $# in
    0)
        print_help
        exit 1
        ;;
    1)
        case $1 in
            uninstall)
                do_uninstall $OS_VERSION
                ;;
            upgrade)
                do_upgrade
                ;;
            *)
                print_help
                exit 1
                ;;
        esac
        ;;
    2)
        if [ $1 = "install" ] || [ $1 = "install-local" ]; then
            do_uninstall $OS_VERSION
            do_install $OS_VERSION $2 $1
        else
            print_help
            exit 1
        fi
        ;;
    *)
        print_help
        exit 1
        ;;
esac

exit 0
