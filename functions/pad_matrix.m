function M = pad_matrix(A, B)
    max_l = max(length(A), length(B));

    A_padded = [A; nan(max_l - length(A), 1)];
    B_padded = [B; nan(max_l - length(B), 1)];

    M = [A_padded B_padded];
end