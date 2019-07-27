--- 战斗开始前状态的前面是加载操作 只是负责加载完成
--- 而战斗开始前状态则是针对不同的战斗做不同的区分

---@class BattleStartState
BattleStartState = Class("BattleStartState",StateBase);

local _M = BattleStartState;

-- 初始化
function _M:OnInit()

end

-- 进入
function _M:OnEnter()
    -- TODO 针对不同的关卡类型初始化
    -- 1. TODO 关卡事件注册
    -- 2. TODO 开启战斗AI
    AIManager:StartAI();
end

-- 退出
function _M:OnExit()

end

-- 更新
function _M:OnUpdate()
    -- 进入战斗和平状态
    BattleStateManager:EnterState(BattleStateManager.BattlePeaceState);
end