--- 普通节点集合

---@class TNB
TNN = {
    ActionNodeSequence = "ActionNodeSequence",  -- 顺序节点
    ActionUnitNode = "ActionUnitNode",          -- 顺序节点 遇到失败就返回
    ActionNodeNot = "ActionNodeNot",            -- 否定节点
    ActionNodeLoop = "ActionNodeLoop",          -- 循环节点
    ActionNodeLog = "ActionNodeLog",            -- 打印节点
    ActionWait    = "ActionWait",               -- 等待节点
    ActionNodeIF = "ActionNodeIF",              -- 判断节点
    ActionNodeParallel = "ActionNodeParallel",  -- 平行节点
}

function CreateActionNode(tnb)
    local node = Class(tnb,ActionNodeBase);
    ActionTreeManager:RegisterNode(node);
    return node;
end

-- region 顺序执行节点 不问对错
local ActionNodeSequence = CreateActionNode(TNN.ActionNodeSequence);
-- 执行
function ActionNodeSequence:DoAction()
    -- 这里会多次执行，每次有子节点执行完成之后都会返回这里
    -- 但是对于顺序节点来说什么都不做 直接执行完毕
    self:EndAction(self);
end
-- 顺序寻找节点
function ActionNodeSequence:GetNextNode()
    if self.curChildNode then
        -- 依次寻找下一个节点
        self.curChildNode = self.curChildNode.nextChildNode;
        -- 全部执行完毕
        if not self.curChildNode then
            -- 当前行为节点执行完成 返回父亲节点
            return self:ReturnParentNode();
        end
    else
        self.curChildNode = self.firstChildNode;
    end
    -- 当前执行节点
    return self.curChildNode;
end
-- endregion

-- region 单元节点 循序执行节点 如果子节点执行失败就停止
local ActionUnitNode = CreateActionNode(TNN.ActionUnitNode)
function ActionUnitNode:DoAction()
    self:EndAction(self);
    -- 子节点的运行结果
    local preReult = self:GetPreResult();
    if preReult == false then
        -- 子节点执行失败 直接跳到最后节点 等待返回
        self.curChildNode = self.lastChildNode;
    end
end
function ActionUnitNode:GetNextNode()
    if self.curChildNode then
        self.curChildNode = self.curChildNode.nextChildNode;
        -- 全部执行完毕
        if not self.curChildNode then
            return self:ReturnParentNode();
        end
    else
        self.curChildNode = self.firstChildNode;
    end
    return self.curChildNode;
end
-- endregion

-- region 平行节点 同帧先后执行
local ActionNodeParallel = CreateActionNode(TNN.ActionNodeParallel)
function ActionNodeParallel:DoAction()
    self:WaitAction();
    self.finishActionTrees = {};
    self.childCount = self:GetChildCount();
end
function ActionNodeParallel:Update(delta)
    -- 同帧运行所以的子节点 每一个节点都是一个行为树
    local actionTree = self.firstChildNode;
    while(actionTree) do
        local inIndex = table.ContainValue(self.finishActionTrees,actionTree);
        if inIndex == 0 then
            if not actionTree.curNode then
                actionTree.curNode = actionTree;
                actionTree.curNode:DoAction();
            end
            actionTree.curNode:Update(delta);
            -- 遍历执行
            while(not actionTree.curNode:CheckActioning()) do
                local nextNode = actionTree.curNode:GetNextNode();
                actionTree.curNode = nextNode;
                if nextNode and nextNode ~= self then
                    actionTree.curNode:DoAction();
                else
                    actionTree.curNode = nil;
                    table.insert(self.finishActionTrees,actionTree);
                    break;
                end
            end
        end

        -- 子树全部执行完毕
        if #self.finishActionTrees >= self.childCount then
            self:EndAction(self);
            break;
        end

        actionTree = actionTree.nextChildNode;
    end
end
-- endregion

-- region 循环节点
local ActionNodeLoop = CreateActionNode(TNN.ActionNodeLoop);
function ActionNodeLoop:DoAction()
    self:EndAction(self);
end
function ActionNodeLoop:GetNextNode()
    if self.curChildNode then
        self.curChildNode = self.curChildNode.nextChildNode;
        -- 已经执行完毕
        if not self.curChildNode then
            -- 全部执行完毕后 再次回到第一个节点
            self.curChildNode = self.firstChildNode;
        end
    else
        self.curChildNode = self.firstChildNode;
    end
    return self.curChildNode;
end
-- endregion

-- region 否定节点
local ActionNodeNot = CreateActionNode(TNN.ActionNodeNot);
function ActionNodeNot:DoAction()
    self:EndAction(self);
    -- 如果有返回对返回结果取反
    self.result = not self:GetPreResult();
end
function ActionNodeNot:GetNextNode()
    if self.curChildNode then
        return self:ReturnParentNode();
    else
        self.curChildNode = self.firstChildNode;
    end
    return self.curChildNode;
end
-- endregion

-- region 判断节点
local ActioNotIF = CreateActionNode(TNN.ActionNodeIF);
SET_PROP(ActioNotIF,"if",VT.LUAFUNCTION,false);
function ActioNotIF:DoAction()
    self:EndAction(self);
end
function ActioNotIF:GetNextNode()
    -- 判断的条件
    local tif = GET_PROP(self,"if");
    if not tif then
        return self:ReturnParentNode();
    end
    if self.curChildNode then
        return self:ReturnParentNode();
    end
    if tif then
        self.curChildNode = self.firstChildNode;
        return self.curChildNode;
    else
        return self:ReturnParentNode();
    end
end
-- endregion

-- region 等待节点
local ActionWait = CreateActionNode(TNN.ActionWait);
SET_PROP(ActionWait,"waitTime",VT.FLOAT,0);
function ActionWait:DoAction()
    self.passWaitTime = 0;
    self:WaitAction();
end
function ActionWait:Update(delta)
    self.passWaitTime = self.passWaitTime + delta;
    if self.passWaitTime >= GET_PROP(self,"waitTime") then
        self:EndAction(self);
    end
end
-- endregion

-- region 打印节点
local ActionNodeLog = CreateActionNode(TNN.ActionNodeLog);
SET_PROP(ActionNodeLog,"Log",VT.STRING,"");
function ActionNodeLog:DoAction()
    LogInfo(GET_PROP(self,"Log"));
    self:EndAction(self);
end
-- endregion