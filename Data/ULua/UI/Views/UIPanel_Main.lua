

UIPanel_Main = UIBaseView.New(UIConst.UIPanel_Main);

local _M = UIPanel_Main;

function _M:OnCreate()
    print("UIPanel_Main OnCreate");
end

function _M:OnRegisterMessage()
    print("UIPanel_Main OnRegisterMessage");
end

function _M:OnShow()
    print("UIPanel_Main OnShow");
end

function _M:OnClose()
    print("UIPanel_Main OnClose");
end

function _M:OnDestory()
    print("UIPanel_Main OnDestory");
end

function _M:ClickOpenTest(sender)
    local index = tonumber(sender.transform.name);
    if index == 1 then
        -- 加载测试
        -- UIManager:Init(nil,nil,UIConst.UIPanel_Father)
        -- 开始战斗
        BattleManager:SendCreateBattle();
    elseif index == 2 then
        -- 打开测试
        UIManager:Open(nil,UIConst.UIPanel_Father);
    elseif index == 3 then
        -- 加载打开测试
        UIManager:Open(nil,UIConst.UIPanel_Father);
    elseif index == 4 then
        -- 关闭测试
        UIManager:Close(UIConst.UIPanel_Father);
    elseif index == 5 then
        -- 卸载测试
        UIManager:Close(UIConst.UIPanel_Father,true);
    elseif index == 6 then
        -- 关闭卸载测试
        UIManager:Close(UIConst.UIPanel_Father,true);
    end
end

function _M:ClickOpenSingle()
    -- 打开单个UI
    UIManager:Open(nil,UIConst.UIPanel_Father);
end

function _M:ClickOpenFamily()
    -- 打开多个UI
    UIManager:Open(nil,UIConst.UIPanel_Father,UIConst.UIPanel_FatherSon1,UIConst.UIPanel_FatherSon2);
end
function _M:ClickOpenIgnore()
    -- 打开一个上层UI 并且不受UI流程控制
    UIManager:Open(nil,UIConst.UIPanel_MessageBox);
end