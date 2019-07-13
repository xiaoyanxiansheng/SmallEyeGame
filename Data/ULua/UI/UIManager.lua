--[[
	UI对外部提供的管理类
	加载 打开 关闭 卸载
--]]

UIManager = {
	-- ui控制脚本
	uiViewScripts = {};
	-- 已加载集合
	initViewCollects = {};
	-- 已打开集合
	openViewCollects = {};
};

local _M = UIManager;

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
	if not viewCollect or #viewCollect == 0 then 
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
		local topViewCollect = self.openViewCollects[#self.openViewCollects];
		if topViewCollect:IsShow() and topViewCollect ~= viewCollect then
			-- 先关闭当前UI集合 然后在打开下一个UI集合
			self:CloseViewCollect(topViewCollect,function()
					self:OpenViewcCollect(viewCollect);
				end);
		else
			self:OpenViewcCollect(viewCollect);
		end
		end,...)
end
function _M:OpenViewcCollect(viewCollect,isBack)
	viewCollect:Show()
end
-- 关闭UI或者UI集合
-- 1 当前UI是主UI 先关闭当前UI集合然后打开上一次UI集合
-- 2 当前UI不是主UI 直接关闭
function _M:Close(viewName,isDestory)
	local viewScript = self:GetControlScript(viewName);
	if viewScript:IsMainUI() then 
		local viewCollect = self:GetViewCollect(viewScript);
		if not viewCollect then 
			print("Close error");
			return;
		end
		-- 先关闭UI集合 然后在打开上次关闭的UI集合
		self:CloseViewCollect(viewCollect,function()
				local topViewCollect = self.openViewCollects[#self.openViewCollects];
				if topViewCollect then 
					self:OpenViewcCollect(topViewCollect,true);
				end
			end,isDestory);
	else
		viewCollect:Close(viewScript);
	end
end
function _M:CloseViewCollect(viewCollect,closeFinishCall,isDestory)
	viewCollect:CloseAll(closeFinishCall,isDestory)
end
--endregion

--region 不对外提供
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
	return nil;
end
-- 获取控制脚本
-- 控制UI的行为: 加载 打开 关闭 卸载
function _M:GetControlScript(viewName)
	if not self.uiViewScripts[viewScript] then 
		local scriptPath = GetUIScriptPath(viewName);
		if scriptPath then 
			require(scriptPath);
		else
			print("GetControlScript error " .. viewName);
		end
	end
	return self.uiViewScripts[viewScript];
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