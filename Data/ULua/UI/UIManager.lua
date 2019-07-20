--[[
	UI对外部提供的管理类
	加载 打开 关闭 卸载
--]]

UIManager = {
	-- UI相机列表
	uiCameraTransDic = {};

	-- ui控制脚本
	uiViewScripts = {};
	-- 已加载集合
	initViewCollects = {};
	-- 已打开集合
	openViewCollects = {};
};

local _M = UIManager;

-- region 根节点信息
function _M:InitData()
	-- 加载UI的根节点
	local UIRootName = "ui/prefab/uipanel_base";
	CreateGameObjectAsync(1,UIRootName,function(instanceId)
		local obj = GetGameObjectById(instanceId);
		if obj then
			obj.transform.position = Vector3.New(0,0,0);
			obj.gameObject:SetActive(true);
			GameObject.DontDestroyOnLoad(obj);

			-- 初始化相机列表
			self:InitDataCameraList(obj);

			-- 根节点加载完成之后UI相关的流程才真正开始
			self:OpenTestUI();
		else
			print("GameMian is error " .. UIRootName);
		end
	end);
end
-- 三个相机能看到的层
_M.CAMERA_NGUI_BOTTOM 	= "NGUI_BOTTOM";
_M.CAMERA_NGUI 			= "NGUI";
_M.CAMERA_NGUI_TOP 		= "NGUI_TOP";
function _M:InitDataCameraList(rootNode)
	-- 层 对应的 相机
	self.uiCameraTransDic[self.CAMERA_NGUI_BOTTOM] 	= rootNode.transform:FindChild("CameraBottom");
	self.uiCameraTransDic[self.CAMERA_NGUI] 		= rootNode.transform:FindChild("Camera");
	self.uiCameraTransDic[self.CAMERA_NGUI_TOP] 	= rootNode.transform:FindChild("CameraTop");
end
-- 得到一个UI相机
function _M:GetUICameraTrans(name)
	return self.uiCameraTransDic[name];
end
-- UI相机的事件屏蔽
function _M:ForbidUIEvent(name,isForbid)
	self:GetUICameraTrans(name).gameObject:GetComponent("UICamera").enabled = not isForbid;
end
-- 层级设置
function _M:SetNodeLayer(go,layerName)
	if not go then
		return;
	end
	go.layer = UnityEngine.LayerMask.NameToLayer(layerName)
end
-- 测试
function _M:OpenTestUI()
	UIManager:Open(nil,UIConst.UIPanel_Main);
end
-- endregion

--region 对外部提供
-- 加载UI
function _M:Init(params,initFinishCall,...)
	-- 1 获取UI控制脚本
	local viewScripts = {}
	local viewNames = {...};
	for i,v in ipairs(viewNames) do
		table.insert(viewScripts,self:GetControlScript(v));
	end

	-- 2 获取UI集合
	local viewCollect = self:GetViewCollect(viewScripts);
	if not viewCollect then
		print("UIManager Init error");
		return;
	end

	-- 3 加载UI集合
	self:AddInitViewCollect(viewCollect);
	viewCollect:Init(params,function()
			if initFinishCall then 
				initFinishCall(viewCollect);
			end
		end,viewScripts);
end
-- 打开UI或者UI集合 
-- 1 当前UI含主UI 关闭上一个UI集合再打开当前
-- 2 当前UI不含主UI 直接打开UI
function _M:Open(params,...)
	-- 加载
	self:Init(params,function(viewCollect)
		local topViewCollect = self:GetTopShowMainViewCollect();
		if topViewCollect and topViewCollect ~= viewCollect then
			-- 只有主UI并且类型为1的才会进入自动流程
			if viewCollect:IsMainCollect() then
				-- 先关闭当前UI集合 然后在打开下一个UI集合
				self:CloseViewCollect(topViewCollect,function()
					self:OpenViewcCollect(viewCollect);
				end,false,true);
			else
				self:OpenViewcCollect(viewCollect);
			end
		else
			self:OpenViewcCollect(viewCollect);
		end
		end,...)
