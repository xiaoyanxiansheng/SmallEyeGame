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
function table.Clear(t,isArray)
    if t then
        if isArray then
            local count = #t;
            for i = 1, count do
                local index = count - i + 1;
                table.remove(t,index);
            end
        else
            for k,v in pairs(t) do
                t[k] = nil;
            end
        end
    end

    return t;
end

-- table中加入一个table
function table.AddTable(t1,t2)
    if not t1 or not t2 then 
        return;
    end

    for k,v in pairs(t2) do
        local inIndex = table.ContainValue(t1,v);
        if inIndex == 0 then 
            table.insert(t1,v);
        end
    end
end

-- table中删除一个Value
function table.Remove(t,value,isArray)
    if not t or not value then
        return;
    end
    for k,v in pairs(t) do
        if v == value then 
            if isArray then 
                table.remove(t,k);
            else
                t[k] = nil;
            end
            break;
        end
    end
end

-- table中加入值 如果以前有就先删除 然后加入
function table.InsertOnlyValue(t,value)
    if not t or not value then 
        return;
    end
    table.Remove(t,value,true);
    table.inert(t,value);
end

-- 克隆
function table.Clone(t)
    if not t then 
        return;
    end
    local tt = {};
    for k,v in pairs(t) do
        tt[k] = v;
    end
    return tt;
end