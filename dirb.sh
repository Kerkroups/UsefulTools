#!/bin/bash

for i in $(cat $1)
do
    var="${i}"
    dirb https://$i $2 -X .pdf,.doc,.xls,.ppt,.odp,.ods,.docx,.xlsx,.pptx,.py,.db,.log,.dll,.zip,.tar,.php,.php3,.cnf,.git -S -R -N 404 -i > $var  &
done
wait
echo Finished
    
