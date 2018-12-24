#!/bin/ksh


SCRIPT_PATH=`dirname $0`
SCRIPT_NAME="wrapper_bfg_product"
DATESTAMP=`date +%Y%m%d%`
TIMESTAMP=`date +%H%M%S%`
export CFG_FILE="$(dirname $0)/ukbs_bfg_skl_haas_config.cfg"
export LOG_NAME="wrapper_bfg_product_log"
export HTTPFS_SUCCESS_FILE="_SKL_QUEUE_PRODUCT_BFG_success.ctrl"
export SKL_HAAS_TABLE_NAME="SKL_QUEUE_PRODUCT_BFG"
export SKL_EDW_TABLE_NAME="SKL_HAAS_IN"
export IL_HAAS_TABLE_NAME="SKL_QUEUE_PRODUCT_BFG"
export IL_EDW_TABLE_NAME="DELTA_IL_PRODUCT_BFG"

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

function Mail_Sqoop_err
{
 mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_F} : ${SCRIPT_NAME}.ksh failed on `date +%Y.%m.%d-%H:%M:%S%` " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Sqoop of ${SKL_HAAS_TABLE_NAME} from DSS BTB HaaS to ${SKL_EDW_TABLE_NAME} REDW has failed.

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE}
*****************************************************************************
MAIL_BODY
}

function Mail_Sqoop_err1
{
 mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_F} : ${SCRIPT_NAME}.ksh failed on `date +%Y.%m.%d-%H:%M:%S%` " "${EMAIL_TO}" << MAIL_BODY
Hi Team,

Sqoop of ${IL_HAAS_TABLE_NAME} from DSS BTB HaaS to ${IL_EDW_TABLE_NAME} REDW has failed.

*****************************************************************************
Script path is ${SCRIPT_PATH} and the script name is ${SCRIPT_NAME}.ksh
Log File is : ${LOG_FILE}
*****************************************************************************
MAIL_BODY
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

Procedure ${1} has completed in ${2}.

${3} stage loading is completed

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
chmod 777 ${LOG_FILE}
echo  2>&1  | tee -a ${LOG_FILE}
echo "`date +%Y.%m.%d-%H:%M:%S%` : The wrapper ${SCRIPT_PATH}/${SCRIPT_NAME}.ksh execution started...!  "  2>&1  | tee -a ${LOG_FILE}

echo "`date +%Y.%m.%d-%H:%M:%S%` : "  2>&1  | tee -a ${LOG_FILE}

####### Check whether the script is already running
if [ -f  ${LOG_DIR}/running_${SCRIPT_NAME}.log  ]; then
        echo "`date +%Y.%m.%d-%H:%M:%S%` Script is ${SCRIPT_NAME} already running "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Script run for ${SCRIPT_NAME} will be terminated as it is already running  "  2>&1  | tee -a ${LOG_FILE}
        mailx -r "${EMAIL_FROM}" -s "${EMAIL_SUBJECT_F} : WRAPPER_DSS_11511 ALREADY RUNNING " "${EMAIL_TO}" << MAIL_BODY
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

######################################################### SQOOP SKL Export Watcher ################################################################

while [ true ]
do

ksh ${BIN_DIR}/edw_proc_call.ksh "PKG_HAAS_TO_DB_SQOOP_CTRL.PR_HAAS_TO_DB_SQOOP_CTRL_CHK" "OPS\$EDWGS" "('${SKL_EDW_TABLE_NAME}','${SKL_HAAS_TABLE_NAME}',:x);" ${ENV}

if [ $? -le 0 ]
then
  
  hour=`date +%H`
   
  if [ $hour -eq 14 ] 
  then
    
	echo "Sqoop Failed"
	Delete_Run_log
	Mail_Sqoop_err
	exit 1
  
  else
    
	sleep 300
	continue
	
  fi
  
elif [ $? -gt 0 ] 
then
  
  touch ${BIN_DIR}/bfg_product_skl_export_sqoop_${DATESTAMP}.success
  echo "Sqoop Completed"
  break

else 

  Delete_Run_log
  Mail_Sqoop_err
  exit 1
  
fi

done

SCH_NM="INT_OWNER_BUS_SKEY"
	PROC_NM="PKG_SKLHAAS_DROP_CREATE_PARTN.PR_BUS_DROP_CREATE_PARTITION"
	rm -f {LOG_DIR}/${SCH_NM}*${PROC_NM}*proc
	echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
	echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
	ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('SKL_HAAS_IN',SYSDATE,3,'DAILY',NULL,'Y',:x);" ${ENV}
	if [ $? -eq 0 ]; then
		echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} completed successfully "  2>&1  | tee -a ${LOG_FILE}
	else
		echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
		Mail_error "${PROC_NM}" "${SCH_NM}"
		Delete_Run_log
	fi

