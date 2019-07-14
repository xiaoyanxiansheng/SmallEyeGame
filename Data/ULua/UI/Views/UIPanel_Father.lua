
-- 继承UIBaseView
UIPanel_Father = UIBaseView.New(UIConst.UIPanel_Father);

local _M = UIPanel_Father;

function _M:OnCreate()
	print("UIPanel_Test OnCreate");
end

function _M:OnRegisterMessage()
	print("UIPanel_Test OnRegisterMessage");
end

function _M:OnShow()
	print("UIPanel_Test OnShow");
end

function _M:OnClose()
	print("UIPanel_Test OnClose");
end

function _M:OnDestory()
	print("UIPanel_Test OnDestory");
end

function _M:ClickClose(sender)
	local index = tonumber(sender.transform.name);
	if index == 1 then
		-- 关闭主UI 也就是关闭整个UI集合
		UIManager:Close(UIConst.UIPanel_Father);
	elseif index == 2 then
		-- 关闭子UI1
		UIManager:Close(UIConst.UIPanel_FatherSon1);
	elseif index == 3 then
		-- 关闭子UI2
		UIManager:Close(UIConst.UIPanel_FatherSon2);
	end
end