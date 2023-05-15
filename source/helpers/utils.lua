function getRandomElement(collection)
    local rand = math.random(#collection)

    acc = 1
    for k, v in pairs(collection) do
        if rand == acc then
            return k, v
        end
        acc += 1
    end
end
