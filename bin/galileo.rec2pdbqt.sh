#!/bin/bash

GALILEOHOME=/home/rodrigo/galileo2018
PYTHON=/usr/local/anaconda2/bin/python
VMD=/usr/local/bin/vmd
VINA=/usr/bin/vina
AUTODOCK4=/usr/bin/autodock4
AUTOGRID4=/usr/bin/autogrid4
BC=/usr/bin/bc

PYTHON=/usr/local/mgltools-1.5.6/bin/pythonsh
SCRIPT=/usr/local/mgltools-1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py

if [ $1 == -r ]
then

    shift
    for name in $@
    do

        $PYTHON $SCRIPT -r $name -o $(echo $name| sed "s/pdb/pdbqt/")

    done
fi

