
local function test()
    local random = math.random(1,10);
    return random > 0;
end

local t =
BEGIN_MODEL()                                               -- 事件集合   
    BEGIN_EVENT(ALT.ON_TRIGGER);                            -- 事件节点
        BEGIN_FATHER_NODE(TNN.ActionNodeLoop);              -- 循环节点
            ADD_NODE(TNN.ActionWait,1.0);                   -- 等待节点
            BEGIN_FATHER_NODE(TNN.ActionNodeParallel)       -- 并行节点
                BEGIN_FATHER_NODE(TNN.ActionNodeSequence);
                    ADD_NODE(TNN.ActionWait,1.0);
                    ADD_NODE(TNN.ActionNodeLog,"log1");         -- 打印节点
                    ADD_NODE(TNN.ActionNodeLog,"log2");         -- 打印节点
                END_FATHER_NODE()
                BEGIN_FATHER_NODE(TNN.ActionNodeSequence);
                    ADD_NODE(TNN.ActionNodeLog,"log3");         -- 打印节点
                    ADD_NODE(TNN.ActionNodeLog,"log4");         -- 打印节点
                END_FATHER_NODE()
            END_FATHER_NODE()
            BEGIN_FATHER_NODE(TNN.ActionNodeIF,test)        -- 判断节点
               ADD_NODE(TNN.ActionNodeLog,"log11");         -- 打印节点
            END_FATHER_NODE()
        END_FATHER_NODE()
    END_EVENT();
END_MODEL()
return t;