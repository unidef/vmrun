#!/bin/bash

cmd=`ls src/`
for x in $cmd; do
    echo "flagging $x as executable"
    chmod +x src/$x
done
echo "done"
