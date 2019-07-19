--[[
	注册消息，发送消息
--]]
local Message = {};

-- 消息体
function BeginMessage(msgName)
	local msg = {};
	msg.name = msgName;
	return msg;
end

-- 发送消息
function SendMessage(msg)
	DispatchMessage(msg);
end

-- 注册消息
function RegisterMessage(msgName,tCall,t)
	if not Message[msgName] then 
		Message[msgName] = {};
	end
	local inIndex = table.ContainValue(Message[msgName],tCall,"tCall");
	if inIndex ~= 0 then
		return;
	end
	local msg = {};
	msg.t = t;
	msg.tCall = tCall;
	table.insert(Message[msgName],msg);
end

-- 删除消息
function RemoveMessage(msgName,call)
	if not Message[msgName] then 
		return;
	end
	local inIndex = table.ContainValue(Message[msgName],call,"tCall");
	if inIndex ~= 0 then
		table.remove(Message[msgName],inIndex);
	end
end

-- 触发注册消息
function DispatchMessage(msg)
	local registers = Message[msg.name];
	if not registers then 
		return;
	end
	for i,v in ipairs(registers) do
		if (v.t ~= nil) then
			v.tCall(v.t,msg);
		else
			v.tCall(msg);
		end
	end
end
