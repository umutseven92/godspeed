-- All copied from https://easings.net/.

function easeOutCubic(t)
    return 1 - (1 - t) ^ 3
end

function easeOutBack(t)
    local c1 = 1.70158;
    local c3 = c1 + 1;

    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

function easeInOutElastic(t)
    local c5 = (2 * math.pi) / 4.5;

    if t == 0 then
        return 0
    elseif t == 1 then
        return 1
    elseif t < 0.5 then
        return -(2 ^ (20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2
    else
        return (2 ^ (-20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1;
    end
end

function easeInSine(t)
    return 1 - math.cos((t * math.pi) / 2);
end

function getRandomElement(collection)
    local rand = math.random(#collection)

    acc = 1
    for k, v in pairs(collection) do
        if rand == acc then
            return k, v
        end
        acc+=1
    end
end