---
--- 战斗和UI的中间层
--- 目的是分离逻辑与表现
---

---@class BattlePerform
BattlePerform = {};
local _M = BattlePerform;

-- 加载关卡
function _M.LoadLevel(msg)
    -- 开始加载
    LoadingManager:Loading(msg);
end

RegisterMessage(MsgConst.Preform_Load_Level,_M.LoadLevel);