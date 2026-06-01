#!/bin/bash
export COLUMNS=1024
textfile_directory=/home/ubuntu/textfile

mkdir -p $textfile_directory

echo "# HELP java_web_process_cpu_usage" > $textfile_directory/cpu.prom
echo "# TYPE java_web_process_cpu_usage gauge" >> $textfile_directory/cpu.prom
top -cbn1 | grep -v grep | grep java | awk '{print $9,$10,$19}' | awk -F'[ /]' '{print $1,$2,$7}' | awk '{printf "java_web_process_cpu_usage{jar=\"%s\"} %s\n", $3,$1}' >> $textfile_directory/cpu.prom

echo "# HELP java_web_process_memory_usage" > $textfile_directory/memory.prom
echo "# TYPE java_web_process_memory_usage gauge" >> $textfile_directory/memory.prom
top -cbn1 | grep -v grep | grep java | awk '{print $9,$10,$19}' | awk -F'[ /]' '{print $1,$2,$7}' | awk '{printf "java_web_process_memory_usage{jar=\"%s\"} %s\n", $3,$2}' >> $textfile_directory/memory.prom
