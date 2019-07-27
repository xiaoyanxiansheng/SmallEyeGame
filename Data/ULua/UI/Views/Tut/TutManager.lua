--- 引导开启：任务、等级、功能点
--- 事件开启：界面打开
--- 事件完成：点击按钮，拖拽
--- 两步引导之间的衔接分为：
---     1 同步：立马开始下一步引导，比如在同一界面的引导。
---     2 异步：等待事件开启，比如不同界面要等待界面打开才能开启

---@class TutManager
TutManager = {
    tutId = 0;          -- 当前引导流程
    tutSubId = 0;       -- 当前引导流程步骤
    tutNextId = 0;      -- 当前引导流程完成后将要触发的引导流程
    tutNextSubId = 0;   -- 当前引导流程完成后将要触发的引导流程步骤
};

local _M = TutManager;

-- region 流程控制
-- 数据初始化
function _M:Init()
    self:InitTutConfig();
    self:RegisterOpenEvent();
end

-- 开启新手引导步骤
function _M:OpenTut(tutId,tutSubId)
    if tutId == 0 then
        return;
    end
    if self.tutId == tutId and self.tutSubId == tutSubId then
        return;
    end

    self.tutId = tutId;
    self.tutSubId = tutSubId;
    self.tutInfo = self:GetTutInfo(self.tutId,self.tutSubId);
    self.tutNextId = self.tutInfo.tutNextId;
    self.tutNextSubId = self.tutInfo.tutNextSubId;
    self.tutNextInfo = self:GetTutInfo(self.tutNextId,self.tutNextSubId);
    print("[tut open] " .. self.tutId .. " " .. self.tutSubId);
    -- 注册完成事件
    self:RegisterEndEvent();
    -- 显示
    UIManager:Open(nil,UIConst.UIPanel_Tut);
end

-- 结束新手引导步骤
function _M:EndTut(tutId,tutSubId)
    if self.tutId == 0 then 
        return;
    end
    
    if self.tutId ~= tutId or self.tutSubId ~= tutSubId then 
        return;
    end
    print("[tut end] " .. self.tutId .. " " .. self.tutSubId);
    -- 是否是关键引导，关键引导完成之后这个引导就完成了，如果还有后续的引导，只是展示作用。
    if self.tutInfo.key == 1 then 
        -- 给服务器发送完成消息
        TutData:SendTutEnd(self.tutId);
    end

    self.tutId = 0;
    self.tutSubId = 0;
    self.tutInfo = nil;
    self:ClearTut();
    if self.tutNextId == 0 then
        self:CloseTut();
    end
end

-- 清理新手引导步骤 并未关闭新手引导界面，因为后面还有后续的步骤
function _M:ClearTut()
    UIManager:GetControlScript(UIConst.UIPanel_Tut):ClearTut();
end
-- 关闭新手引导界面
function _M:CloseTut()
    UIManager:Close(UIConst.UIPanel_Tut,true);
end

-- 存在将要做的引导
function _M:GetCanDoTutByView(viewName)
    -- 获取当前页面的新手引导
    -- 可能不止一个，取优先级最高的一个，order越小优先级越高
    local candoTutId = 0;
    local candoTutSubId = 0;
    local candoOrder = 100000;
    local tutList = self.tutConfig[viewName];
    if tutList then
        for i, tutInfo in ipairs(tutList) do
            local tutId = tutInfo.tutId;
            -- 可以做的引导
            if TutData:IsCando(tutId) then
                -- 获取优先级最高的一个引导（order越小优先级越高）
                if tutInfo.order < candoOrder then
                    candoOrder = tutInfo.order;
                    candoTutId = tutId;
                    candoTutSubId = tutInfo.tutSubId;
                end
            end
        end
    end
    return candoTutId,candoTutSubId;
end
function _M:GetTutInfo(tutId,tutSubId)
    local tutId = tutId or self.tutId;
    local tutSubId = tutSubId or self.tutSubId;
    for viewName, tutInfoList in pairs(self.tutConfig) do
        for i, tutInfo in ipairs(tutInfoList) do
            if tutInfo.tutId == tutId and tutInfo.tutSubId == tutSubId then
                return tutInfo;
            end
        end
    end
    return nil;
end
-- endregion

-- region 事件扩展：用于增加新手引导类型
-- region 开启事件：注册
function _M:RegisterOpenEvent()
    -- 注册界面打开触发
    RegisterMessage(MsgConst.UI_Open,self.OpenEvent_UI_Open,self);
end
-- 开启事件：UI打开
function _M:OpenEvent_UI_Open(msg)
    local viewName = msg.viewName;

    local tutId = 0;
    local tutSubId = 0;
    -- 是否存在引导流程
    if self.tutNextId > 0 then
        -- 打开的页面就是新手引导需要的页面
        if self.tutNextInfo.viewName == viewName then
            tutId = self.tutNextId;
            tutSubId = self.tutNextSubId;
        end
    else
        -- 开启新的引导
        tutId,tutSubId = self:GetCanDoTutByView(viewName);
    end
    self:OpenTut(tutId,tutSubId);
