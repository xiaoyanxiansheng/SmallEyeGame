

require "Data/Script/Common/StateMachine/StateBase"

---@class StateManager
StateManager = Class("StateManager");

local _M = StateManager;

_M.StateManagerList = {};

function _M:cotr()
    self.name = self.__cname;
    self.StateManagerList[self.name] = self;

    self.stateName = nil;
    self.stateList = nil;
end

-- 注册状态
function _M:RegisterState(state)
    if not self.stateList then
        self.stateList = {};
    end
    self.stateList[state.name] = state;
end

-- 初始化状态
function _M:Init(stateName)

end

-- 进入状态（进入前先退出当前状态）
function _M:EnterState(stateName)
    self:Exit(stateName);
    self:Enter(stateName);
end

-- 进入状态
function _M:Enter(stateName)
    if not self:Check(stateName) then
        return;
    end
    if self.stateName and self.stateName == stateName then
        return;
    end
    LogInfo("StateManager Endter " .. stateName);
    self.stateList[stateName]:OnEnter();
end

-- 退出状态
function _M:Exit(stateName)
    if not self:Check(stateName) then
        return;
    end
    if self.stateName and self.stateName == stateName then
        LogInfo("StateManager Exit " .. stateName);
        self.stateList[stateName]:OnExit();
    end
end

-- 更新
function _M:Update(delta)
    if not self:Check(self.stateName) then
        return;
    end
    self.stateList[self.stateName]:OnUpdate(delta);
end

function _M:Check(stateName)
    if not stateName then
        return false;
    end
    if not self.stateList then
        return false;
    end
    if not self.stateList[stateName] then
        return false;
    end
    return true;
end