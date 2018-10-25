#!/bin/bash
#
#
#SBATCH -A SSS SFV
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -o job_%j_%N.out
#SBATCH -t 24:00:00
#SBATCH -J ROMS script

matlab -noFigureWindows -r ROMS_grid.m