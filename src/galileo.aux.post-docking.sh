#!/bin/bash

VinaDocked="$1"
ReceptorName=$(basename $RECEPTOR| sed "s/\.pdbqt//")
LigandName=$(basename $VinaDocked| sed -e "s/.vinadocked.pdbqt//;s/$ReceptorName\-//") 
 
Name=$ReceptorName-$LigandName
Ligand=$LigandName.pdbqt
Appended=$OUTPUT/$Name.ad4docked.pdbqt
Consensus=$OUTPUT/$Name.consensus.pdbqt
Diverse=$OUTPUT/$Name.diverse.pdbqt

if [ -f $Appended ]
then
	$PYTHON $GALILEOHOME/src/galileo.aux.consensus.py $VinaDocked $Appended $CONSENSUS_RMSD $Consensus
        $PYTHON $GALILEOHOME/src/galileo.aux.diversity.py $Consensus $DIVERSITY_RMSD $Diverse
        [ "$(cat $Consensus| wc -l)" == "0" ] && /bin/rm $Consensus
        [ "$(cat $Diverse| wc -l)" == "0" ] && /bin/rm $Diverse

fi

