---
--- 关卡节点
---

ANL = {
    ActionNodeLevelGameStart = "ActionNodeLevel_GameStart",
}

-- 战斗开始节点
-- region 顺序执行节点 不问对错
local ActionNodeLevelGameStart = CreateActionNode(ANL.ActionNodeLevelGameStart);
-- 执行
function ActionNodeLevelGameStart:DoAction()
    self.result = math.random(1,10) >= 5;
    LogError(tostring(self.result));
    self:EndAction(self);
end
