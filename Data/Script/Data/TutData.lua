---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wanggang.
--- DateTime: 2019/7/16 16:41
---

---@class TutData
TutData = {
    tutData = {};   -- tut的完成列表
};

local _M = TutData;

-- 可做的引导 引导条件已经达成并且还没有完成
function _M:IsCando(tutId)
    -- TODO 这里还需要判断一下开启条件：任务、关卡、功能点等
    -- 演示功能就跳过这些条件
    return table.ContainValue(self.tutData,tutId) == 0;
end

function _M:UpdateData()
    -- TODO 根据服务器来更新数据
end

function _M:UpdateEnd(tutId)
    table.insert(self.tutData,tutId);
end

-----------------------------------------------------------------------------
RegisterMessage(MsgConst.TutEvent_End,function(tutId)
    self:UpdateEnd(tutId);
end)