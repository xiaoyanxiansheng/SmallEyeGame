
UIPanel_FatherSon2 = UIBaseView.New(UIConst.UIPanel_FatherSon2);

local _M = UIPanel_FatherSon2;

function _M:OnCreate()
    print("UIPanel_FatherSon2 OnCreate");
end

function _M:OnRegisterMessage()
    print("UIPanel_FatherSon2 OnRegisterMessage");
end

function _M:OnShow()
    print("UIPanel_FatherSon2 OnShow");
end

function _M:OnClose()
    print("UIPanel_FatherSon2 OnClose");
end

function _M:OnDestory()
    print("UIPanel_FatherSon2 OnDestory");
end