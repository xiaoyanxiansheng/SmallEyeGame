require "Data/Script/Battle/State/BattleStartState";
require "Data/Script/Battle/State/BattlePeaceState";
require "Data/Script/Battle/State/BattleEndState";

---@class BattleStateManager
BattleStateManager = Class("BattleStateManager",StateManager).New();

local _M = BattleStateManager;

_M.BattleStartState = "BattleStartState";   -- 战斗准备
_M.BattlePeaceState = "BattlePeaceState";   -- TODO 战斗开始 （这个状态做修改）
_M.BattleEndState = "BattleEndState";       -- 战斗结束

function _M:Init()
    self:RegisterState(BattleStartState.New());
    self:RegisterState(BattlePeaceState.New());
    self:RegisterState(BattleEndState.New());
end

_M:Init();