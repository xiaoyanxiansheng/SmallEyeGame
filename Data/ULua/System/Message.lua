--[[
	注册消息，发送消息
--]]
local Message = {};

-- 消息体
function BenginMessage(msgName)
	local msg = {};
	msg.name = msgName;
	return msg;
end

-- 发送消息
function SendMessage(msg)
	DispatchMessage(msg);
end

-- 注册消息
function RegisterMessage(msgName,call)
	if not Message[msgName] then 
		Message[msgName] = {};
	end
	table.Remove(Message[msgName],call,true);
	table.insert(Message[msgName],call);
end

-- 删除消息
function RemoveMessage(msgName,call)
	if not Message[msgName] then 
		return;
	end
	table.Remove(Message[msgName],call,true);
end

-- 触发注册消息
function DispatchMessage(msg)
	local registers = Message[msg.name];
	if not registers then 
		return;
	end
	for i,v in ipairs(registers) do
		v(msg);
	end
end
