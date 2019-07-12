-- 寻找table中是否存再
function table.ContainValue(t,value,param1,param2)
    local containIndex = 0;
    if t then
        for i, v in pairs(t) do
            if not param1 then
                if v == value then
                    containIndex = i;
                    break;
                end
            elseif not param2 then
                if v[param1] == value then
                    containIndex = i;
                    break;
                end
            else
                if v[param1][param2] == value then
                    containIndex = i;
                    break;
                end
            end
        end
    end
    return containIndex;
end

-- 清理table
function table.Clear(t)
    if t then 
        for k,v in pairs(t) do
            t[k] = nil;
        end
    end
end

-- table中加入一个table
function table.AddTable(t1,t2)
    if not t1 or not t2 then 
        return t1;
    end

    for k,v in pairs(t2) do
        local inIndex = table.ContainValue(t1,v,k);
        if inIndex == 0 then 
            table.insert(t1,v);
        end
    end
end