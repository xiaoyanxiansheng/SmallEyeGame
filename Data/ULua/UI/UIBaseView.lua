--[[
	UI分类
		1 主UI(自动流程)：每个UI集合必须有一个，打开UI集合前需要关闭当前UI集合，这时只需要处理打开逻辑就行；关闭当前UI集合后需要打开上次关闭的UI集合，这时只需要处理关闭逻辑就行。
		2 主UI(手动流程)：每个UI集合必须有一个，不受自动打开和关闭的影响。比如一些弹出框。
		0 子UI：和主UI一起构成UI集合
--]]
---@class UIBaseView
UIBaseView = Class("UIBaseView");

local _M = UIBaseView;

function _M:ctor(name)
	self.name = name;

	self.params = nil;				-- 页面打开后的参数
	-- 加载流程
	self.uiInitRequestId = 0;		-- 异步请求ID
	self.uiInitFinishCall = nil;	-- 请求加载完成后的回调
	self.uiInstanceId = 0;			-- UI的实例ID
	self.uiBindCore = nil;			-- 绑定Prefab中节点控件

	self.registerMessages = nil;	-- 注册的消息

	-- 打开关闭流程
	self.isShow = false;			-- 当前UI是否显示

	-- 注册脚本
	UIManager:SetControlScript(self.name,self);
end

-- 设置UI参数
function _M:SetParams(params)
	self.params = params;
end

-- 加载
function _M:Init(initFinishCall)
	-- 加载中
	if self:IsIniting() then
		return;
	end
	-- 已经加载
	if self:IsInit() then
		if initFinishCall then 
			initFinishCall();
		end
		return;
	end

	-- 开始加载
	self.uiInitFinishCall = initFinishCall;
	self:ShowFullScreenMask();
	self.uiInitRequestId = CreateUIPanelAsync(GetPrefabPath(self.name),function(instanceId) self:OnCreateInstance(instanceId) end);
end

function _M:OnCreateInstance(instanceId)
	self:CloseFullScreenMask();
	if instanceId == 0 then
		print("OnCreateInstance is error " ,self.name);
		return;
	end
	
	self.uiInitRequestId = 0;
	self.uiInstanceId = instanceId;
	
	-- 绑定UICore
	self:BindUICore();
	
	-- 注册UI消息事件
	self:BaseRegisterMessage();

	-- 加载完成
	self:OnCreate();
	if self.uiInitFinishCall then 
		self.uiInitFinishCall();
		self.uiInitFinishCall = nil;
	end
end

-- 打开
-- isBack：当关闭当前UI时会自动打开前一个关闭的UI，这时isBack为true
function _M:Show(isBack)
	if self:IsShow() then
		self:OnShow();
		return;
	end
	-- 1 计算UI层级
	self:SetUILayer();
	-- 2 加载atlas
	self:LoadAtlas(function()
			self:OnShowBefore(isBack);
		end);
end

-- 关闭
function _M:Close(isDestory,closeFinishCall)
	if not self:IsShow() then
		self:CloseAfter(isDestory,closeFinishCall);
		return;
	end

	self:CloseFullScreenMask();
	-- 1 释放图集
	self:ReleaseAtlas();
	
	-- 2 关闭GameObject
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		print("Close is error " .. self.name);
		return;
	end
	self.isShow = false;
	obj.gameObject:SetActive(false);
	
	-- 3 删除UI层级
	self:DelUILayer();
	
	-- 4 关闭完成
	self:OnClose();

	-- 5 关闭之后的流程
	self:CloseAfter(isDestory,closeFinishCall);
end

function _M:CloseAfter(isDestory,closeFinishCall)
	if closeFinishCall then
		closeFinishCall();
	end
	
	if isDestory then
		self:UnInit();
	end
end

-- 卸载
function _M:UnInit()
	if self:IsShow() then
		print("please close it first");
		return
	end
	-- 加载中
	if self:IsIniting() then
		CancelCreateGameObjectAsync(self.uiInitRequestId);
		self.uiInitRequestId = 0;
		return;
	end
	-- 已经卸载
	if not self:IsInit() then
		return;
	end

	-- 1 清理消息
	self:RemoveRegisterMessage();

	-- 2 解绑UICore
	self:UnBindUIcore();

	-- 3 卸载GameObject
	DestoryGameObject(self.uiInstanceId);
	self.uiInstanceId = 0;

	-- 4 数据清理
	self:ClearParams();

	-- 5 卸载完成
	self:OnDestory();
end

-- 清理数据
function _M:ClearParams()
	self.params = nil;
end

-- 打开前处理
function _M:OnShowBefore(isBack)
	-- 获取实例
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		pring("OnShowBefore is error " .. self.name);
		return;
	end
	
	-- 显示
	self.isShow = true;
	obj.gameObject:SetActive(true);

	-- 显示完成
	self:OnShow(isBack);

	-- 通知UI已经打开
	local msg = BeginMessage(MsgConst.UI_Open);
	msg.viewName = self.name;
	SendMessage(msg);