SCH_NM="INT_OWNER_BUS_SKEY"
	PROC_NM="PKG_SKLHAAS_DROP_CREATE_PARTN.PR_BUS_DROP_CREATE_PARTITION"
	rm -f {LOG_DIR}/${SCH_NM}*${PROC_NM}*proc
	echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
	echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
	ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('SKL_HAAS_OUT',SYSDATE,3,'DAILY',NULL,'Y',:x);" ${ENV}
	if [ $? -eq 0 ]; then
		echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} completed successfully "  2>&1  | tee -a ${LOG_FILE}
	else
		echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
		Mail_error "${PROC_NM}" "${SCH_NM}"
		Delete_Run_log
	fi
	
######################################################### SKL keys generation #####################################################################

#arr_src_system[1]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG-NDP"
#arr_src_system[2]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG-NWP"
#arr_src_system[3]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG-FEO"
#arr_src_system[4]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG-PKG"
#arr_src_system[5]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG-SSV"
#arr_src_system[6]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG-NDP"
#arr_src_system[7]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG-NWP"
#arr_src_system[8]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG-FEO"	
#arr_src_system[9]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG-PKG"
#arr_src_system[10]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG-SSV"

arr_src_system[1]="SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG"
arr_src_system[2]="SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG"

for entity in "${arr_src_system[@]}"
do
#source_system_value=`echo ${entity}|tail -c 8`
case "${entity}" in
	"SKL_QUEUE_PRODUCT_BFG-PRODUCT-BFG")
	      p_skl_entity="SKL_PRODUCT"
		  p_seq_name="SKL_PRODUCT_SEQ"
		  p_skl_key="PRODUCT_KEY"
		  p_reuse_key="NEW"
		  p_reuse_source_system="ALL"
		  p_ss_key_append_value=""
		  p_ss_key_seperator=""
		  p_source_system="BFG"
		;;
	"SKL_QUEUE_PRODUCT_BFG-PRODUCT_ATTRIBUTE-BFG")
	      p_skl_entity="SKL_PRODUCT_ATTRIBUTE"
		  p_seq_name="SKL_PRODUCT_ATTRIBUTE_SEQ"
		  p_skl_key="PRODUCT_ATTRIBUTE_KEY"
		  p_reuse_key="REUSE"
		  p_reuse_source_system="ALL"
		  p_ss_key_append_value=""
		  p_ss_key_seperator=""
		  p_source_system="BFG"
		;;		
esac

hour_wip=`date +%H`

  SCH_NM="INT_OWNER_BUS_SKEY"
  		ret_val=2
  		counter=0
          PROC_NM="PKG_SKL_HAAS_GENERATE_BFG.PR_SKL_WIP"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}		
  		while [ $ret_val -eq 2 -a $hour_wip -ne 14 ]
  		do
             ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_source_system}','${entity}',:x);" ${ENV}
  		   ret_val=$?
  		   if [ $ret_val -eq 2 ]; then
  		      sleep 300
  			  counter=`expr $counter+1`
  		   fi
  		done
  		if [ $ret_val -eq 0 ]; then
            echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
  		elif [ $ret_val -eq 2 ]; then
  		  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
            Mail_error "SKL_WIP Lock Error in PKG_SKL_HAAS_GENERATE_BFG.PR_SKL_WIP for ${p_skl_entity}" "INT_OWNER_BUS_SKEY"
            Delete_Run_log
  		  exit 1
          else
            echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity}  Failed...! "  2>&1  | tee -a ${LOG_FILE}
            Mail_error "${PROC_NM}" "${SCH_NM}"
            Delete_Run_log
  		  exit 1
          fi

