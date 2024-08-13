function C = temporal_correlation(temporal_differences)

    C = exp(-temporal_differences);

    % C(temporal_differences.*tau > tau) = 0;
end