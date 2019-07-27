---
--- 战斗的AI管理器
---

require "Data/Script/Battle/AI/ActionTree/ActionTreeManager";

---@class AIManager
AIManager = Class("AIManager").New();

local _M = AIManager;

_M.AIType_LEVEL = 1;
_M.AIType_MODEL = 2;

-- 构造
function _M:ctor()
    self.actionTreeManager = nil;
end

-- 开始
function _M:StartAI()
    -- 开启行为树
    ActionTreeManager:StartAI(self.AIType_LEVEL,1001,"AT_Test");
    -- 测试
    local msg = BeginMessage(MsgConst.ActionTree_TriggerEvent);
    msg.AIType = self.AIType_LEVEL;
    msg.param = 1001;
    msg.eventType = ALT.ON_TRIGGER;
    SendMessage(msg);
end

-- 是否暂停
function _M:SetPause(isPause)

end

-- 更新
function _M:Update(delta)
    ActionTreeManager:Update(delta);
end