#!/bin/bash

#-----------------------------------------
#    Define local names   
#-----------------------------------------
LIGAND="$1"
repetition="$2"

receptorname=$(basename $RECEPTOR| sed "s/\.pdbqt//")
ligandname=$(basename $LIGAND| sed "s/\.pdbqt//")
NAME=$receptorname-$ligandname
APPENDEDFILE=$OUTPUT/$NAME.vinadocked.pdbqt

PREFIX=$OUTPUT/_TEMP_.$receptorname-$ligandname-$repetition
DOCKED=$PREFIX.pdbqt
LOGFILE=$PREFIX.log
RANDOMIZED=$PREFIX.inp.pdbqt


#-----------------------------------------
#    Randomize ligand dihedrals  
#-----------------------------------------

vina  --receptor $RECEPTOR  --ligand $LIGAND --out $RANDOMIZED   \
      --center_x $x  --center_y $y  --center_z $z                \
      --size_x  $dx  --size_y  $dy  --size_z  $dz                \
      --randomize_only       2> $PREFIX.error 


#-----------------------------------------
#    Run docking
#-----------------------------------------

vina  --receptor $RECEPTOR  --ligand $RANDOMIZED  --out $DOCKED  --log $LOGFILE  \
      --center_x $x  --center_y $y  --center_z $z     \
      --size_x  $dx  --size_y  $dy  --size_z  $dz     \
      --cpu 1  --exhaustiveness $EXHAUSTIVENESS --num_modes 10 --energy_range 2      2> $PREFIX.error

/bin/rm $RANDOMIZED


#-----------------------------------------
#    Check missing files  
#    ad other errors
#-----------------------------------------
if [ ! "$(cat $PREFIX.error| wc -l)" == "0" ]
then
        echo "Galileo: There was an error with $LIGAND in VINA step. Check $PREFIX.error"

elif [ ! -f $LOGFILE ]
then 
        echo "Galileo: There was an error with $LIGAND in VINA step. There is no log file!"

elif [ ! -f $DOCKED ]
then
        echo "Galileo: There was an error with $LIGAND in VINA step. There is no output (.pdbqt) file!"

elif [ ! "$(tail -1 $LOGFILE)" == "Writing output ... done." ]
then 
	echo "Galileo: There was an error with $LIGAND in VINA step. File $LOGFILE does not end correctly."

else
	/bin/rm $PREFIX.error
fi


#-----------------------------------------
#    If there are errors, 
#    continue with next ligand
#-----------------------------------------
if [ -f $PREFIX.error ]
then
        break
fi


#-----------------------------------------
#    Clean docked models 
#-----------------------------------------
model=1
for score in $(head -n -1 $LOGFILE | tail -n +25| awk '{print $2}')
do

	if [[ $(echo "$score <= $TRESHOLD" | $BC) -eq 1 ]]
	then
	  	$PYTHON $GALILEOHOME/src/galileo.get_models.py $DOCKED $model >> $APPENDEDFILE
			
	fi
		
	((model++))
done

#-----------------------------------------
#    Clean remaining temporary files 
#-----------------------------------------

/bin/rm $LOGFILE
/bin/rm $DOCKED

