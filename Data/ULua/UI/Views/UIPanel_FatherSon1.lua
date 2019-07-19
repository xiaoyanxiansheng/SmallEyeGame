
UIPanel_FatherSon1 = UIBaseView.New(UIConst.UIPanel_FatherSon1);

local _M = UIPanel_FatherSon1;

function _M:OnCreate()
    print("UIPanel_FatherSon1 OnCreate");
end

function _M:OnRegisterMessage()
    print("UIPanel_FatherSon1 OnRegisterMessage");
end

function _M:OnShow()
    print("UIPanel_FatherSon1 OnShow");
end

function _M:OnClose()
    print("UIPanel_FatherSon1 OnClose");
end

function _M:OnDestory()
    print("UIPanel_FatherSon1 OnDestory");
end