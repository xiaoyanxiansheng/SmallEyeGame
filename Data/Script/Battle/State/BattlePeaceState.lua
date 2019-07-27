---


---@class BattlePeaceState
BattlePeaceState = Class("BattlePeaceState",StateBase);

local _M = BattlePeaceState;

-- 初始化
function _M:OnInit()

end

-- 进入
function _M:OnEnter()
    -- TODO 开启AI AI接管战斗
    BattleManager:GetBattle():GetAIManager():Start();
end

-- 退出
function _M:OnExit()

end

-- 更新
function _M:OnUpdate()

end