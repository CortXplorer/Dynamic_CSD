function id_matrix = rec_loop2_inner(levels, level_vec, id_matrix, current_factor, perm0)

if current_factor == length(levels),
    loopto = levels(current_factor);
    for iLevel = 1:loopto,
        level_vec(current_factor) = iLevel;
        % check
        beenhere = 0;
        if perm0 == 1,
            s0 = sort(level_vec);
            for iCheck = 1:size(id_matrix, 1),
                s1 = sort(id_matrix(iCheck, :));
                if length(s0) ~= length(s1),
                    continue;
                end;
                if s0 == s1,
                    beenhere = 1;
                    break;
                end;
            end;
        end;
        if beenhere == 0,
            id_matrix = [id_matrix; level_vec];
        end;
    end;
else
    loopto = levels(current_factor);
    for iLevel = 1:loopto,
        level_vec(current_factor) = iLevel;
        id_matrix = rec_loop2_inner(levels, level_vec, id_matrix, current_factor + 1, perm0);
    end;
end;