SCH_NM="INT_OWNER_BUS_SKEY"
  		ret_val=2
  		counter=0
          PROC_NM="PKG_SKL_HAAS_GENERATE_BFG.PR_SKL_REDW_GENERATION"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}		
  		while [ $ret_val -eq 2 -a $counter -lt 13 ]
  		do
           ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_skl_entity}','${p_source_system}','${p_seq_name}','${p_skl_key}','${p_reuse_key}','${p_reuse_source_system}',:x);" ${ENV}
  		   ret_val=$?
  		   if [ $ret_val -eq 2 ]; then
  		      sleep 300
  			  counter=`expr $counter+1`
  		   fi
  		done
  		if [ $ret_val -eq 0 ]; then
            echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
  		elif [ $ret_val -eq 2 ]; then
  		  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
            Mail_error "${p_skl_entity} Lock Error in PKG_SKL_HAAS_GENERATE_BFG.PR_SKL_REDW_GENERATION" "INT_OWNER_BUS_SKEY"
            Delete_Run_log
  		  exit 1
          else
            echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} Failed...! "  2>&1  | tee -a ${LOG_FILE}
            Mail_error "${PROC_NM}" "${SCH_NM}"
            Delete_Run_log
  		  exit 1
          fi
  		
  SCH_NM="INT_OWNER_BUS_SKEY"
          PROC_NM="PKG_SKL_HAAS_GENERATE_BFG.PR_SKL_HAAS_OUT"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${entity}','${p_source_system}',:x);" ${ENV}
          if [ $? -eq 0 ]; then
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
          else
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                  Mail_error "${PROC_NM}" "${SCH_NM}"
                  Delete_Run_log
  				exit 1
          fi		  

done		  
		

mv ${BIN_DIR}/bfg_product_skl_export_sqoop_*.success ${LOG_DIR}

ksh ${BIN_DIR}/edw_proc_call.ksh "PKG_HAAS_TO_DB_SQOOP_CTRL.PR_HAAS_TO_DB_SQOOP_CTRL_UPD" "OPS\$EDWGS" "('${SKL_EDW_TABLE_NAME}','${SKL_HAAS_TABLE_NAME}',:x);" ${ENV}

if [ $? -ne 0 ] 
then
  Mail_error "${PROC_NM}.${SCH_NM}" "In Progress to processed status updating package failed"
  Delete_Run_log
  exit 1
fi
		
################# SKL keys generation ############################



############################################ HTTPFS success file to start SKL HaaS import process ############################################



touch ${HTTPFS_DIR}/${HTTPFS_SUCCESS_FILE}

java -jar ${HTTPFS_DIR}/haas-httpfs-client-0.0.1.jar -copyFromLocal ${HTTPFS_DIR}/${HTTPFS_SUCCESS_FILE} ${TGT_HAAS_DIR}
java -jar ${HTTPFS_DIR}/haas-httpfs-client-0.0.1.jar -chmod 770 ${TGT_HAAS_DIR}/${HTTPFS_SUCCESS_FILE}

			
############################################ HTTPFS success file to start SKL HaaS import process ############################################

#exit 0 ##Please Remove Later

####################################################### IL Merge after SKL HaaS import process ###############################################

#sleep 10 mins has kept to wait for SKL haas import completion fron HAAS
Mail_success "SKL_GENERATION" "PRODUCT"
sleep 600


######################################################### SQOOP SKL Import Watcher ################################################################

while [ true ]
do

ksh ${BIN_DIR}/edw_proc_call.ksh "PKG_HAAS_TO_DB_SQOOP_CTRL.PR_HAAS_TO_DB_SQOOP_CTRL_CHK" "OPS\$EDWGS" "('${IL_EDW_TABLE_NAME}','${IL_HAAS_TABLE_NAME}',:x);" ${ENV}

if [ $? -le 0 ]
then
  
  hour=`date +%H`
   
  if [ $hour -eq 14 ] 
  then
    
	echo "Sqoop Failed"
	Delete_Run_log
	Mail_Sqoop_err1
	exit 1
  
  else
    
	sleep 300
	continue
	
  fi
  
elif [ $? -gt 0 ] 
then
  
  touch ${BIN_DIR}/bfg_product_skl_import_sqoop_${DATESTAMP}.success
  echo "Sqoop Completed"
  break

else 

  Delete_Run_log
  Mail_Sqoop_err1
  exit 1
  
fi

done
	
######################################################### SQOOP SKL Import Watcher #####################################################################

arr_src_system[1]="L_EDW_PRODUCT"
arr_src_system[2]="L_EDW_PRODUCT_ATTRIBUTE"
arr_src_system[3]="L_EDW_PRODUCT_PRODUCT_REL"


