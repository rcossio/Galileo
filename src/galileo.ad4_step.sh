#!/bin/bash

VINADOCKED="$1"
repetition="$2"
ligandname=$(basename $VINADOCKED| sed -e "s/.vinadocked.pdbqt//;s/$RECEPTORNAME\-//") 
 
NAME=$RECEPTORNAME-$ligandname
LIGAND=$ligandname.pdbqt
APPENDEDFILE=$OUTPUT/$NAME.ad4docked.pdbqt
CONSENSUS=$OUTPUT/$NAME.consensus.pdbqt
DIVERSE=$OUTPUT/$NAME.diverse.pdbqt

PREFIX=$OUTPUT/_TEMP_.$RECEPTORNAME-$ligandname-$repetition
DOCKED=$PREFIX.out.pdbqt
LOGFILE=$PREFIX.log



ligand_types=$(grep ATOM $(cat $VINA_FILES) | awk '!a[$12]++' | awk '{printf $12" "}')
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
move $DATABASE/$ligandname.pdbqt                # small molecule

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



autodock4 -p $PREFIX.dpf -l $LOGFILE             2> $PREFIX.error
grep '^DOCKED' $LOGFILE | cut -c9- > $DOCKED     2> $PREFIX.error
/bin/rm $PREFIX.dpf                              


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


model=1
for score in $(grep "Estimated Free Energy of Binding" $DOCKED | awk '{print $8}')
do

        if [[ $(echo "$score <= $TRESHOLD" | $BC) -eq 1 ]]
        then
                $PYTHON $GALILEOHOME/src/galileo.get_models.py $DOCKED $model >> $APPENDEDFILE
        fi

        ((model++))
done


/bin/rm $LOGFILE
/bin/rm $DOCKED

if [ -f $APPENDEDFILE ]
then
	$PYTHON $GALILEOHOME/src/galileo.consensus_models.py $VINADOCKED $APPENDEDFILE $CONSENSUS_RMSD $CONSENSUS
        $PYTHON $GALILEOHOME/src/galileo.diversity_models.py $CONSENSUS $DIVERSITY_RMSD $DIVERSE
        [ "$(cat $CONSENSUS| wc -l)" == "0" ] && /bin/rm $CONSENSUS
        [ "$(cat $DIVERSE| wc -l)" == "0" ] && /bin/rm $DIVERSE

fi

