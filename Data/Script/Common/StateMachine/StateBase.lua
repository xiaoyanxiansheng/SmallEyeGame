---
--- 状态基类
---

---@class StateBase
StateBase = Class("StateBase");

local _M = StateBase;

function _M:ctor(stateManager)
    self.name = self.__cname;
    self:OnInit();
end

function _M:GetName()
    return self.name;
end

-- 初始化
function _M:OnInit()
    LogInfo("StateBase OnInit");
end

-- 进入
function _M:OnEnter()
    LogInfo("StateBase OnEnter");
end

-- 退出
function _M:OnExit()
    LogInfo("StateBase OnExit");
end

-- 更新
function _M:OnUpdate()
    -- LogInfo("StateBase OnUpdate");
end