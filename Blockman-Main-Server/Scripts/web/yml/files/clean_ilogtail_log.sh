#!/usr/bin/env sh
time=$1
dir=/usr/local/ilogtail
start(){
    find ${dir} -name '*.gz' -mtime +${time}
}
start
