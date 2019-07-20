
UIPanel_Tut = UIBaseView.New(UIConst.UIPanel_Tut);

local _M = UIPanel_Tut;

function _M:OnCreate()

end

function _M:OnRegisterMessage()

end

function _M:OnShow()
    self.tutInfo = TutManager:GetTutInfo();
    -- 1. 屏蔽NGUI层的UI事件
    UIManager:ForbidUIEvent(UIManager.CAMERA_NGUI,true);
    -- 2. 高亮显示 设置节点到NGUI_TOP层中
    self:SetNodeDisplay(UIManager.CAMERA_NGUI_TOP);
end

function _M:ClearTut()
    -- 恢复节点到NGUI层中
    self:SetNodeDisplay(UIManager.CAMERA_NGUI);
    self.tutInfo = nil;
end

function _M:OnClose()
    -- 1. 开启NGUI层的UI事件
    UIManager:ForbidUIEvent(UIManager.CAMERA_NGUI,false);
end

function _M:OnDestory()

end

-- 高亮显示设置
function _M:SetNodeDisplay(layer)
    local triggerEventValue = self.tutInfo.triggerEventValue;
    local view = UIManager:GetControlScript(self.tutInfo.viewName);
    local displayNode = view:GetNode(triggerEventValue);
    if not displayNode then
        print(" RefreshNodeDisplay is error " .. self.tutInfo.tutId .. " " .. self.tutInfo.tutSubId .. " " .. triggerEventValue);
        return;
    end
    if layer == UIManager.CAMERA_NGUI_TOP then 
        -- 注意：只有UIPanel才能改变显示层 不然修改无效
        local tempPanel = displayNode:GetComponent("UIPanel");
        if not tempPanel then
            tempPanel = AddComponent(displayNode,"UIPanel");
            -- 高亮显示
            tempPanel.depth = 10000;
            self.addPanel = tempPanel;
        end
    else
        -- 删除增加panel
        if self.addPanel then
            GameObject.Destroy(self.addPanel);
            self.addPanel = nil;
        end
    end
    
    displayNode:SetActive(false);
    displayNode:SetActive(true);
    UIManager:SetNodeLayer(displayNode,layer);
end