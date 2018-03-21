#!/bin/bash

#$        Put
#$        Here
#PBS      Info
#PBS      For
#SBATCH   Cluster
#SBATCH   Run

export PATH=$(pwd)/../bin:$PATH
# Prepare receptor pdbqt files
#galileo rec2pdbqt -r rec.pdbqt


# Visual inspection to set the box
#galileo box --receptor rec.pdbqt --center 45.0 51.0 41.0 --size 22.0 20.0 22.0
#or:
# galileo box -r rec.pdbqt -c 45.0 51.0 41.0 -s 22.0 20.0 22.0


# Run vina calculations
#ls -1 ligands/* > vina.list
#galileo vina -i vina.in


# Prepare receptor files for ad4
#galileo prepare_ad4 -i pad4.in 


# Run ad4 calculations
ls -1 galileo_results/*vinadocked.pdbqt > ad4.list
galileo ad4 -i ad4.in
  
