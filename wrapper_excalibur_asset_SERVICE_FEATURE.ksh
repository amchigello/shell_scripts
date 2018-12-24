#!/bin/ksh
#**********************************************************************************************
#  Author               : Panduranga Nayak
#  Summary              : Wrapper for  L_EDW_ASSET and L_EDW_ASSET_ATTRIBUTE - Excalibur.
################################################################################################

SCRIPT_PATH=`dirname $0`
SCRIPT_NAME="wrapper_excalibur_asset_SERVICE_FEATURE"
DATESTAMP=`date +%Y%m%d%`
TIMESTAMP=`date +%H%M%S%`	
export CFG_FILE="$(dirname $0)/config_svoc_excalibur.cfg"
export LOG_NAME="wrapper_excalibur_asset_SERVICE_FEATURE_log"


##### Calling the configuration file script ###############
if [ ! -f "${CFG_FILE}" ] ; then
   echo "`date +%Y.%m.%d-%H:%M:%S%` : The CFG ${CFG_FILE} is NOT available...!  "
        mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_W} : CFG - Not Available" "${EMAIL_TO}" << MAIL_BODY
Team,
The CFG_FILE "${CFG_FILE}" is not avilable
*****************************************************************************
Script path is ${SCRIPT_PATH} and the wrapper name is ${SCRIPT_NAME}.ksh

*****************************************************************************
MAIL_BODY
                exit 2
else
        echo "`date +%Y.%m.%d-%H:%M:%S%` : The CFG ${CFG_FILE} is available...!  "
   . ${CFG_FILE}
fi

#####Delete run log
function Delete_Run_log
{
if [ -f  ${LOG_DIR}/running_${SCRIPT_NAME}.log  ] ; then
        rm -f ${LOG_DIR}/running_${SCRIPT_NAME}.log
fi
}

function Mail_error
{
 mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_F} : ${SCRIPT_NAME}.ksh failed on `date +%Y.%m.%d-%H:%M:%S%` " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Procedure ${1} has Failed in ${2}.

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE}
*****************************************************************************
MAIL_BODY
}

function Mail_success
{
 mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_S} : ${SCRIPT_NAME}.ksh completed on `date +%Y.%m.%d-%H:%M:%S%` " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Procedure ${1} completed in ${2}.

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE}
*****************************************************************************
MAIL_BODY
}

function Mail_wait
{
 mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_S} : ${SCRIPT_NAME}.ksh waiting on `date +%Y.%m.%d-%H:%M:%S%` " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Procedure ${1} in ${2} waiting for 5 minutes.
Iteration ${3}

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE}
*****************************************************************************
MAIL_BODY
}

