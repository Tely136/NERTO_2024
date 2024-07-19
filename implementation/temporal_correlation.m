function C = temporal_correlation(time1, time2, tau)
    temporal_distances = abs(time1 - time2);
    temporal_distances_numeric = temporal_distances ./ tau;

    C = exp(-temporal_distances_numeric);

    C(temporal_distances > tau) = 0;

end