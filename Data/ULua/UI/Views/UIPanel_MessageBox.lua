

UIPanel_MessageBox = UIBaseView.New(UIConst.UIPanel_MessageBox);

local _M = UIPanel_MessageBox;

function _M:OnCreate()
    print("UIPanel_MessageBox OnCreate");
end

function _M:OnRegisterMessage()
    print("UIPanel_MessageBox OnRegisterMessage");
end

function _M:OnShow()
    print("UIPanel_MessageBox OnShow");
end

function _M:OnClose()
    print("UIPanel_MessageBox OnClose");
end

function _M:OnDestory()
    print("UIPanel_MessageBox OnDestory");
end

function _M:ClickExit()
    UIManager:Close(UIConst.UIPanel_MessageBox);
end