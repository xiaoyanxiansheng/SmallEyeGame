
---@class ALT
ALT = {
    NONE = "TREE_EVENT_NONE",
    ON_TRIGGER = "TREE_EVENT_ON_TRIGGER",                 -- 触发
    ON_BATTLE_START = "TREE_EVENT_ON_BATTLE_START",       -- 战斗开始
    ON_BATTLE_END = "TREE_EVENT_ON_BATTLE_END",           -- 战斗结束
}

---@class ActionEventTrigger
ActionEventTrigger = Class("ActionEventTrigger");
local _M = ActionEventTrigger;
function _M:ctor(type)
    self.type = type;
    self.treeRoot = nil;        -- 行为树根节点
    self.beInterrupVote = 0;    -- 优先级高能中断优先级低的

    self.curActionNode = nil;   -- 当前运行节点
    self.isPause = false;       -- 是否暂定
end
-- 是否能被中断
function _M:CheckTrigger(event)
    -- 暂定状态下 不接受事件
    if self.isPause then
        return false;
    end
    -- 优先级触发
    if event.beInterrupVote >= self.beInterrupVote then
        return true;
    end
    return false;
end
-- 运行行为树
function _M:DoActionTree(delta,finishCall)
    if self.isPause then
        return;
    end
    if not self.curActionNode then
        self.curActionNode = self.treeRoot;
        self.curActionNode:DoAction();
    end
    self.curActionNode:Update(delta);
    -- 遍历执行
    while(self.curActionNode and not self.curActionNode:CheckActioning()) do
        self.curActionNode = self.curActionNode:GetNextNode();
        if self.curActionNode then
            self.curActionNode:DoAction();
        else
            self:Destory();
            finishCall(self);
            break;
        end
    end
end

function _M:Pause()
    self.isPause = true;
end
function _M:Resume()
    self.isPause = false;
end
function _M:Break()
    self:Destory();
end
function _M:Destory()
    self.curActionNode = nil;   -- 当前运行节点
    self.isPause = false;       -- 是否暂定
end
function _M:IsPause()
    return self.isPause;
end

local _M = nil;

-- ON_TRIGGER
_M = Class(ALT.ON_TRIGGER, ActionEventTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);

-- ON_TRIGGER
_M = Class(ALT.ON_BATTLE_START, ActionEventTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);

-- ON_TRIGGER
_M= Class(ALT.ON_BATTLE_END, ActionEventTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);