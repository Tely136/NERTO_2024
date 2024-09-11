@echo off

curl -o "C:\NERTO_drive\PANDORA_data\pandora_ccny.txt" https://data.pandonia-global-network.org/ManhattanNY-CCNY/Pandora135s1/L2/Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_nybg.txt" https://data.pandonia-global-network.org/BronxNY/Pandora180s1/L2/Pandora180s1_BronxNY_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_queens.txt" https://data.pandonia-global-network.org/QueensNY/Pandora55s1/L2/Pandora55s1_QueensNY_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_beltsville.txt" https://data.pandonia-global-network.org/BeltsvilleMD/Pandora80s1/L2/Pandora80s1_BeltsvilleMD_L2_rnvh3p1-8.txt
 
curl -o "C:\NERTO_drive\PANDORA_data\pandora_essex.txt" https://data.pandonia-global-network.org/EssexMD/Pandora75s1/L2/Pandora75s1_EssexMD_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_greenbelt2.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora2s1/L2/Pandora2s1_GreenbeltMD_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_greenbelt32.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora32s1/L2/Pandora32s1_GreenbeltMD_L2_rnvh3p1-8.txt

curl -o "C:\NERTO_drive\PANDORA_data\pandora_DC.txt" https://data.pandonia-global-network.org/WashingtonDC/Pandora140s1/L2/Pandora140s1_WashingtonDC_L2_rnvh3p1-8.txt


matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_ccny.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_nybg.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_queens.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_beltsville.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_essex.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_greenbelt2.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_greenbelt32.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_DC.txt', 'C:\NERTO_drive\PANDORA_data\pandora_data.mat');"