end

-- 加载完成
function _M:OnCreate()
	-- 子类重写
end
-- 注册事件
function _M:OnRegisterMessage()
	-- 子类重写
end
-- 打开完成
function _M:OnShow(isBack)
	-- 子类重写
end
-- 关闭完成
function _M:OnClose()
	-- 子类重写
end
-- 卸载完成
function _M:OnDestory()
	-- 子类重写
end

-- 绑定UI控制：目的是为了让脚本方便的获取需要的节点或者控件
function _M:BindUICore()
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		print("BindUICore is error " .. self.name);
		return;
	end
	self.uiBindCore = obj.transform:GetComponent("UICore");
	if self.uiBindCore then 
		self.uiBindCore:Init(self);
	end
end
-- 解绑UICore：绑定的UI控件是当前的，如果卸载后再加载，里面保存的将是上一个UI的控件，所以需要删除
function _M:UnBindUIcore()
	if not self.uiBindCore then 
		return;
	end
	self.uiBindCore:UnInit();
end

-- 事件
function _M:BaseRegisterMessage()
	self:OnRegisterMessage();
end
function _M:RegisterMessage(msgName,call)
	if not self.registerMessages then 
		self.registerMessages = {};
	end
	if not self.registerMessages[msgName] then 
		self.registerMessages[msgName] = {};
	end
	local call = function(msg)
					-- 我们规定只有显示的UI才能收到更新，
					-- 如果需要隐藏的UI也收到更新那么换成打开UI的时候再刷新一次UI就行了
					if self:IsShow() then 
						call(msg);
					end
				end
	table.InsertOnlyValue(self.registerMessages[msgName],call);
	-- 注册消息
	RegisterMessage(msgName,call,self);
end
function _M:RemoveRegisterMessage()
	if not self.registerMessages then 
		return;
	end
	for k,v in pairs(self.registerMessages) do
		-- 删除消息
		RemoveMessage(k,v);
	end
	self.registerMessages = nil;
end

-- 加载Atals
function _M:LoadAtlas(onLoadAtlas)
	-- TODO 目前不处理UI和图集分离
	if onLoadAtlas then 
		onLoadAtlas();
	end
end
function _M:ReleaseAtlas()
	-- TODO 目前不处理UI和图集分离
end
-- 设置UI层级
function _M:SetUILayer()
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		print("SetUILayer is error " , self.name);
		return;
	end
	local layer = UILayer:CalculateLayer(self);
	self:AddUILayerHelper(layer);
end
-- 删除UI层级
function _M:DelUILayer()
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		print("SetUILayer is error " , self.name);
		return;
	end
	local layer = UILayer:DelLayer(self);
	self:AddUILayerHelper(-layer);
end
function _M:AddUILayerHelper(layer)
	local obj = GetGameObjectById(self.uiInstanceId);
	if not obj then 
		print("AddUILayerHelper is error " .. self.name);
		return;
	end
	local addLayer = layer * 100;
	local panels = CommonUtil.GetUIPanels(obj);
	-- C#中的用法 在lua中显得很另类
	for i = 0, panels.Length - 1 do
		panels[i].depth = panels[i].depth + addLayer;
	end
end

-- TODO 全屏遮罩处理
function _M:ShowFullScreenMask()
	-- TODO
end
function _M:CloseFullScreenMask()
	-- TODO
end

-- 主UI(自动流程) 文件头有解释
function _M:IsMainUI()
	if UISetting[self.name] 
		and UISetting[self.name].uiType 
		and UISetting[self.name].uiType == 1 then 
		return true;
	end
	return false;
end
-- 主UI(手动流程) 文件头有解释
function _M:IsIgnoreMainUI()
	if UISetting[self.name]
		and UISetting[self.name].uiType 
		and UISetting[self.name].uiType == 2 then 
		return true;
	end
	return false;
end
-- 子UI
function _M:IsSonUI()
	if UISetting[self.name] 
		and UISetting[self.name].uiType 
		and UISetting[self.name].uiType ~= 0 then
		return false;
	end
	return true;
end

-- 加载中
function _M:IsIniting()
	return self.uiInitRequestId > 0;
end
-- 是否加载
function _M:IsInit()
	return self.uiInstanceId ~= 0;
end
-- 是否显示
function _M:IsShow()
	return self.isShow;
end
-- 通过路径获取节点
function _M:GetNode(path)
	local trans = self.uiBindCore.transform:FindChild(path);
	if trans then
		return trans.gameObject;
	end
	return nil;
end

-- region
function _M:GetName()
	return self.name;
end
-- endregion