
file_name=$1

export i=0
while true;
do
    if [ -f ${file_name} ];
    then
        echo "Found the file ${file_name}"
        exit 0
    else
        i=`expr $i + 1`
        echo "sleeping iteration ${i}"
        sleep 5
    fi
done;
