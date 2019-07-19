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

----------------------------------- 与服务器通信 ------------------------------------------
-- 新手引导完成
function _M:SendTutEnd(tutId)
	-- 这里还缺一步 应该是发送到服务器 因为现在没有服务器 所以客户端直接转发
	local msg = BeginMessage(MsgConst.S2C_Tut_End);
	msg.tutId = tutId;
	SendMessage(msg);
end

-- 收到服务器返回的消息
RegisterMessage(MsgConst.S2C_Tut_End,function(msg)
    TutData:UpdateEnd(msg.tutId);
    SendMessage(BeginMessage(MsgConst.Tut_End));
end)