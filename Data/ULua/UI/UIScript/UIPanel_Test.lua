
-- 继承UIBaseView
UIPanel_Test = UIBaseView.New(UIConst.UIPanel_Test);

local _M = UIPanel_Test;

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