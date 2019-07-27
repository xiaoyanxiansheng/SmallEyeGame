---
--- 加载管理器
--- 分状态加载
---

---@class LoadingManager
LoadingManager = {};

local _M = LoadingManager;

function _M:Loading(msg)
    -- TODO 直接加载完成
    -- SendMessage(BeginMessage(MsgConst.Load_Level_Finish));
    self:LoadingSuccess();
end

function _M:LoadingSuccess()
    BattleManager:SendLoadingFinish();
end
