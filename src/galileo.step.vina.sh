#!/bin/bash

#-----------------------------------------
#    Define local names   
#-----------------------------------------
Ligand="$1"
Repetition="$2"

ReceptorName=$(basename $RECEPTOR| sed "s/\.pdbqt//")
LigandName=$(basename $Ligand| sed "s/\.pdbqt//")
Name=$ReceptorName-$LigandName
Appended=$OUTPUT/$Name.vinadocked.pdbqt

Prefix=$OUTPUT/_TEMP_.$ReceptorName-$LigandName-$Repetition
Docked=$Prefix.pdbqt
LogFile=$Prefix.log
Randomized=$Prefix.inp.pdbqt


#-----------------------------------------
#    Erase previous temporary files  
#-----------------------------------------
[ -f $Prefix.error ] && /bin/rm $Prefix.error

#-----------------------------------------
#    Randomize Ligand dihedrals  
#-----------------------------------------

vina  --receptor $RECEPTOR  --ligand $Ligand --out $Randomized   \
      --center_x $X  --center_y $Y  --center_z $Z                \
      --size_x  $DX  --size_y  $DY  --size_z  $DZ                \
      --randomize_only       1> /dev/null 2>> $Prefix.error 


#-----------------------------------------
#    Run docking
#-----------------------------------------

vina  --receptor $RECEPTOR  --ligand $Randomized  --out $Docked  --log $LogFile  \
      --center_x $X  --center_y $Y  --center_z $Z     \
      --size_x  $DX  --size_y  $DY  --size_z  $DZ     \
      --cpu 1  --exhaustiveness $EXHAUSTIVENESS --num_modes 10 --energy_range 2      1> /dev/null 2>> $Prefix.error

/bin/rm $Randomized   2>> $Prefix.error



#-----------------------------------------
#    Clean Docked models 
#-----------------------------------------
model=1
for score in $(head -n -1 $LogFile | tail -n +25| awk '{print $2}'  2>> $Prefix.error)
do

	if [[ $(echo "$score <= $TRESHOLD" | $BC) -eq 1 ]]
	then
	  	$PYTHON $GALILEOHOME/src/galileo.aux.get_models.py $Docked $model >> $Appended     2>> $Prefix.error
			
	fi
		
	((model++))
done


#-----------------------------------------
#    Check missing files  
#    and other errors
#-----------------------------------------
if [ ! "$(cat $Prefix.error| wc -l)" == "0" ]
then
        echo "Galileo: There was an error with $Ligand in VINA step. Check $Prefix.error"

elif [ ! -f $LogFile ]
then
        echo "Galileo: There was an error with $Ligand in VINA step. There is no log file!"

elif [ ! -f $Docked ]
then
        echo "Galileo: There was an error with $Ligand in VINA step. There is no output (.pdbqt) file!"

elif [ ! "$(tail -1 $LogFile)" == "Writing output ... done." ]
then
        echo "Galileo: There was an error with $Ligand in VINA step. File $LogFile does not end correctly."

else
        /bin/rm $Prefix.error
fi


#-----------------------------------------
#    Clean remaining temporary files 
#-----------------------------------------

/bin/rm $LogFile 
/bin/rm $Docked


#-------------------------------------------
#     Report
#-------------------------------------------

echo "Galileo: Completed VINA step. Rec=$ReceptorName Lig=$LigandName Rep=$Repetition"

