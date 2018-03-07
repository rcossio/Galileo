#!/bin/bash
GALILEOHOME=/home/rodrigo/galileo2018
PYTHON=/usr/local/anaconda2/bin/python
VMD=/usr/local/bin/vmd
VINA=/usr/bin/vina
AUTODOCK4=/usr/bin/autodock4
AUTOGRID4=/usr/bin/autogrid4

        NAME=$(basename $VINADOCKED| sed "s/\.vinadocked\.pdbqt//")
        LIGAND=$NAME.pdbqt
        DOCKED=$OUTPUT/$NAME.out.pdbqt
        LOGFILE=$OUTPUT/$NAME.log
        APPENDEDFILE=$OUTPUT/$NAME.appended.pdbqt
        PREFIX=$OUTPUT/_TEMP_.$NAME
	CONSENSUS=$OUTPUT/$NAME.consensus.pdbqt
        DIVERSE=$OUTPUT/$NAME.diverse.pdbqt

}

function create_input {

	ligand_types=$(grep ATOM $VINAFILES/*.vinadocked.pdbqt | awk '!a[$12]++' | awk '{printf $12" "}')
	cat > $PREFIX.dpf <<EOF
autodock_parameter_version 4.2            # used by autodock to validate parameter set
seed pid time                             # seeds for random generator
unbound_model bound                       # state of unbound ligand
ligand_types $ligand_types
fld $RECEPTOR_FILES.maps.fld               # grid_data_file
EOF

	for atomtype in $ligand_types
	do
	        echo "map $RECEPTOR_FILES.$atomtype.map" >> $PREFIX.dpf
	done

	cat >> $PREFIX.dpf <<EOF
elecmap $RECEPTOR_FILES.e.map              # electrostatics map
desolvmap $RECEPTOR_FILES.d.map            # desolvation map
move $DATABASE/$NAME.pdbqt                # small molecule

tran0 random                              # initial coordinates/A or random
quaternion0 random                        # initial orientation
dihe0 random                              # initial dihedrals (relative) or random

set_ga                                    # set the above parameters for GA or LGA

set_psw1                                  # set the above pseudo-Solis & Wets parameters
ga_run 10                                 # do this many hybrid GA LS runs
EOF

}

function run_docking {
	autodock4 -p $PREFIX.dpf -l $LOGFILE
	grep '^DOCKED' $LOGFILE | cut -c9- > $DOCKED
	/bin/rm $PREFIX.dpf
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
        elif [ ! "$(grep 'Successful Completion' $LOGFILE |wc -l)" == "1" ]
        then
                echo "There was an error with $LIGAND"

        # If everithing is OK
        else
                /bin/rm $PREFIX.error
        fi
}

function append_structures {
        model=1
        for score in $(grep "Estimated Free Energy of Binding" $DOCKED | awk '{print $8}')
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

function consensus_structures {
	if [ -f $APPENDEDFILE ]
	then
		python $GALILEOHOME/src/Galileo.ConsensusModels.py $VINADOCKED $APPENDEDFILE $CONSENSUS_RMSD $CONSENSUS 
                python $GALILEOHOME/src/Galileo.DiversityModels.py $CONSENSUS $DIVERSITY_RMSD $DIVERSE
                [ "$(cat $DIVERSE| wc -l)" == "0" ] && /bin/rm $DIVERSE

	fi
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
    elif [ "$key" == "RECEPTOR_FILES" ]
    then 
        RECEPTOR_FILES=$value1
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
    elif [ "$key" == "VINAFILES" ]
    then
        VINAFILES=$value1
    elif [ "$key" == "CONSENSUS_RMSD" ]
    then
        CONSENSUS_RMSD=$value1
    elif [ "$key" == "DIVERSITY_RMSD" ]
    then
        DIVERSITY_RMSD=$value1
    fi

done < $INPUT


[ ! -d $OUTPUT ] && mkdir $OUTPUT

for VINADOCKED in $(ls $VINAFILES/*.vinadocked.pdbqt)
do
        define_names
        for i in $(seq 1 1 $REPETITIONS)
        do
		create_input  2> $PREFIX.error
                run_docking       2> $PREFIX.error
                check_error
                append_structures
                clean_files
        done
	consensus_structures

        #CORTO ACA PARA VER
        exit


done