end
function _M:OpenViewcCollect(viewCollect,isBack)
	self:AddOpenViewCollect(viewCollect);
	viewCollect:Show(isBack)
end
-- 关闭UI或者UI集合
-- 1 当前UI是主UI 先关闭当前UI集合然后打开上一次UI集合
-- 2 当前UI不是主UI 直接关闭
function _M:Close(viewName,isDestory)
	local viewScript = self:GetControlScript(viewName);
	local viewCollect = self:GetViewCollect(viewScript);
	if not viewCollect then
		print("Close error");
		return;
	end
	if viewScript:IsMainUI() then
		-- 先关闭UI集合 然后在打开上次关闭的UI集合
		self:RemoveOpenViewCollect(viewCollect);
		self:CloseViewCollect(viewCollect,function()
				local topViewCollect = self:GetTopMainViewCollect();
				if topViewCollect then 
					self:OpenViewcCollect(topViewCollect,true);
				end
			end,isDestory);
	else
		viewCollect:Close(viewScript);
	end
end
function _M:CloseViewCollect(viewCollect,closeFinishCall,isDestory,isBack)
	if isDestory then
		self:RemoveInitViewCollect(viewCollect);
	end
	if isBack then
		viewCollect:CloseAllAndSave(closeFinishCall,isDestory,isBack);
	else
		viewCollect:CloseAll(closeFinishCall,isDestory,isBack);
	end

end
--endregion

--region 不对外提供
-- 获取显示UI集合(最上层自动流程集合：就是主UI类型为1的UI集合)
-- 因为主UI分两种：类型1 会被自动打开关闭影响，类型2 不会；这里需要的是类型1的主UI
function _M:GetTopShowMainViewCollect()
	local count = #self.openViewCollects;
	for i = 1, count do
		local index = count - i + 1;
		local viewCollect = self.openViewCollects[index];
		if viewCollect:IsShow() and viewCollect:IsMainCollect() then
			return viewCollect;
		end
	end
	return nil;
end
-- 获得UI集合
function _M:GetTopMainViewCollect()
	local count = #self.openViewCollects;
	for i = 1, count do
		local index = count - i + 1;
		local viewCollect = self.openViewCollects[index];
		if viewCollect:IsMainCollect() then
			return viewCollect;
		end
	end
	return nil;
end
-- 获取UI集合
function _M:GetViewCollect(viewScript)
	-- 倒序查找
	local initCount = #self.initViewCollects;
	for i=1,initCount do
		local index = initCount - i + 1;
		local viewCollect = self.initViewCollects[index];
		for k,v in pairs(viewCollect:GetInitViews()) do
			if v == viewScript then 
				return viewCollect;
			end
		end
	end
	return UIBaseCollect.New();
end
-- 获取控制脚本
-- 控制UI的行为: 加载 打开 关闭 卸载
function _M:GetControlScript(viewName)
	if not self.uiViewScripts[viewName] then
		local scriptPath = GetUIScriptPath(viewName);
		if scriptPath then
			require(scriptPath);
		else
			print("GetControlScript error " .. viewName);
		end
	end
	return self.uiViewScripts[viewName];
end
-- 注册控制脚本
function _M:SetControlScript(viewName,script)
	if not self.uiViewScripts[viewName] then
		self.uiViewScripts[viewName] = script;
	end
end

-- 加入加载集合
function _M:AddInitViewCollect(viewCollect)
	self:RemoveInitViewCollect(viewCollect);
	table.insert(self.initViewCollects,viewCollect);
end
-- 移除加载集合
function _M:RemoveInitViewCollect(viewCollect)
	table.Remove(self.initViewCollects,viewCollect,true);
end
-- 加入打开集合
function _M:AddOpenViewCollect(viewCollect)
	self:RemoveOpenViewCollect(viewCollect);
	table.insert(self.openViewCollects,viewCollect);
end
-- 移除打开集合
function _M:RemoveOpenViewCollect(viewCollect)
	table.Remove(self.openViewCollects,viewCollect,true);
end
--endregion

_M:InitData();