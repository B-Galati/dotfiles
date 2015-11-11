#!/bin/bash
#####################################################################################
##
## PREFERENCES
##

# filename for logfile
LOGFILE="/tmp/repairMKV.log"

# latest working mkvtoolnix version
MKVWORKS=5.8.0

##
#####################################################################################
##
## DO NOT EDIT ANYTHING BELOW FROM HERE, IF YOU DON'T KNOW WHAT YOU ARE DOING
##
#####################################################################################
checkMKV() {
  FILE=$1
  # temp filename for our corrected .mkv file
  FILEPATHTMP="${FILE}_tmp.mkv"

  echo "Filename: $FILE" >> $LOGFILE
  echo -e "\nFilename: $FILE"
  echo "Temp Filename: $FILEPATHTMP" >> $LOGFILE

  if [[ -n $FORCED ]]
  then
    repairMKV
  else
    checkCompression
    if [[ $? -eq 3 ]]
    then
      MKVVERSION=`mkvinfo --ui-language en_US "$FILE" | grep "Writing" | awk '{print $6}'`
      MKVVERSION=${MKVVERSION:1}  
      if [[ -z $MKVVERSION ]]
      then
        echo 'Unable to get the mkv version from your file!' | tee -a $LOGFILE
      else
        if [[ $MKVVERSION > $MKVWORKS ]]
        then
          if [[ $MKVMERGEVERSION > 5.8.0 ]]
          then
            checkDate
            if [[ $CREATEDATE < $MODIFYDATE ]]
            then
              echo "Repair is necessary, mkv file version is $MKVVERSION" | tee -a $LOGFILE
  	      if [[ -z $SIMULATION ]]
	      then
	        repairMKV
	      fi
	    else
              echo "Repair is not necessary, you already fixed that file" | tee -a $LOGFILE
            fi
          else
            echo "Repair is necessary, mkv file version is $MKVVERSION" | tee -a $LOGFILE
  	    if [[ -z $SIMULATION ]]
	    then
	      repairMKV
	    fi
          fi
        else  
          echo "Repair is not necessary, mkv file version is not higher than $MKVWORKS it is $MKVVERSION" | tee -a $LOGFILE
        fi
      fi
    fi
  fi
}

checkCompression() {
  COMPRESS=`mkvinfo --ui-language en_US "$FILE" | grep -i compress`
  if [[ -z $COMPRESS ]]
  then
    echo "File is not compressed"
    return 3
  else
    echo "Repair is needed, file is compressed"
    if [[ -z $SIMULATION ]]
    then
      repairMKV
      return $?
    else
      return 0
    fi
  fi
}

checkDate() {
  # get the date when the mkv was created and get the date when the file was last modified
  CREATEDATE=`mkvinfo --ui-language en_US "$FILE" | grep Date | awk -F ':' '{print $2":"$3":"$4}'`
  CREATEDATE=`date -u -d "$CREATEDATE" +%s`
  ## we add 1800 seconds (30min) to the $CREATEDATE because otherwise the $CREATEDATE will be always smaller than the $MODIFYDATE
  CREATEDATE=`expr $CREATEDATE + 1800`
  MODIFYDATE=`date -u -r "$FILE" +%s`
}

repairMKV() {
  echo "Starting with repair.." | tee -a $LOGFILE

  if [[ $MKVMERGEVERSION > 5.8.0 ]]
  then
    mkvmerge -o $FILEPATHTMP --compression -1:none --engage no_cue_duration,no_cue_relative_position $FILE | tee -a $LOGFILE
  else
    mkvmerge -o $FILEPATHTMP --compression -1:none $FILE | tee -a $LOGFILE
  fi

  # check if we had an error during the remerge process
  if [[ $? -eq 0 ]]
  then
    # delete the "defect" file
    rm "$FILE"
    # rename the new file to the original name
    mv "$FILEPATHTMP" "$FILE"
    echo "Repair successfully completed"
    return 0
  else
    echo "An error occured. Temp file will be deleted." >> $LOGFILE
    echo "An error occured, please check the logfile $LOGFILE. Temp file will be deleted."
    rm "$FILEPATHTMP"
    return 0
  fi
}

#####################################################################################
#####################################################################################
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
echo "#####################################################################################" >> $LOGFILE
date >> $LOGFILE
# installed mkvmerge version
MKVMERGEVERSION=`mkvmerge -V | awk '{print $2}'`
MKVMERGEVERSION=${MKVMERGEVERSION:1}
echo "Installed mkvtoolnix version: $MKVMERGEVERSION" >> $LOGFILE
# save the filename in a variable
FILEPATH="$1"
# if we get no argument script will stop
if [[ -z $FILEPATH ]]
then
  echo "No file or folder passed to the script. See help with ./repairMKV.sh -h"
  exit
fi

if [[ "$1" = "-h" ]]
then
  echo './repairMKV.sh <file or folder> [options]'
  echo -e "  \nOptions:"
  echo -e "   -s \t Simulation mode, no files will be altered."
  echo -e "   -f \t Forced mode, repair mkv anyway."
  echo -e "   -h \t Show this help."
  exit
fi

if [[ -n $2 ]]
then
  if [[ "$2" = "-s" ]]
  then
    echo 'This is a simulation!' | tee -a $LOGFILE
    SIMULATION=$2
  elif [[ "$2" = "-f" ]]
  then
    echo 'This is a forced repair!' | tee -a $LOGFILE
    FORCED=$2
  fi
fi
# check if the 2nd letter of the filepath is a /, if so then we remove the first letter. This is necessary for sickbeard.
if [[ "${FILEPATH:1:1}" = '/' && "${FILEPATH:0:1}" = u ]]
then
  FILEPATH=`echo ${FILEPATH:1}`
fi
# check if filepath is a folder
if [[ -d $FILEPATH ]]
then
  echo "Input argument is a folder: $FILEPATH" >> $LOGFILE
  # searching for files which end with .mkv and size min. 100MB (to skip the samples)
  for x in $(find $FILEPATH -name *.mkv -type f -size +100M) 
  do
    checkMKV $x
  done
# check if filepath is a file
elif [[ -f $FILEPATH ]]
then
  echo "Input argument is a file: $FILEPATH" >> $LOGFILE
  checkMKV $FILEPATH
else
  echo "Wrong input: $FILEPATH. This is not a file nor folder!"
fi
IFS=$SAVEIFS
