---
--- 战斗基础脚本
---

require "Data/Script/Battle/Base/Battle";
require "Data/Script/Battle/Base/ClientBattle";
require "Data/Script/Battle/Base/ServerBattle";

---@class BattleManager
BattleManager = {
    battleType = 1;
    battle = nil;
}

local _M = BattleManager;

_M.BATTLE_LOCAL = 1;  -- 本地战斗
_M.BATTLE_SERVER = 2; -- 服务器战斗

-- 创建战斗
function _M:CreateBattle(msg)
    self.battleType = msg.battleType;
    if self.battleType == self.BATTLE_LOCAL then
        self.battle = ClientBattle.New();
    else
        -- TODO 服务器战斗
    end
    self.battle:InitBattle();
end
-- 开始战斗
function _M:StartBattle(msg)
    self:DestoryBattle();

    if not self.battle then
        LogError("BattleManager battle is nil");
        return;
    end
    self.battle:StartBattle();
    self:OpenUpdateFrame();
end
-- 结束战斗
function _M:FinishBattle()
    if self.updateTimer then
        RemoveTimer(self.updateTimer);
        self.updateTimer = nil;
    end
end
-- 销毁战斗
function _M:DestoryBattle()
    self:FinishBattle();
end
-- 帧更新
function _M:UpdateFame(delta)
    -- AI    更新
    AIManager:Update(delta);
    -- 状态机 更新
    StateManager:Update(delta);
end
-- 战斗起一个倒计时
function _M:OpenUpdateFrame()
    self.updateTimer = AddTimer(0,function(detal)
        self:UpdateFame(detal);
        return false;
    end)
end

function _M:GetBattle()
    return self.battle;
end

---------------------------------------- TODO 发送消息 ---------------------------------------------
-- 创建战斗
function _M:SendCreateBattle()
    local msg = BeginMessage(MsgConst.S2C_Battle_CreateBattle);
    msg.battleType = self.BATTLE_LOCAL;
    SendMessage(msg);
end
-- 加载完成
function _M:SendLoadingFinish()
    -- TODO 本地直接开始战斗
    self:StartBattle();

    -- TODO 联网需要向服务器发送消息
    --local msg = BeginMessage(MsgConst.S2C_Battle_LoaingFinish);
    --SendMessage(msg);
end
---------------------------------------- 接受消息 ---------------------------------------------
RegisterMessage(MsgConst.S2C_Battle_CreateBattle,_M.CreateBattle,_M);
-- 如果是服务器版本 发送加载成功消息后服务器会返回开始战斗（多人情况下才有用）
RegisterMessage(MsgConst.S2C_Battle_StartBattle,_M.StartBattle,_M);