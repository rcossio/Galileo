#!/bin/bash

#$        Put
#$        Here
#PBS      Info
#PBS      For
#SBATCH   Cluster
#SBATCH   Run


# Prepare receptor pdbqt files
../src/rec2pdbqt -r rec.pdbqt
#IDEAL
#galileo rec2pdbqt -r rec.pdbqt



# Visual inspection to set the box
../src/box.sh --receptor rec.pdbqt --center 45.0 51.0 41.0 --size 22.0 20.0 22.0
#IDEAL
#galileo box --receptor rec.pdbqt --center 45.0 51.0 41.0 --size 22.0 20.0 22.0


# Run vina calculations
../src/run.vina.sh -i vina.in
#IDEAL
#galileo vina -i vina.in


# Prepare receptor files for ad4
galileo prepare_ad4 -i ad4.in 



# Run ad4 calculations
galileo ad4 -i ad4.in
  
