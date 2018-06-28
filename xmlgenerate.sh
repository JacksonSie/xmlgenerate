#!/usr/bin/env bash
# generate xml incident
# output XML file
# report for exchange with peers

dateStart=$(date -d '-7 days' +%Y%m%d)
dateEnd=$(date -d '-1 days' +%Y%m%d)

if [[ $# = 2 ]];then
        dateStart=$1
        dateEnd=$2
fi

mail_list='
        reporter@wt.moc.radio
        ,op@wt.moc.radio
        ,dev@wt.moc.radio
'

nowDir='/radio'
nowday=`date +%Y%m%d`
outputToday=$nowDir/xmloutput/$nowday
spoolFile=$outputToday/$nowday.xml
logFile=$nowDir/log/xmlLog.log.`date +%Y%m%d%H%M%S`
##########
queryFile=./xmlgenerate.sql
##########

mkdir $outputToday
touch $logFile
touch $spoolFile

export LANG='en_US.UTF-8'
export NLS_LANG=American_America.UTF8
export ORACLE_HOME=/opt/oracle/product/
export ORACLE_SID=something_SID
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$PATH
PASSFILE=/something/.PASSfile;USERNAME=user;usrpass=`cat $PASSFILE|grep $ORACLE_SID|grep $USERNAME|awk '{print $3}'` #;echo $USERNAME $usrpass

function get_incident_id(){
    grep -Po '(?<=<EVENT_ID>)[0-9]+(?=</EVENT_ID>)' $spoolFile |while read line ;do
        echo $line
    done
}

sqlplus $USERNAME/$usrpass@$ORACLE_SID @$queryFile $dateStart $dateEnd $spoolFile >> $logFile 2>&1

# 將各個incident編號分開為各個檔案
echo 'text processing'
get_incident_id | while read inc_id ;do
    inc_unit_file=$outputToday/$inc_id.xml
    inc_tmp_file=$outputToday/_inc_file.$RANDOM$RANDOM$RANDOM.txt
    echo catched $inc_id
    cp $spoolFile $inc_unit_file
    #變數代換會寫進spool file，要拿掉
    sed -i 's/Enter value.*//g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/old[[:blank:]]\{1,\}[[:digit:]]\{1,\}:.*//g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/new[[:blank:]]\{1,\}[[:digit:]]\{1,\}:.*//g' $inc_unit_file >> $logFile 2>&1

    #處理 header , frame
    sed -i 's/<?xml version="1.0"?>/<?xml version="1.0" encoding="UTF-8"?>/g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/ROWSET/radio/g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/<radio>/<radio xmlns="urn:ietf:params:xml:ns:iodef-1.0" version="1.00" lang="UTF-8">/g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/ROW/Incident/g'  $inc_unit_file >> $logFile 2>&1
    sed -i 's/^[[:blank:]]\{1,\}//g' $inc_unit_file >> $logFile 2>&1
    sed -i ':a;N;$!ba;s/\n//g' $inc_unit_file >> $logFile 2>&1  # replace enter

    #處理 oracle column 30 char limit
    sed -i 's/ooooooooooooooooooooooooooooo/oooooooooooooooooooooooooooooooooooooo/g' $inc_unit_file >> $logFile 2>&1
    sed -i 's/oooooooooooooooooooooooooooooo/oooooooooooooooooooooooooooooooooo/g' $inc_unit_file >> $logFile 2>&1
    echo '<?xml version="1.0" encoding="UTF-8"?><radio lang="UTF-8" version="1.00" xmlns="urn:ietf:params:xml:ns:iodef-1.0">' >> $inc_tmp_file
    grep -Po "<Incident><ORGANIZATION>radio institute</ORGANIZATION><EVENT_ID>$inc_id</EVENT_ID>(.*?)</Incident>" $inc_unit_file >> $inc_tmp_file
    echo "</radio>" >> $inc_tmp_file
    mv  $inc_tmp_file $inc_unit_file
done

null_record=$(egrep -i '<EVENT_ID>.*</EVENT_ID>' $spoolFile |wc -l )
mail_subject="XML incidents $dateStart - $dateEnd"
if [[ $null_record == 0 ]]; then
        echo '區間內無事故' >> $spoolFile
        echo '區間內無事故' >> $logFile
        mail_subject="$mail_subject(區間內無事故)"
fi

body="
incidents XML , date from $dateStart to $dateEnd \n
\n
SQL*Plus log :\n
\n
$(cat $logFile)
"

cd $outputToday
tar -zcvf $nowday.tgz ./* >> $logFile 2>&1
echo -e $body | mailx -a $nowday.tgz -s "$mail_subject" $mail_list  >> $logFile 2>&1

exit
