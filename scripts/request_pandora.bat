@echo off

curl -o "D:\data\PANDORA_data\pandora_ccny.txt" https://data.pandonia-global-network.org/ManhattanNY-CCNY/Pandora135s1/L2/Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_nybg.txt" https://data.pandonia-global-network.org/BronxNY/Pandora180s1/L2/Pandora180s1_BronxNY_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_queens.txt" https://data.pandonia-global-network.org/QueensNY/Pandora55s1/L2/Pandora55s1_QueensNY_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_beltsville.txt" https://data.pandonia-global-network.org/BeltsvilleMD/Pandora80s1/L2/Pandora80s1_BeltsvilleMD_L2_rnvh3p1-8.txt
 
curl -o "D:\data\PANDORA_data\pandora_essex.txt" https://data.pandonia-global-network.org/EssexMD/Pandora75s1/L2/Pandora75s1_EssexMD_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_greenbelt2.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora2s1/L2/Pandora2s1_GreenbeltMD_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_greenbelt32.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora32s1/L2/Pandora32s1_GreenbeltMD_L2_rnvh3p1-8.txt

curl -o "D:\data\PANDORA_data\pandora_DC.txt" https://data.pandonia-global-network.org/WashingtonDC/Pandora140s1/L2/Pandora140s1_WashingtonDC_L2_rnvh3p1-8.txt


matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_ccny.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_nybg.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_queens.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_beltsville.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_essex.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_greenbelt2.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_greenbelt32.txt', 'D:\data\PANDORA_data\pandora_data.mat');"

matlab -batch "addpath('C:\Users\tely1\MATLAB Drive\NERTO\repo\scripts'); parse_pandora('D:\data\PANDORA_data\pandora_DC.txt', 'D:\data\PANDORA_data\pandora_data.mat');"
