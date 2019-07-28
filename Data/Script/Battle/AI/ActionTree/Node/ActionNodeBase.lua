---
--- 行为节点基类
--- 1. 基础流程
--- 2. 通用方法

---@class ActionNodeBase
ActionNodeBase = Class("ActionNodeBase");

local _M = ActionNodeBase;
-- 构造函数
function _M:ctor(type)
    self.type = type;
    self.parentNode = nil;      -- 父节点 当前节点运行完成（包括子节点）之后需要返回父节点
    self.nextChildNode = nil;   -- 下一个兄弟节点
    self.lastChildNode = nil;   -- 最后一个节点
    self.firstChildNode = nil;  -- 第一个孩子节点

    self.curChildNode = nil;    -- 运行时 当前孩子节点 每一个节点都是一颗行为树 所以需要记录当前运行到了哪一个节点
    self.isAction   = false;    -- 运行时 是否正在运行中 为true表示当前节点被阻塞无法往下执行
    self.result = nil;          -- 运行时 运行结果
    self.preResult = nil;       -- 运行时 上一节点的运行结果 行为树之间的通信方式
end
-- 1 运行
function _M:DoFirstAction() end
function _M:DoAction()end
-- 2 更新
function _M:Update(delta)end
-- 3 下一步
function _M:GetNextNode()
    return self:ReturnParentNode();
end
-- 完成：不在运行状态
function _M:EndAction()
    self.isAction = false;
end
-- 阻塞：节点在等待完成中
function _M:WaitAction()
    self.isAction = true;
end
-- 行为树是否正在运行中（在当前运行节点阻塞）
function _M:CheckActioning()
    return self.isAction == true;
end

-- 上一节点运行结果的运行结果
function _M:GetPreResult()
    return self.preResult;
end

-- 返回父节点 当子节点全部执行完毕
function _M:ReturnParentNode()
    if self.parentNode then
        self.parentNode.preResult = self.result;
    end
    self:Clear();
    return self.parentNode;
end

-- 清理暂存的信息
function _M:Clear()
    self.curChildNode = nil;    -- 运行时 当前孩子节点
    self.isAction   = false;    -- 运行时 是否完成
    self.result = nil;          -- 运行时 运行结果
    self.preResult = nil;       -- 运行时 上一节点的运行结果
end

-- 添加一个孩子节点
function _M:AddChildNode(node)
    if not self.firstChildNode then
        self.firstChildNode = node;
        self.lastChildNode = node;
    else
        self.lastChildNode.nextChildNode = node;
        self.lastChildNode = self.lastChildNode.nextChildNode;
    end
end

-- 子节点个数 求取链表的长度
function _M:GetChildCount()
    local count = 0;
    local nextNode = self.firstChildNode;
    while(nextNode) do
        count = count + 1;
        nextNode = nextNode.nextChildNode;
    end
    return count;
end