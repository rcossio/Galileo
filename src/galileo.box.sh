#!/bin/bash

#---------------------------------------
#  Parsing arguments
#---------------------------------------

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--receptor)
    INPUT="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--center)
    x="$2"
    y="$3"
    z="$4"
    shift 
    shift 
    shift
    shift
    ;;
    -s|--size)
    dx="$2"
    dy="$3"
    dz="$4"
    shift 
    shift 
    shift
    shift
    ;;
esac
done


#---------------------------------------
#    Creating .PDB and .VMD
#---------------------------------------
PREFIX=_TEMP_
VMDTEMPLATE=$GALILEOHOME/bin/galileo.box.vmd

cat $INPUT > $PREFIX.pdb

$PYTHON $GALILEOHOME/bin/galileo.box.py $x $y $z $>> $PREFIX.pdb

sed -e "s/TEMPLATE/$PREFIX/g" $VMDTEMPLATE > $PREFIX.vmd

$VMD -e $PREFIX.vmd
/bin/rm $PREFIX.vmd
/bin/rm $PREFIX.pdb
