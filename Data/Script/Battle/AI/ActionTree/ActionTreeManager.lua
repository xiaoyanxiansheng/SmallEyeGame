---
--- 行为树管理器
--- 1 注册
--- 2 监听
--- 3 触发
---

---@class ActionTreeManager
ActionTreeManager = {
    registerNodes = nil,          -- 注册的所有节点
    registreEvents = nil,         -- 注册的所有事件
    registerEvents = nil,       -- 当前注册的实体事件
    activeEvents = nil,         -- 当前激活的实体事件
};

local _M = ActionTreeManager;

function _M:Init()
    self:RegisterEvent();
end

-- 开启AI
function _M:StartAI(AIType,param,aiName)
    if not self.registerEvents then
        self.registerEvents = {};
    end
    if not self.registerEvents[AIType] then
        self.registerEvents[AIType] = {};
    end
    local events = require("Data/Script/Battle/AI/AIFile/AI_Test");
    self.registerEvents[AIType][param] = events;
end

-- 注册消息
function _M:RegisterEvent()
    RegisterMessage(MsgConst.ActionTree_TriggerEvent,self.ReceiveMessage,self);
end
-- 触发事件消息
function _M:ReceiveMessage(msg)
    local AIType = msg.AIType;
    local param = msg.param;
    local eventType = msg.eventType;
    if not self.registerEvents[AIType] then
        return;
    end
    if not self.registerEvents[AIType][param] then
        return;
    end
    local events = self.registerEvents[AIType][param];
    if not self.activeEvents then
        self.activeEvents = {};
    end
    for i, v in pairs(events) do
        if v.type == eventType then
            local tempEvent = Clone(v);
            tempEvent.param = param;
            table.insert(self.activeEvents,tempEvent);
        end
    end
end

-- 运行
_M.deleteEvents = {};
function _M:Update(delta)
    if not self.activeEvents then
        return;
    end

    table.Clear(self.deleteEvents,true);
    for entityId,event  in ipairs(self.activeEvents) do
        if not event.treeRoot.curNode then
            event.treeRoot.curNode = event.treeRoot;
        end
        event.treeRoot.curNode:Update(delta);
        event.treeRoot.event = event;
        self:DoEventTrigger(event.treeRoot,function(finishActionTree)
            table.insert(self.deleteEvents,finishActionTree.event);
        end);
    end
    local deleteEventsCount = #self.deleteEvents;
    if deleteEventsCount > 0 then
        for i = 1, deleteEventsCount do
            local event = self.deleteEvents[deleteEventsCount - i + 1];
            table.Remove(self.activeEvents,event,true);
        end
    end
end

function _M:DoEventTrigger(actionTree,finishCall)
    -- 遍历执行
    while(actionTree.curNode and not actionTree.curNode:CheckActioning()) do
        local nextNode = actionTree.curNode:GetNextNode();
        actionTree.curNode = nextNode;
        if nextNode then
            actionTree.curNode:DoAction();
        else
            finishCall(actionTree);
            break;
        end
    end
end

function _M:StopActionTree(tree)
    if not tree then
        return;
    end
    if tree.curNode then
        tree.curNode:Stop();
    end
    -- 从active中删除
end

-- 注册节点信息
function _M:RegisterNode(nodeClass)
    if not self.registerNodes then
        self.registerNodes = {};
    end
    self.registerNodes[nodeClass.__cname] = nodeClass;
end
-- 注册事件信息
function _M:RegisterEventTrigger(eventClass)
    if not self.registreEvents then
        self.registreEvents = {};
    end
    self.registreEvents[eventClass.__cname] = eventClass;
end

_M:Init();

require "Data/Script/Battle/AI/ActionTree/ActionTreeTool";
require "Data/Script/Battle/AI/ActionTree/Node/ActionNodeBase";
require "Data/Script/Battle/AI/ActionTree/Node/ActionNodeNormal";
require "Data/Script/Battle/AI/ActionTree/Node/ActionNodeLevel";
require "Data/Script/Battle/AI/ActionTree/Node/ActionNodeSkill";
require "Data/Script/Battle/AI/ActionTree/Trigger/ActionLevelTrigger";