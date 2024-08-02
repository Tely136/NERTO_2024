function C = temporal_correlation(temporal_differences, tau)

    C = exp(-temporal_differences);

    C(temporal_differences.*tau > tau) = 0;

end