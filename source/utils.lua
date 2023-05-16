function easeOutCubic(t)
    return 1 - (1 - t) ^ 3
end

function easeOutBack(t)
    local c1 = 1.70158;
    local c3 = c1 + 1;

    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end
