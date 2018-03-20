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
        export RECEPTOR=$value1
    elif [ "$key" == "OUTPUT" ]
    then
        export OUTPUT=$value1
    elif [ "$key" == "TRESHOLD" ]
    then
        export TRESHOLD=$value1
    elif [ "$key" == "REPETITIONS" ]
    then
        export REPETITIONS=$value1
    elif [ "$key" == "DATABASE" ]
    then
        export DATABASE=$value1
    elif [ "$key" == "CENTER" ]
    then
        export x=$value1
        export y=$value2
        export z=$value3
    elif [ "$key" == "SIZE" ]
    then
        export dx=$value1
        export dy=$value2
        export dz=$value3
    elif [ "$key" == "CPUS" ]
    then
        export CPUS=$value1
    elif [ "$key" == "EXHAUSTIVENESS" ]
    then
        export EXHAUSTIVENESS=$value1
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
                $GALILEOHOME/src/galileo.vina_step.sh $LIGAND $repetition
	done
done
