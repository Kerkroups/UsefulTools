#!/bin/bash

for i in $(cat $1)
do
    var="${i}"
    dirb https://$i $2 -X .pdf,.doc,.xls,.ppt,.odp,.ods,.docx,.xlsx,.pptx -S -R -N 404 -i > $var  &
done
wait
echo Finished
    