end
-- endregion

-- region 完成事件：注册
-- 触发事件
TutManager.TriggerEventType_UI_Open = 1;    -- 界面打开
-- 完成事件
TutManager.EndEventType_UI_Click = 1;       -- 点击完成
TutManager.EndEventType_Msg_Receive = 2;    -- 收到消息完成
function _M:RegisterEndEvent()
    local endEventType = self.tutInfo.endEventType;
    local endEventValue = self.tutInfo.endEventValue;

    if endEventType == self.EndEventType_UI_Click then
        -- 完成事件：UI点击
        self:EndEvent_UI_Click();
    elseif endEventType == self.EndEventType_Msg_Receive then
        -- 收到消息完成功能
        RegisterMessage(endEventValue,self.EndEvent_Msg_Receive,self);
    end
end
-- 完成事件：UI点击
function _M:EndEvent_UI_Click()
    local view = UIManager:GetControlScript(self.tutInfo.viewName);
    if view then
        local go = view:GetNode(self.tutInfo.endEventValue);
        if go then
            AddTopClick(go,self.EndEvent_UI_Click_Trigger);
        else
            print("EndEvent_UI_Click is error " .. self.tutInfo.viewName .." not find "..self.tutInfo.endEventValue);
        end
    end
end
function _M.EndEvent_UI_Click_Trigger(sender)
    if not _M.tutInfo then
        return;
    end
    -- 取消注册
    DelClick(sender,_M.EndEvent_UI_Click_Trigger);
    -- 完成
    _M:EndEvent();
end
-- 完成事件：收到消息
function _M:EndEvent_Msg_Receive()
    if not self.tutInfo then
        return;
    end
    -- 取消注册
    RemoveMessage(self.tutInfo.endEventValue,self.EndEvent_Msg_Receive);
    -- 完成
    self:EndEvent();
end

function _M:EndEvent()
    if not self.tutInfo then
        return;
    end

    local endEventType = self.tutInfo.endEventType

    if endEventType == self.EndEventType_None then
        self:EndTut(self.tutId,self.tutSubId);
    elseif endEventType == self.EndEventType_UI_Click then
        self:EndTut(self.tutId,self.tutSubId);
    elseif endEventType == self.EndEventType_Msg_Receive then
        -- 等待消息返回才能完成
    else
        -- 还有一些事件也不能直接完成 比如拖动 滑动事件 必须等待事件完成才能触发完成
    end

    -- 完成当前步骤引导
    self:EndTut(self.tutId,self.tutSubId);

    -- 是否存在下一步引导
    if self.tutNextId == 0 then
        return;
    end

    -- 是否还存在下一步引导
    if not TutData:IsCando(self.tutNextId) then
        return;
    end
    if UIManager:GetControlScript(self.tutNextInfo.viewName):IsShow() then
        self:OpenTut(self.tutNextId,self.tutNextSubId);
    else
        -- 页面打开的时候会自动触发 self:MessageUIOpen 从而触发下一引导
    end
end
-- endregion
-- endregion

-- region 配置
-- TODO 新手引导的配置数据 后期使用表格
function _M:InitTutConfig()
    self.tutConfig = {
        --[[[UIConst.UIPanel_Main] = {
            -- 引导：第一步
            {viewName = UIConst.UIPanel_Main,tutId=1000,tutSubId=1,tutNextId=1000,tutNextSubId=2,order=1,triggerEventType = 1, triggerEventValue="main/singleButton", endEventType=1,endEventValue="main/singleButton"},
            -- 引导：第三步
            {viewName = UIConst.UIPanel_Main,tutId=1000,tutSubId=3,tutNextId=1000,tutNextSubId=4,order=1,triggerEventType = 1, triggerEventValue="main/grid/001", endEventType=1,endEventValue="main/grid/001"},
            -- 引导：第四步
            {viewName = UIConst.UIPanel_Main, tutId=1000,tutSubId=4,tutNextId=1000,tutNextSubId=5, order=1, triggerEventType = 1, triggerEventValue="main/familyButton", endEventType=1,endEventValue="main/familyButton"}
        },
        [UIConst.UIPanel_Father] = {
            -- 引导：第二步
            {viewName = UIConst.UIPanel_Father, tutId=1000,tutSubId=2,tutNextId=1000,tutNextSubId=3, order=1, triggerEventType = 1,triggerEventValue="main/grid/001", endEventType=1,endEventValue="main/grid/001"},
            -- 引导：第五步
            {viewName = UIConst.UIPanel_Father, tutId=1000,tutSubId=5,tutNextId=0,tutNextSubId=0, order=1, triggerEventType = 1,triggerEventValue="main/grid/002", endEventType=1,endEventValue="main/grid/002", key=1},
        },--]]
    };
end
-- endregion

_M:Init();