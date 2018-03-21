#!/bin/bash


#-----------------------------------------
#    Define local names   
#-----------------------------------------
VinaDocked="$1"
Repetition="$2"
ReceptorName=$(echo $RECEPTOR| sed -e "s/.pdbqt//")
LigandName=$(basename $VinaDocked| sed -e "s/.vinadocked.pdbqt//;s/$ReceptorName\-//") 
 
Name=$ReceptorName-$LigandName
Ligand=$LigandName.pdbqt
Appended=$OUTPUT/$Name.ad4docked.pdbqt

Prefix=$OUTPUT/_TEMP_.$ReceptorName-$LigandName-$Repetition
Docked=$Prefix.out.pdbqt
LogFile=$Prefix.log


#-----------------------------------------
#    Erase previous temporary files  
#-----------------------------------------
[ -f $Prefix.error ] && /bin/rm $Prefix.error



#-----------------------------------------
#    Prepare input 
#-----------------------------------------

ligand_types=$(grep ATOM $(cat $VINA_FILES) | awk '!a[$12]++' | awk '{printf $12" "}'   2>> $Prefix.error) 
cat > $Prefix.dpf <<EOF
autodock_parameter_version 4.2            # used by autodock to validate parameter set
seed pid time                             # seeds for random generator
unbound_model bound                       # state of unbound ligand
ligand_types $ligand_types
fld $RECEPTOR_FILES.maps.fld               # grid_data_file
EOF

for atomtype in $ligand_types
do
        echo "map $RECEPTOR_FILES.$atomtype.map" >> $Prefix.dpf
done

cat >> $Prefix.dpf <<EOF
elecmap $RECEPTOR_FILES.e.map              # electrostatics map
desolvmap $RECEPTOR_FILES.d.map            # desolvation map
move $DATABASE/$LigandName.pdbqt                # small molecule

tran0 random                              # initial coordinates/A or random
quaternion0 random                        # initial orientation
dihe0 random                              # initial dihedrals (relative) or random

ga_pop_size 150                      # number of individuals in population
ga_num_evals 2500000                 # maximum number of energy evaluations
ga_num_generations 27000             # maximum number of generations
ga_elitism 1                         # top individuals to survive to next generation
ga_mutation_rate 0.02                # rate of gene mutation
ga_crossover_rate 0.8                # rate of crossover
set_ga                               # set the above parameters for GA or LGA

sw_max_its 300                       # iterations of Solis & Wets local search
sw_max_succ 4                        # consecutive successes before changing rho
sw_max_fail 4                        # consecutive failures before changing rho
sw_rho 1.0                           # size of local search space to sample
sw_lb_rho 0.01                       # lower bound on rho
ls_search_freq 0.06                  # probability of performing local search
set_psw1                             # set the above pseudo-Solis & Wets parameters

ga_run 10                            # do this many hybrid GA LS runs
EOF


#-----------------------------------------
#    Run docking
#-----------------------------------------

autodock4 -p $Prefix.dpf -l $LogFile             2>> $Prefix.error
grep '^DOCKED' $LogFile | cut -c9- > $Docked     2>> $Prefix.error
/bin/rm $Prefix.dpf                              2>> $Prefix.error


#-----------------------------------------
#    Clean Docked models 
#-----------------------------------------

model=1
for score in $(grep "Estimated Free Energy of Binding" $Docked | awk '{print $8}' 2>> $Prefix.error)
do

        if [[ $(echo "$score <= $TRESHOLD" | $BC) -eq 1 ]]
        then
            $PYTHON $GALILEOHOME/src/galileo.aux.get_models.py $Docked $model >> $Appended    2>> $Prefix.error
        fi

        ((model++))
done



#-----------------------------------------
#    Check missing files  
#    and other errors
#-----------------------------------------
# Stderr reported error
if [ ! "$(cat $Prefix.error| wc -l)" == "0" ]
then
        echo "There was an error with $Ligand"

# Absense of log file
elif [ ! -f $LogFile ]
then
        echo "There was an error with $Ligand"

# Abserse of docked file
elif [ ! -f $Docked ]
then
        echo "There was an error with $Ligand"

# Incorrect ending of log file
elif [ ! "$(grep 'Successful Completion' $LogFile |wc -l)" == "1" ]
then
        echo "There was an error with $Ligand"

# If everithing is OK
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

echo "Galileo: Completed AD4 step. Rec=$ReceptorName Lig=$LigandName Rep=$Repetition"

