#!/bin/bash
GALILEOHOME=/home/rodrigo/galileo2018
PYTHON=/usr/local/anaconda2/bin/python
VMD=/usr/local/bin/vmd
VINA=/usr/bin/vina
AUTODOCK4=/usr/bin/autodock4
AUTOGRID4=/usr/bin/autogrid4


PREFIX=_TEMP_

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
    elif [ "$key" == "DATABASE" ]
    then
        DATABASE=$value1
    elif [ "$key" == "SPACING" ]
    then
        SPACING=$value1
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
    fi

done < $INPUT


[ ! -d "$(dirname $RECEPTOR_FILES)" ] && mkdir $(dirname $RECEPTOR_FILES)
receptor_types=$(grep ATOM $RECEPTOR | awk '!a[$12]++' | awk '{printf $12" "}')
ligand_types=$(grep ATOM $DATABASE/*.pdbqt | awk '!a[$12]++' | awk '{printf $12" "}')
nx=$(python -c "print '%1.0f'%($dx/float($SPACING))")
ny=$(python -c "print '%1.0f'%($dy/float($SPACING))")
nz=$(python -c "print '%1.0f'%($dz/float($SPACING))")

cat > $PREFIX.gpf <<EOF
npts $nx $ny $nz               
gridfld $RECEPTOR_FILES.maps.fld     
spacing $SPACING             
receptor_types $receptor_types 
ligand_types $ligand_types     
receptor $RECEPTOR           
gridcenter $x $y $z          
smooth 0.5                  
EOF

for atomtype in $ligand_types
do
	echo "map $RECEPTOR_FILES.$atomtype.map" >> $PREFIX.gpf
done

cat >> $PREFIX.gpf <<EOF
elecmap $RECEPTOR_FILES.e.map   
dsolvmap $RECEPTOR_FILES.d.map 
dielectric -0.1465    
EOF


echo "  Using the following .gpf :"
awk '{print "     " $0}' $PREFIX.gpf


autogrid4 -p $PREFIX.gpf -l $PREFIX.log -d

echo ""
echo "Galileo: Successful completion?"
grep Successful $PREFIX.log


/bin/rm $PREFIX.gpf
/bin/rm $PREFIX.log
