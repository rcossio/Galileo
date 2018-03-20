#!/bin/bash


if [ "$1" == "-i" ]
then
    shift
    INPUT=$1
    shift
fi

while read -r line
do
    key=$(echo $line| awk '{print $1}')
    value1=$(echo $line| awk '{print $2}')
    value2=$(echo $line| awk '{print $3}')
    value3=$(echo $line| awk '{print $4}')

    if [ "$key" == "RECEPTOR" ]
    then
        export RECEPTOR=$value1
        export RECEPTORNAME=$(echo $RECEPTOR| sed -e "s/.pdbqt//")
    elif [ "$key" == "RECEPTOR_FILES" ]
    then 
        export RECEPTOR_FILES=$value1
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
    elif [ "$key" == "VINA_FILES" ]
    then
        export VINA_FILES=$value1
    elif [ "$key" == "CONSENSUS_RMSD" ]
    then
        export CONSENSUS_RMSD=$value1
    elif [ "$key" == "DIVERSITY_RMSD" ]
    then
        export DIVERSITY_RMSD=$value1
    fi

done < $INPUT


[ ! -d $OUTPUT ] && mkdir $OUTPUT

for VINADOCKED in $(cat $VINA_FILES)
do
        for repetition in $(seq 1 1 $REPETITIONS)
        do
                $GALILEOHOME/src/galileo.ad4_step.sh $VINADOCKED $repetition
        done
	$GALILEOHOME/src/galileo.ad4_consensus.sh $VINADOCKED
        
done

