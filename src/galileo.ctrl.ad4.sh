#!/bin/bash

#-------------------------------------------
#    Capture the SIGINT signal
#    and terminate child processes
#-------------------------------------------

term() {
  echo -e "\nCaught SIGINT/SIGTERM signal!" 

  for child in $(jobs -p)
  do
      kill -TERM "$child" 2>/dev/null
  done
  exit
}

trap term SIGINT
trap term SIGTERM

#-----------------------------------------
#    Parse input file name 
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
        export X=$value1
        export Y=$value2
        export Z=$value3
    elif [ "$key" == "SIZE" ]
    then
        export DX=$value1
        export DY=$value2
        export DZ=$value3
    elif [ "$key" == "CPUS" ]
    then
        export CPUS=$value1
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
Tasks=0
for vinadocked in $(cat $VINA_FILES)
do
        if (( Tasks >= CPUS ))
        then
            wait -n
            ((Tasks--))
        fi

        #---------------------------------------------
        #    This is the task to send to each core
        #---------------------------------------------
        {
            for repetition in $(seq 1 1 $REPETITIONS)
            do
                    $GALILEOHOME/src/galileo.step.ad4.sh $vinadocked $repetition 2>&1
            done
	    $GALILEOHOME/src/galileo.aux.post-docking.sh $vinadocked  2>&1
        } &

        ((Tasks++))

done

#-------------------------------------------
#    Wait for all child processes to finish
#-------------------------------------------
wait

