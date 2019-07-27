
---@class ALT
ALT = {
    NONE = "TREE_EVENT_NONE",
    ON_TRIGGER = "TREE_EVENT_ON_TRIGGER",                 -- 触发
    ON_BATTLE_START = "TREE_EVENT_ON_BATTLE_START",       -- 战斗开始
    ON_BATTLE_END = "TREE_EVENT_ON_BATTLE_END",           -- 战斗结束
}

---@class ActionLevelTrigger
ActionLevelTrigger = Class("ActionLevelTrigger");
local _M = ActionLevelTrigger;
function _M:ctor(type)
    self.type = type;
    self.treeRoot = nil;
end

local _M = nil;

-- ON_TRIGGER
_M = Class(ALT.ON_TRIGGER,ActionLevelTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);

-- ON_TRIGGER
_M = Class(ALT.ON_BATTLE_START,ActionLevelTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);

-- ON_TRIGGER
_M= Class(ALT.ON_BATTLE_END,ActionLevelTrigger);
-- TODO 需要加入属性
ActionTreeManager:RegisterEventTrigger(_M);