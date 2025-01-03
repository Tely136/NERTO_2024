@echo off

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_ccny.txt" https://data.pandonia-global-network.org/ManhattanNY-CCNY/Pandora135s1/L2/Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_nybg.txt" https://data.pandonia-global-network.org/BronxNY/Pandora180s1/L2/Pandora180s1_BronxNY_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_queens.txt" https://data.pandonia-global-network.org/QueensNY/Pandora55s1/L2/Pandora55s1_QueensNY_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_beltsville.txt" https://data.pandonia-global-network.org/BeltsvilleMD/Pandora80s1/L2/Pandora80s1_BeltsvilleMD_L2_rnvh3p1-8.txt
 
@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_essex.txt" https://data.pandonia-global-network.org/EssexMD/Pandora75s1/L2/Pandora75s1_EssexMD_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_greenbelt2.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora2s1/L2/Pandora2s1_GreenbeltMD_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_greenbelt32.txt" https://data.pandonia-global-network.org/GreenbeltMD/Pandora32s1/L2/Pandora32s1_GreenbeltMD_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_DC.txt" https://data.pandonia-global-network.org/WashingtonDC/Pandora140s1/L2/Pandora140s1_WashingtonDC_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_new_brunswick.txt" https://data.ovh.pandonia-global-network.org/NewBrunswickNJ/Pandora69s1/L2/Pandora69s1_NewBrunswickNJ_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_new_haven.txt" https://data.ovh.pandonia-global-network.org/NewHavenCT/Pandora64s1/L2/Pandora64s1_NewHavenCT_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_cornwall.txt" https://data.ovh.pandonia-global-network.org/CornwallCT/Pandora179s1/L2/Pandora179s1_CornwallCT_L2_rnvh3p1-8.txt

@REM curl -o "C:\NERTO_drive\PANDORA_data\pandora_madison.txt" https://data.ovh.pandonia-global-network.org/MadisonCT/Pandora186s1/L2/Pandora186s1_MadisonCT_L2_rnvh3p1-8.txt


matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_ccny.txt', 'C:\NERTO_drive\PANDORA_data\ccny_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_nybg.txt', 'C:\NERTO_drive\PANDORA_data\nybg_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_queens.txt', 'C:\NERTO_drive\PANDORA_data\queens_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_beltsville.txt', 'C:\NERTO_drive\PANDORA_data\beltsville_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_essex.txt', 'C:\NERTO_drive\PANDORA_data\essex_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_greenbelt2.txt', 'C:\NERTO_drive\PANDORA_data\greenbelt2_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_greenbelt32.txt', 'C:\NERTO_drive\PANDORA_data\greenebelt32_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_DC.txt', 'C:\NERTO_drive\PANDORA_data\DC_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_new_brunswick.txt', 'C:\NERTO_drive\PANDORA_data\new_brunswick_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_new_haven.txt', 'C:\NERTO_drive\PANDORA_data\new_haven_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_cornwall.txt', 'C:\NERTO_drive\PANDORA_data\cornwall_pandora_data.mat');"

matlab -batch "parse_pandora('C:\NERTO_drive\PANDORA_data\pandora_madison.txt', 'C:\NERTO_drive\PANDORA_data\madison_pandora_data.mat');"