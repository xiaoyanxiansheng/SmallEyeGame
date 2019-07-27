---
--- 客户端战斗
---

---@class ClientBattle
ClientBattle = Class("ClientBattle",Battle);

local _M = ClientBattle;

function _M:cotr()
    -- 使用父类初始化
    Battle.cotr(self);
end

-- 创建战斗
function _M:OnCreateBattle()
    LogInfo("ClientBattle OnCreateBattle");
end

-- 初始化战斗
function _M:OnInitBattle()
    LogInfo("ClientBattle OnInitBattle");

    -- 初始化成功 开始加载场景
    local msg = BeginMessage(MsgConst.Preform_Load_Level);
    SendMessage(msg);
end

-- 战斗开始
function _M:OnStartBattle()
    -- TODO 战斗前准备
    BattleStateManager:EnterState(BattleStateManager.BattleStartState);
end

------------------------------------ 消息 ------------------------------------------
--RegisterMessage(MsgConst.,)