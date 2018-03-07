#!/bin/bash

function define_names {
        NAME=$(basename $RECEPTOR| sed "s/\.pdbqt//")-$(basename $LIGAND| sed "s/\.pdbqt//")
	RANDOMIZED=$OUTPUT/$NAME.inp.pdbqt
	DOCKED=$OUTPUT/$NAME.pdbqt
        LOGFILE=$OUTPUT/$NAME.log
	APPENDEDFILE=$OUTPUT/$NAME.vinadocked.pdbqt
	PREFIX=$OUTPUT/_TEMP_.$NAME
}

function randomize_ligand {

	vina  --receptor $RECEPTOR  --ligand $LIGAND --out $RANDOMIZED   \
              --center_x $x  --center_y $y  --center_z $z     \
              --size_x  $dx  --size_y  $dy  --size_z  $dz     \
              --randomize_only        
}


function run_docking {
	vina  --receptor $RECEPTOR  --ligand $RANDOMIZED  --out $DOCKED  --log $LOGFILE  \
              --center_x $x  --center_y $y  --center_z $z     \
              --size_x  $dx  --size_y  $dy  --size_z  $dz     \
	      --cpu $CPUS  --exhaustiveness $EXHAUSTIVENESS --num_modes 10 --energy_range 2
	/bin/rm $RANDOMIZED

}

function check_error {
        # Stderr reported error
        if [ ! "$(cat $PREFIX.error| wc -l)" == "0" ]
        then
                echo "There was an error with $LIGAND"

        # Absense of log file
        elif [ ! -f $LOGFILE ]
        then 
                echo "There was an error with $LIGAND"

	# Abserse of docked file
        elif [ ! -f $DOCKED ]
        then
                echo "There was an error with $LIGAND"

        # Incorrect ending of log file
	elif [ ! "$(tail -1 $LOGFILE)" == "Writing output ... done." ]
	then 
		echo "There was an error with $LIGAND"

	# If everithing is OK
	else
		/bin/rm $PREFIX.error
	fi
}

function append_structures {
        model=1
	for score in $(head -n -1 $LOGFILE | tail -n +25| awk '{print $2}')
	do

		if [[ $(echo "$score <= $TRESHOLD" | bc) -eq 1 ]]
		then
			echo "
import sys
longstring=''
model=$model
n=0
for line in open('$DOCKED'):
    if line[0:5] == 'MODEL': n += 1
    if n == model:           longstring += line
sys.stdout.write(longstring)
			" > $PREFIX.py

		  	python $PREFIX.py >> $APPENDEDFILE
			/bin/rm $PREFIX.py
		fi
		
		((model++))
	done
}

function clean_files {
	/bin/rm $LOGFILE
	/bin/rm $DOCKED
}

#---------------------------------------------------------------------------------------------------


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


[ ! -d $OUTPUT ] && mkdir $OUTPUT

for LIGAND in $(ls $DATABASE/*.pdbqt)
do
	define_names
	for i in $(seq 1 1 $REPETITIONS)
	do
		randomize_ligand 2> $PREFIX.error
		run_docking      2> $PREFIX.error
		check_error
		append_structures
		clean_files
	done
	
done
