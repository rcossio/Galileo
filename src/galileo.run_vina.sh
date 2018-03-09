#!/bin/bash

#-----------------------------------------
#    Detect input file name 
#-----------------------------------------

if [ "$1" == "-i" ]
then
    shift
    INPUT=$1
    shift
fi


#-----------------------------------------
#    Read input file and 
#    define variables 
#-----------------------------------------

while read -r line
do
    key=$(echo $line| awk '{print $1}')
    value1=$(echo $line| awk '{print $2}')
    value2=$(echo $line| awk '{print $3}')
    value3=$(echo $line| awk '{print $4}')

    if [ "$key" == "RECEPTOR" ]
    then
        RECEPTOR=$value1
    elif [ "$key" == "OUTPUT" ]
    then
        OUTPUT=$value1
    elif [ "$key" == "TRESHOLD" ]
    then
        TRESHOLD=$value1
    elif [ "$key" == "REPETITIONS" ]
    then
        REPETITIONS=$value1
    elif [ "$key" == "DATABASE" ]
    then
        DATABASE=$value1
    elif [ "$key" == "CENTER" ]
    then
        x=$value1
        y=$value2
        z=$value3
    elif [ "$key" == "SIZE" ]
    then
        dx=$value1
        dy=$value2
        dz=$value3
    elif [ "$key" == "CPUS" ]
    then
        CPUS=$value1
    elif [ "$key" == "EXHAUSTIVENESS" ]
    then
        EXHAUSTIVENESS=$value1
    fi

done < $INPUT


#-----------------------------------------
#    Create output folder 
#-----------------------------------------

[ ! -d $OUTPUT ] && mkdir $OUTPUT


#-----------------------------------------
#    Start the big loop, running over 
#    the ligands and repetitions
#
#    [Can we extend to multiple receptors?]
#    [Can we program the use of multipleCPUs?]
#-----------------------------------------

for LIGAND in $(ls $DATABASE/*.pdbqt)
do
	for repetition in $(seq 1 1 $REPETITIONS)
	do
                $GALILEOHOME/src/galileo.vina_step.sh
	done
done