###########             Archive directories      ###################################
function Archiver
{
echo "`date +%Y.%m.%d-%H:%M:%S%` : Archiver function started.... "
echo  2>&1
echo  "`date +%Y.%m.%d-%H:%M:%S%` : Archive Test in LOG_DIR"  2>&1
FILE_EXIST_LOG_DIR=`ls ${LOG_DIR}/* 2>/dev/null`
if [ ! -z "${FILE_EXIST_LOG_DIR}" ] ; then
        echo  "`date +%Y.%m.%d-%H:%M:%S%` : Archiving to $ARC_LOG_DIR/ ...!  "  2>&1
           #chmod 777 $LOG_DIR/* 2>&1
        mv -f $LOG_DIR/* $ARC_LOG_DIR  2>&1
        echo $? 2>&1
fi
}

export LOG_FILE="${LOG_DIR}/${LOG_NAME}_${DATESTAMP}${TIMESTAMP}.log"
touch ${LOG_FILE}
chmod 775 ${LOG_FILE}
echo  2>&1  | tee -a ${LOG_FILE}
echo "`date +%Y.%m.%d-%H:%M:%S%` : The wrapper ${SCRIPT_PATH}/${SCRIPT_NAME}.ksh execution started...!  "  2>&1  | tee -a ${LOG_FILE}

echo "`date +%Y.%m.%d-%H:%M:%S%` : "  2>&1  | tee -a ${LOG_FILE}

####### Check whether the script is already running
if [ -f  ${LOG_DIR}/running_${SCRIPT_NAME}.log  ]; then
        echo "`date +%Y.%m.%d-%H:%M:%S%` Script is ${SCRIPT_NAME} already running "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Script run for ${SCRIPT_NAME} will be terminated as it is already running  "  2>&1  | tee -a ${LOG_FILE}
        mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_F} : WRAPPER ${SCRIPT_NAME} ALREADY RUNNING " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Script run will be terminated as a previous instance is already running.

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE_WATCHER}
*****************************************************************************
MAIL_BODY
    exit 1
fi
Archiver
touch ${LOG_DIR}/running_${SCRIPT_NAME}.log

################# ETL LOAD START ######################

parts[1]="SYS_P617016"
parts[2]="SYS_P617017"
parts[3]="SYS_P617018"
parts[4]="SYS_P616993"
parts[5]="SYS_P616994"
parts[6]="SYS_P616995"
parts[7]="SYS_P616996"
parts[8]="SYS_P616997"
parts[9]="SYS_P616998"
parts[10]="SYS_P616999"
parts[11]="SYS_P617000"
parts[12]="SYS_P617001"
parts[13]="SYS_P617002"
parts[14]="SYS_P617003"
parts[15]="SYS_P617004"
parts[16]="SYS_P617005"
parts[17]="SYS_P617006"
parts[18]="SYS_P617007"
parts[19]="SYS_P617008"
parts[20]="SYS_P617009"
parts[21]="SYS_P617010"
parts[22]="SYS_P617011"
parts[23]="SYS_P617012"
parts[24]="SYS_P617013"
parts[25]="SYS_P617014"
parts[26]="SYS_P617015"

for i in "${parts[@]}"
do
part_name=${i}

SCH_NM="EDW_LOAD_STAGE_BUSIL"
PROC_NM="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_STG0B_MIL"
echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
echo "`date +%Y.%m.%d-%H:%M:%S%` Started for partition ${part_name} "  2>&1  | tee -a ${LOG_FILE}
Mail_success "Partition ${part_name} Started" "${SCH_NM}"
ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${part_name}',:x);" $ENV
fi
	if [ $? -eq 0 ]; then
			echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} executed successfully "  2>&1  | tee -a ${LOG_FILE}
			Mail_success "${PROC_NM}" "${SCH_NM}"
	else
			echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
			Mail_error "${PROC_NM}" "${SCH_NM}"
			Delete_Run_log
			exit 1
	fi

STAGE_BUSIL[1]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_STG0"
STAGE_BUSIL[2]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_ATTRIB_STG0"
SCH_NM="EDW_LOAD_STAGE_BUSIL"
export strt_idx=1
export end_idx=2
while [ $strt_idx -le $end_idx ];
do
		PROC_NM=${STAGE_BUSIL[$strt_idx]}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
		if [$strt_idx -eq 1]; then
			Mail_success "Partition ${part_name} Started" "${SCH_NM}"
			ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${part_name}',:x);" $ENV
		else
			ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "(:x);" $ENV
		fi
			if [ $? -eq 0 ]; then
					echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} executed successfully "  2>&1  | tee -a ${LOG_FILE}
					Mail_success "${PROC_NM}" "${SCH_NM}"
			else
					echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
					Mail_error "${PROC_NM}" "${SCH_NM}"
					Delete_Run_log
					exit 1
			fi
		strt_idx=`expr $strt_idx + 1`
done 

SKL[1]="PKG_EXCALIBUR_ASSET_SKL.PR_EXCAILBUR_PROD_SKL"
SKL[2]="PKG_EXCALIBUR_ASSET_SKL.PR_EXCAILBUR_ASSET_SKL"
SKL[3]="PKG_EXCALIBUR_ASSET_SKL.PR_EXCAILBUR_BAC_SKL"
SKL[4]="PKG_EXCALIBUR_ASSET_SKL.PR_EXCAILBUR_ASSET_ATTRIB_SKL"

SCH_NM="INT_OWNER_BUS_SKEY"
export strt_idx=1
export end_idx=4
while [ $strt_idx -le $end_idx ];
do
		export iteration=0
		export ret_val=2
		PROC_NM=${SKL[$strt_idx]}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        while [ $ret_val -eq 2 -a $iteration -lt 13 ]
		do
		   ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "(:x);" ${ENV}
		   ret_val=$?
		   if [ $ret_val -eq 2 ]; then
			  sleep 300
			  iteration=`expr $iteration+1`
			  Mail_wait "${PROC_NM}" "${SCH_NM}" "${iteration}"
		   fi
		done
		if [ $ret_val -eq 0 ]; then
		  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} completed successfully "  2>&1  | tee -a ${LOG_FILE}
		  Mail_success "${PROC_NM}" "${SCH_NM}"
		elif [ $ret_val -eq 2 ]; then
		  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
		  Mail_error "${PROC_NM}" "${SCH_NM} Table Locked"
		  Delete_Run_log
		  exit 1
		else
		  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
		  Mail_error "${PROC_NM}" "${SCH_NM}"
		  Delete_Run_log
		  exit 1
		fi
		strt_idx=`expr $strt_idx + 1`
done 

STAGE_BUSIL[1]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_STG1"
STAGE_BUSIL[2]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_STG2"
STAGE_BUSIL[3]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_STG3"
STAGE_BUSIL[4]="PKG_EXCALIBUR_ASSET_STG.PR_EXCALIBUR_ASSET_ATTRIB_STG1"
SCH_NM="EDW_LOAD_STAGE_BUSIL"
export strt_idx=1
export end_idx=4
while [ $strt_idx -le $end_idx ];
do
		PROC_NM=${STAGE_BUSIL[$strt_idx]}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
		ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "(:x);" $ENV
			if [ $? -eq 0 ]; then
					echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} executed successfully "  2>&1  | tee -a ${LOG_FILE}
					Mail_success "${PROC_NM}" "${SCH_NM}"
			else
					echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
					Mail_error "${PROC_NM}" "${SCH_NM}"
					Delete_Run_log
					exit 1
			fi
		strt_idx=`expr $strt_idx + 1`
done

SCH_NM="INT_OWNER_BUS_IL"
IL_MERGE[1]="PKG_EXCALIBUR_ASSET_IL.PR_L_EDW_ASSET"
IL_MERGE[2]="PKG_EXCALIBUR_ASSET_IL.PR_L_EDW_ASSET_ATTRIB"
export strt_idx=1
export end_idx=2
while [ $strt_idx -le $end_idx ];
do
		PROC_NM=${IL_MERGE[$strt_idx]}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "(:x);" $ENV
        if [ $? -eq 0 ]; then
                echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} executed successfully "  2>&1  | tee -a ${LOG_FILE}
				Mail_success "${PROC_NM}" "${SCH_NM}"
        else
                echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                Mail_error "${PROC_NM}" "${SCH_NM}"
				Delete_Run_log
                exit 1
        fi
		strt_idx=`expr $strt_idx + 1`
done 

Mail_success "Partition ${part_name} completed" "${SCH_NM}"

done

################# ETL END ############################
Delete_Run_log
exit 0

	