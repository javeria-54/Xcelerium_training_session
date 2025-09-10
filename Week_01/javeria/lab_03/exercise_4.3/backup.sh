#!/bin/bash

backupdir="/mnt/d/training_session/training_session"
mkdir -p "$backupdir" 
time=$(date +%F)
backupfile="backup_${time}.tar.gz"

tar czf "${backupdir}/${backupfile}" "/mnt/d/training_session/training_session/Week_01"
echo "backup created ${backupdir}/${backupfile}"

 