#!/bin/bash

VINADOCKED="$1"
ligandname=$(basename $VINADOCKED| sed -e "s/.vinadocked.pdbqt//;s/$RECEPTORNAME\-//") 
 
NAME=$RECEPTORNAME-$ligandname
LIGAND=$ligandname.pdbqt
APPENDEDFILE=$OUTPUT/$NAME.ad4docked.pdbqt
CONSENSUS=$OUTPUT/$NAME.consensus.pdbqt
DIVERSE=$OUTPUT/$NAME.diverse.pdbqt

if [ -f $APPENDEDFILE ]
then
	$PYTHON $GALILEOHOME/src/galileo.consensus_models.py $VINADOCKED $APPENDEDFILE $CONSENSUS_RMSD $CONSENSUS
        $PYTHON $GALILEOHOME/src/galileo.diversity_models.py $CONSENSUS $DIVERSITY_RMSD $DIVERSE
        [ "$(cat $CONSENSUS| wc -l)" == "0" ] && /bin/rm $CONSENSUS
        [ "$(cat $DIVERSE| wc -l)" == "0" ] && /bin/rm $DIVERSE

fi

