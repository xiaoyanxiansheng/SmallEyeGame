---@class
Battle = Class("Battle");
local  _M = Battle;

-- battle的状态
Battle_State = {
    None        = 0;    -- 未开始
    Inited      = 1;    -- 初始化
    Started     = 2;    -- 战斗开始
    Finished    = 3;    -- 已结束
    Destoryed   = 4;    -- 已销毁
}

-- 构造
function _M:ctor()
    self.entities = {};     -- 实体
end

-- 创建战斗
function _M:CreateBattle()
    LogInfo("Battle CreateBattle");

    self:InitBattle();

    self:OnCreateBattle();
end

-- 创建完成
function _M:OnCreateBattle()
    LogInfo("Battle OnCreateBattle");
end

-- 初始化战斗
function _M:InitBattle()
    LogInfo("Battle InitBattle");
    self:OnInitBattle();
end

-- 初始化完成
function _M:OnInitBattle()
    LogInfo("Battle OnInitBattle");
end

-- 开始战斗
function _M:StartBattle()
    LogInfo("Battle StartBattle");
    self:OnStartBattle();
end
-- 开始战斗完成
function _M:OnStartBattle()
    LogInfo("Battle OnStartBattle");
end

-- 结束战斗
function _M:FinishBattle()
    LogInfo("Battle FinishBattle");

    self:OnFinishBattle();
end
-- 结束战斗完成
function _M:OnFinishBattle()
    LogInfo("Battle OnFinishBattle");
end

-- 销毁战斗
function _M:DestoryBattle()
    LogInfo("Battle DestoryBattle");

    self:OnDestoryBattle();
end

-- 销毁战斗完成
function _M:OnDestoryBattle()
    LogInfo("Battle OnDestoryBattle");
end

-- 战斗AI
function _M:SetAIManager(aiManager)
    self.aiManager = aiManager;
end
function _M:GetAIManager()
    return self.aiManager;
end