for entity in "${arr_src_system[@]}"
do
case "${entity}" in
	"L_EDW_PRODUCT")
	      p_primary_key="PRODUCT_KEY"
		  p_delta_sqoop_table="DELTA_EDW_PRODUCT_BFG"
		  p_final_table="FINAL_EDW_PRODUCT_BFG"
		  p_date_columns="EFFECTIVE_END_DT,EFFECTIVE_START_DT,SOURCE_CREATE_DATE,SOURCE_LAST_UPDATE_DATE"
		  p_history_table="H_EDW_PRODUCT"
		  p_hist_start_date="HIST_START_DATE"
		  p_hist_end_date="HIST_END_DATE"
		;;
	 "L_EDW_PRODUCT_PRODUCT_REL")
	      p_primary_key="MAIN_PRODUCT_KEY,LINKED_PRODUCT_KEY,LINKED_PRODUCT_REL_TYPE"
		  p_delta_sqoop_table="DELTA_EDW_PROD_PROD_REL_BFG"
		  p_final_table="FINAL_EDW_PROD_PROD_REL_BFG"
		  p_date_columns="SOURCE_CREATE_DATE,SOURCE_LAST_UPDATE_DATE"
		  p_history_table="H_EDW_PRODUCT_PRODUCT_REL"
		  p_hist_start_date="HIST_START_DT"
		  p_hist_end_date="HIST_END_DT"
		;;
	 "L_EDW_PRODUCT_ATTRIBUTE")
	      p_primary_key="PRODUCT_ATTRIBUTE_KEY"
		  p_delta_sqoop_table="DELTA_EDW_PRODUCT_ATTRIB_BFG"
		  p_final_table="FINAL_EDW_PRODUCT_ATTRIB_BFG"
		  p_date_columns=""
		  p_history_table="H_EDW_PRODUCT_ATTRIBUTE"
		  p_hist_start_date="HIST_START_DATE"
		  p_hist_end_date="HIST_END_DATE"
		;;
esac


SCH_NM="EDW_LOAD_STAGE_4"
          PROC_NM="PKG_HAAS_TO_IL_MERGE_GENERIC.PR_FINAL_STAGE_GENERATE"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_primary_key}','${p_delta_sqoop_table}','${p_final_table}','${entity}','${p_date_columns}',:x);" ${ENV}
          if [ $? -eq 0 ]; then
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
          else
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                  Mail_error "${PROC_NM} for ${entity}" "${SCH_NM}"
                  Delete_Run_log
  				exit 1
          fi
		  
SCH_NM="EDW_LOAD_STAGE_4"
          PROC_NM="PKG_HAAS_TO_IL_MERGE_GENERIC.PR_IL_MERGE"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_final_table}','${entity}','${p_primary_key}',:x);" ${ENV}
          if [ $? -eq 0 ]; then
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
          else
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                  Mail_error "${PROC_NM} for ${entity}" "${SCH_NM}"
                  Delete_Run_log
  				exit 1
          fi

SCH_NM="EDW_LOAD_STAGE_4"
          PROC_NM="PKG_HAAS_TO_IL_MERGE_GENERIC.PR_IL_HIST_MERGE"
          echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
          #ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_history_table}','${p_primary_key}','${p_final_table}','${p_hist_start_date}','${p_hist_end_date}',:x);" ${ENV}
          if [ $? -eq 0 ]; then
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} completed successfully "  2>&1  | tee -a ${LOG_FILE}
          else
                  echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} ${p_skl_entity} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                  #Mail_error "${PROC_NM}" "${SCH_NM}"
                  Delete_Run_log
          fi
		  
SCH_NM="EDW_LOAD_STAGE_4"
        PROC_NM="PR_TRUNCATE_STAGE"
        echo "`date +%Y.%m.%d-%H:%M:%S%` Schema Name is ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        echo "`date +%Y.%m.%d-%H:%M:%S%` Started the ${PROC_NM} IN ${SCH_NM} "  2>&1  | tee -a ${LOG_FILE}
        ksh ${BIN_DIR}/edw_proc_call.ksh $PROC_NM $SCH_NM "('${p_delta_sqoop_table}',:x);" ${ENV}
        if [ $? -eq 0 ]; then
                echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} completed successfully "  2>&1  | tee -a ${LOG_FILE}
        else
                echo "`date +%Y.%m.%d-%H:%M:%S%` ${PROC_NM} IN ${SCH_NM} Failed...! "  2>&1  | tee -a ${LOG_FILE}
                Mail_error "${PROC_NM}" "${SCH_NM}"
                Delete_Run_log
				exit 1
        fi
	  
done

####################################################### IL Merge after SKL HaaS import process ###############################################

ksh ${BIN_DIR}/edw_proc_call.ksh "PKG_HAAS_TO_DB_SQOOP_CTRL.PR_HAAS_TO_DB_SQOOP_CTRL_UPD" "OPS\$EDWGS" "('${IL_EDW_TABLE_NAME}','${IL_HAAS_TABLE_NAME}',:x);" ${ENV}
Mail_success "IL_GENERATION" "PRODUCT"

if [ $? -ne 0 ] 
then
  Mail_error "${PROC_NM}.${SCH_NM}" "In Progress to processed status updating package failed"
  Delete_Run_log
  exit 1
else
 Delete_Run_log
 exit 0
fi


