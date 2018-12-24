#/***************************************************************/
# Program Name : 	edw_proc_call.ksh
# Author  : 		
# Creation Date : 	
# Description : 	wrapper to execute a PL SQL OBJECT	
# Input parameters : <PROC_NAME> <SCHEMA_NAME> <PARAM_STRING> <run time environment D,T,C,P>
# Output parameters: 	NA
# Modifications : a history of changes to the program
# <DD-MM-YYYY>   <Modifier Name>    <Description>
#/*************************************************************/

export CFG_FILE="$(dirname $0)/edw_proc_stdenvs.cfg"
if [ ! -f "${CFG_FILE}" ]; then
  print -u2 "Configuration file ${CFG_FILE} does not exist!"
  exit 2
fi

if [ $# -ne 4 ]; then
	print " Usage: $0 <PROC_NAME> <SCHEMA_NAME> <PARAM_STRING> <run time environment D,T,C,P> "
	exit 2
fi

TIMESTAMP=`date +%H%M%S%d%m%y%`

export PROC_NAME="$1"
export SCHEMA_NAME="$2"
export PARAM_STRING="$3"
export ENV="$4"

echo $SCHEMA_NAME
echo $PARAM_STRING
echo $ENV

PROC_CALL=${SCHEMA_NAME}.${PROC_NAME}$PARAM_STRING

. ${CFG_FILE} $ENV

echo $PROC_CALL    
echo $LOG_DIR
export LOG_FILE="${LOG_DIR}/Log_for_ASG.log"

PROCFILE="${LOG_DIR}/${SCHEMA_NAME}.${PROC_NAME}_`date +%d%m%y%H%M%S.%3N`.proc"

PROC_EXISTS=`ls -l $PROCFILE 2>/dev/null | wc -l`


if [ $PROC_EXISTS -ne 0 ] 
then
	print " Procedure ${PROC_NAME} is already under execution..! Exiting.."
	date_is=`date +%d-%m-%y`
	date_time="`date +%H:%M:%S`"
	echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|2|.proc file for this proc was present before execution|[$date_is $date_time] (0 seconds)">>$LOG_FILE
	exit 2
else
	touch $PROCFILE
fi

TIMESTAMP_START=`date +%H%M%S%d%m%y%`


ret_val=`sqlplus -s /nolog << EOF
conn $ORAUSER/$ORAPWD@$ORASID
whenever SQLERROR EXIT 1;
whenever OSERROR EXIT 1;
set serveroutput on;
set lines 500;
set feedback off;
set heading off;

set pages 0 lines 1024
set serveroutput on size 1000000

ALTER SESSION FORCE PARALLEL DDL PARALLEL 4;
ALTER SESSION FORCE PARALLEL DML PARALLEL 4;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 4;

var x varchar2(1000);

begin
  
 $PROC_CALL

end;
/

print x

ALTER SESSION DISABLE PARALLEL DDL;
ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL QUERY;

EOF
`
STATUS_MESSAGE=`echo $ret_val`

echo "Status message :: $STATUS_MESSAGE"
ret_code=`echo $STATUS_MESSAGE | awk -F"|" '{ print $1 }'`
ret_mesg=`echo $STATUS_MESSAGE | awk -F"|" '{ print $2 }'`
echo "ret_code :: $ret_code "
echo "ret_messg :: $ret_mesg"
TIMESTAMP_END=`date +%H%M%S%d%m%y%`

start_time=$TIMESTAMP_START
h1=`echo $start_time | cut -c 1,2`
m1=`echo $start_time | cut -c 3,4`
s1=`echo $start_time | cut -c 5,6`

end_time=$TIMESTAMP_END
h2=`echo $end_time | cut -c 1,2`
m2=`echo $end_time | cut -c 3,4`
s2=`echo $end_time | cut -c 5,6`

seconds=$(echo "$h2*3600+$m2*60+$s2-($h1*3600+$m1*60+$s1)" | bc)

date_is=`date +%d-%m-%y`
date_time="`date +%H:%M:%S`"


if [ "$ret_code" = "0" ]
then
	echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|$ret_code|$ret_mesg|[$date_is $date_time] ($seconds seconds)">>$LOG_FILE
	retval=0
elif [ "$ret_code" = "2" ]
then
    echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|$ret_code|$ret_mesg|[$date_is $date_time] ($seconds seconds)">>$LOG_FILE
	retval=2
elif [ "$ret_code" = "1" ]
then
	echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|$ret_code|$ret_mesg|[$date_is $date_time] ($seconds seconds)">>$LOG_FILE
	retval=1
elif [ "$ret_code" = "" ]
then
	echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|$ret_code|$ret_mesg|[$date_is $date_time] ($seconds seconds)">>$LOG_FILE
	retval=1
else
	echo "[$date_is]|$SCHEMA_NAME.$PROC_NAME|$ret_code|$ret_mesg|[$date_is $date_time] ($seconds seconds)">>$LOG_FILE
	retval=$ret_code
fi
rm -f $PROCFILE
exit $retval

