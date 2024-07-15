clearvars; close all; clc;

load('/mnt/disks/data-disk/NERTO_2024/validation/tempo_time_series_data.mat');
% load merged data also in time series form for each site
load('/mnt/disks/data-disk/data/pandora_data/pandora_data.mat');

tempo_timetable = table2timetable(data_table);
tempo_timetable = tempo_timetable(tempo_timetable.QA==0&tempo_timetable.SZA<70&tempo_timetable.Cld_frac<0.2,:);

pandora_timetable = table2timetable(pandora_data);
pandora_timetable = pandora_timetable(pandora_timetable.qa==0|pandora_timetable.qa==1|pandora_timetable.qa==10|pandora_timetable.qa==11,:);

varnames = {'Site', 'TempoNO2', 'PandoraNO2'};
vartypes = {'string', 'double', 'double'};
comparison_table = timetable('Size', [0 3] ,'VariableTypes', vartypes, 'VariableNames', varnames, 'RowTimes', NaT(0, 'TimeZone', 'UTC'));

start_day = datetime(2024, 6, 1, 0,0,0, 'TimeZone', 'America/New_York');
end_day =   datetime(2024, 7, 1, 0,0,0, 'TimeZone', 'America/New_York');
period = timerange(start_day, end_day, "openright");

sites = unique(pandora_timetable.Site);

tempo_timetable = tempo_timetable(period,:);


pandora_timetable(period,:);

for j = 1:length(sites)
    site = sites(j);
    tempo_timetable_site = retime(tempo_timetable(strcmp(tempo_timetable.Site,site),3), 'regular', 'mean', 'TimeStep', minutes(1)); 
    tempo_timetable_site = rmmissing(tempo_timetable_site);

    pan = NaN(size(tempo_timetable_site));
    for i = 1:size(tempo_timetable_site,1)
        tempo_time = tempo_timetable_site.time(i);
        time_range = timerange(tempo_time-minutes(30), tempo_time+minutes(30));

        temp_pandora = pandora_timetable(time_range,:);

        pan(i) = mean(temp_pandora.NO2, "omitmissing");
    end

    site_vec = repmat(site, size(pan));
    temp_table = timetable(site_vec, tempo_timetable_site.NO2, pan,'RowTimes', tempo_timetable_site.time, 'VariableNames', varnames);
    comparison_table = [comparison_table; temp_table];
end

save('/mnt/disks/data-disk/NERTO_2024/validation/tempo_pandora_comparison.mat', 'comparison_table');