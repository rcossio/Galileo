
function define_names {
        NAME=$(basename $LIGAND| sed "s/\.pdbqt//")
	RANDOMIZED=$OUTPUT/$NAME.inp.pdbqt
	DOCKED=$OUTPUT/$NAME.out.pdbqt
        LOGFILE=$OUTPUT/$NAME.log
	APPENDEDFILE=$OUTPUT/$NAME.appended.pdbqt
	PREFIX=$OUTPUT/_TEMP_.$NAME
}

function randomize_ligand {

	./vina  --receptor $RECEPTOR  --ligand $LIGAND --out $RANDOMIZED   \
              --center_x $x  --center_y $y  --center_z $z     \
              --size_x  $dx  --size_y  $dy  --size_z  $dz     \
              --randomize_only        
}


function run_docking {
	./vina  --receptor $RECEPTOR  --ligand $RANDOMIZED  --out $DOCKED  --log $LOGFILE  \
              --center_x $x  --center_y $y  --center_z $z     \
              --size_x  $dx  --size_y  $dy  --size_z  $dz     \
	      --cpu 4  --exhaustiveness 20 --num_modes 10 --energy_range 2
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
RECEPTOR=R.1.pdbqt
OUTPUT=vina_results
TRESHOLD=8.0
REPETITIONS=3
DATABASE=pdbqt

x=45.0
y=51.0
z=41.0
dx=22.0
dy=20.0
dz=22.0

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
	exit
done
