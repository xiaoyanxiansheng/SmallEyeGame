
local function test()
    local random = math.random(1,10);
    return random > 5;
end

local t =
BEGIN_MODEL()
    BEGIN_EVENT(ALT.ON_TRIGGER);
        BEGIN_FATHER_NODE(TNN.ActionNodeLoop);
            ADD_NODE(TNN.ActionWait,1);
            BEGIN_FATHER_NODE(TNN.ActionUnitNode)
                ADD_NODE(ANL.ActionNodeLevelGameStart);
                ADD_NODE(TNN.ActionNodeLog,"log1");
                ADD_NODE(ANL.ActionNodeLevelGameStart);
                ADD_NODE(TNN.ActionNodeLog,"log2");
                ADD_NODE(ANL.ActionNodeLevelGameStart);
                ADD_NODE(TNN.ActionNodeLog,"log3");
                ADD_NODE(ANL.ActionNodeLevelGameStart);
                ADD_NODE(TNN.ActionNodeLog,"log4");
                ADD_NODE(ANL.ActionNodeLevelGameStart);
                ADD_NODE(TNN.ActionNodeLog,"log5");
            END_FATHER_NODE()
            --BEGIN_FATHER_NODE(TNN.ActionNodeIF,test)
            --    ADD_NODE(TNN.ActionNodeLog,"log11");
            --END_FATHER_NODE()
            --ADD_NODE(TNB.ActionNodeLog,"log11");
            --BEGIN_FATHER_NODE(TNB.ActionNodeParallel)
            --    ADD_NODE(TNB.ActionNodeLog,"log11");
            --    ADD_NODE(TNB.ActionNodeLog,"log12");
            --    ADD_NODE(TNB.ActionNodeLog,"log13");
            --END_FATHER_NODE()
            --ADD_NODE(TNB.ActionNodeLog,"log12");
            --ADD_NODE(TNB.ActionWait,3);
            --ADD_NODE(TNB.ActionNodeLog,"log13");
            --ADD_NODE(TNB.ActionNodeLog,"log14");
            --BEGIN_FATHER_NODE(TNB.ActionUnitNode);
            --    ADD_NODE(TNB.ActionNodeLog,"====================================");
            --    ADD_NODE(TNB.ActionNodeLog,"log21");
            --    ADD_NODE(TNB.ActionNodeLog,"log22");
            --    ADD_NODE(TNB.ActionNodeLog,"log23");
            --    ADD_NODE(TNB.ActionNodeLog,"log24");
            --END_FATHER_NODE();
            --BEGIN_FATHER_NODE(TNB.ActionUnitNode);
            --    ADD_NODE(TNB.ActionNodeLog,"====================================");
            --    ADD_NODE(TNB.ActionNodeLog,"log25");
            --    ADD_NODE(TNB.ActionNodeLog,"log26");
            --    ADD_NODE(TNB.ActionNodeLog,"log27");
            --    ADD_NODE(TNB.ActionNodeLog,"log28");
            --END_FATHER_NODE();
        END_FATHER_NODE()
    END_EVENT();
END_MODEL()

return t;