--[[
	UI收集器
	作用：当我们需要同时打开多个页面的时候将其组成一个集合
--]]
---@class UIBaseCollect
UIBaseCollect = Class("UIBaseCollect");

local _M = UIBaseCollect;

-- region 流程接口
-- 加载UI集合
function _M:Init(params,initFinishCall,views)
	if not self:CheckViews(views) then
		return;
	end

	-- UI参数设置
	self.params = params;
	-- 加载列表
	self:AddInitView(views);

	-- 加载前开启全屏屏蔽UI：防止看到场景和防止误触
	self:ShowFullScreenMask();
	-- 加载所有UI 全部加载完成后才算加载完成
	local curInitCount = 0;
	local totalInitCount = #views;
	for i=1,totalInitCount do
		-- 获取页面脚本
		local viewScript = views[i];
		viewScript:SetParams(params);
		viewScript:Init(function()
			curInitCount = curInitCount + 1;
			-- 加载完成
			if curInitCount == totalInitCount then
				-- 关闭全屏屏蔽UI
				self:CloseFullScreenMask();
				-- 等待打开列表
				self:AddOpeningViews(views);
				if initFinishCall then
					initFinishCall();
				end
			end
		end);
	end
end

-- 打开UI集合
function _M:Show(isBack)
	if not self:CheckViews(self.openingViews) then
		return;
	end

	-- 打开所有等待打开的UI
	for i,v in ipairs(self.openingViews) do
		v:Show(isBack);
	end

	-- 改变状态为已打开
	self:AddOpenedViews(self.openingViews);
	self.openingViews = nil;
end

-- 关闭UI集合
function _M:CloseAll(closeFinishCall,isDestory)
	-- 卸载流程处理所有UI，关闭流程只需要处理已打开的
	local views = isDestory and self.initViews or self.openedViews;
	if not views or #views == 0 then
		return;
	end

	-- 从后往前关闭UI
	local UICount = #views;
	for i=1,UICount do
		local index = UICount - i + 1;
		local view = views[index];
		-- 这里需要注意 只有主UI才有权利完成之后返回
		local tempCloseFinishCall = view:IsMainUI() and closeFinishCall or nil;
		self:Close(view,tempCloseFinishCall,isDestory);
	end
end
-- 关闭UI集合并且保存当前打开UI到待打开状态
function _M:CloseAllAndSave(closeFinishCall,isDestory)
	-- 保存返回列表
	local openingViews = table.Clone(self.openedViews);

	-- 关闭UI集合
	self:CloseAll(closeFinishCall,isDestory);

	-- 加入保存列表 等待返回流程的时候打开
	if openingViews then
		self:AddOpeningViews(openingViews,true);
	end
end
-- 关闭UI
function _M:Close(viewScript,closeFinishCall,isDestory)
	self:RemoveOpeningView(viewScript);
	self:RemoveOpenedView(viewScript);
	if isDestory then
		self:RemoveInitView(viewScript);
	end
	viewScript:Close(isDestory,closeFinishCall);
end
-- endregion

-- region 帮助函数
function _M:ctor()
	-- 打开页面参数
	self.params = nil;
	-- 已加载页面
	self.initViews = nil;
	-- 将要打开的页面
	self.openingViews = nil;
	-- 已经打开的页面
	self.openedViews = nil;
end

function _M:ShowFullScreenMask()
	-- TODO
end
function _M:CloseFullScreenMask()
	-- TODO
end

function _M:AddInitView(views,isReset)
	if isReset then
		self.initViews = {};
	end
	if not self.initViews then
		self.initViews = {};
	end
    table.AddTable(self.initViews,views);
end
function _M:RemoveInitView(view)
	return table.Remove(self.initViews,view,true);
end
function _M:AddOpeningViews(views,isReset)
	if isReset then
		self.openingViews = {};
	end
	if not self.openingViews then
		self.openingViews = {};
	end
	table.AddTable(self.openingViews,views);
end
function _M:RemoveOpeningView(view)
	return table.Remove(self.openingViews,view,true);
end
function _M:AddOpenedViews(views,isReset)
	if isReset then
		self.openedViews = {};
	end
	if not self.openedViews then
		self.openedViews = {};
	end
	table.AddTable(self.openedViews,views);
end
function _M:RemoveOpenedView(view)
	return table.Remove(self.openedViews,view,true);
end
function _M:GetInitViews()
	return self.initViews;
end
-- 将要打开的UI是否含有主UI
function _M:IsContainMainUI()
	for k,v in pairs(self.openingViews) do
		if v:IsMainUI() then
			return true;
		end
	end
	return false;
end
-- 是否全部是子UI
function _M:IsAllSonUI()
	for k,v in pairs(self.openingViews) do
		if not v:IsSonUI() then
			return false;
		end
	end
	return true;
end
-- 是否在显示中
function _M:IsShow()
	return self:GetMain():IsShow();
end
-- UI集合主UI（一定会有一个）
function _M:GetMain()
	return self.initViews[1];
end
-- 检查有效性
function _M:CheckViews(views)
	if not views then
		print("views is nil");
		return false;
	end
	if #views == 0 then
		print("view is empty");
		return false;
	end

	return true;
end
-- 集合类型：使用主UI类型判断
function _M:IsMainCollect()
	return self:GetMain():IsMainUI();
end
function _M:IsIgnoewMainCollect()
	return self:GetMain():IsIgnoewMainUI();
end
-- endregion