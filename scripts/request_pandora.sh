#!/bin/bash

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_ccny.txt https://data.pandonia-global-network.org/ManhattanNY-CCNY/Pandora135s1/L2/Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8.txt

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_nybg.txt https://data.pandonia-global-network.org/BronxNY/Pandora180s1/L2/Pandora180s1_BronxNY_L2_rnvh3p1-8.txt

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_queens.txt https://data.pandonia-global-network.org/QueensNY/Pandora55s1/L2/Pandora55s1_QueensNY_L2_rnvh3p1-8.txt

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_beltsville.txt https://data.pandonia-global-network.org/BeltsvilleMD/Pandora80s1/L2/Pandora80s1_BeltsvilleMD_L2_rnvh3p1-8.txt
 
wget -O /mnt/disks/data-disk/data/pandora_data/pandora_essex.txt https://data.pandonia-global-network.org/EssexMD/Pandora75s1/L2/Pandora75s1_EssexMD_L2_rnvh3p1-8.txt

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_greenbelt2.txt https://data.pandonia-global-network.org/GreenbeltMD/Pandora2s1/L2/Pandora2s1_GreenbeltMD_L2_rnvh3p1-8.txt

wget -O /mnt/disks/data-disk/data/pandora_data/pandora_greenbelt32.txt https://data.pandonia-global-network.org/GreenbeltMD/Pandora32s1/L2/Pandora32s1_GreenbeltMD_L2_rnvh3p1-8.txt


matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_ccny.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_nybg.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_queens.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_beltsville.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_essex.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_greenbelt2.txt'); exit"

matlab -nodisplay -nosplash -r "parse_pandora('/mnt/disks/data-disk/data/pandora_data/pandora_greenbelt32.txt'); exit"
