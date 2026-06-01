#!/bin/bash

user='xxx'
password='xx'
host='xxxxxxxxxxxxxxxxxxxxx'
port=3306
mycmd="mysql -u$user -p$password -h $host -P $port -p$password"
#mycmd="echo"


db1='ccountdb'

db2='clandb'

db3='decorationdb'

db4='editorpaydb'

db5='frienddb'

db6='gamedb'

db7='datadb'

db8='mailboxdb'

db9='msgdb'

db10='paydb'

db11='userdb'

db12='messagedb'

db13='activitydb'

db14='admindb'

db15='charmingtowndb'

db16='gameaidedb'

db17='bmgdata'

db18='statisticdb'

array_db=(${db1} ${db2} ${db3} ${db4} ${db5} ${db6} ${db7} ${db8} ${db9} ${db10} ${db11} ${db12} ${db13} ${db14} ${db15} ${db16} ${db17} ${db18})

echo ${array_db[@]} 




for dbname in ${array_db[@]};
do
	$mycmd -e "CREATE DATABASE IF NOT EXISTS $dbname DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
done