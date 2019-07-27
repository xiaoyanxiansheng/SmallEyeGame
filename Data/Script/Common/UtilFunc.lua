function LogInfo(s)
    GameLogger.LogInfo(debug.getinfo(2, "S").source.." " .. debug.getinfo(2, "l").currentline .. " : "..s);
end
function LogError(s)
    GameLogger.LogError(debug.getinfo(2, "S").source.." " .. debug.getinfo(2, "l").currentline .. " : "..s);
end
function LogWarning(s)
    GameLogger.LogWarning(debug.getinfo(2, "S").source.." " .. debug.getinfo(2, "l").currentline .. " : "..s);
end