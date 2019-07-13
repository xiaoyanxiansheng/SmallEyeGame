--[[
	UI收集器
	作用：当我们需要同时打开多个页面的时候将其组成一个集合
--]]
UIBaseCollect = class("UIBaseCollect");

local _M = UIBaseCollect;

#region 对外接口
-- 加载UI集合
function _M:Init(params,initFinishCall,views)
	if not self:CheckViews(views) then 
		return;
	end
	
	-- UI参数设置
	self.params = params;
	-- 加载列表
	self:AddInitView(views);
	-- 等待打开列表
	self:AddOpeningViews(views);

	-- 加载所有UI 全部加载完成后才算加载完成
	local curInitCount = 0;
	local totalInitCount = #views;
	for i=1,totalInitCount do
		-- 获取页面脚本
		local viewScript = views[i];
		viewScript:SetParams(params);
		viewScript:Init(function()
				curInitCount = curInitCount + 1;
				if curInitCount == totalInitCount then 
					if initFinishCall then 
						initFinishCall();
					end
				end
			end);
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
	-- 从后往前关闭UI
	local UICount = #self.openedViews;
	for i=1,UICount do
		local index = UICount - i + ;
		-- 这里需要注意 只有主UI才有权利完成之后返回
		local view = self.openedViews[index];
		local tempCloseFinishCall = view:IsMainUI() and closeFinishCall or nil;
		self:Close(self.openedViews[index],tempCloseFinishCall,isDestory);
	end
end

-- 关闭UI
function _M:Close(viewScript,closeFinishCall,isDestory)
	self:RemoveOpeningView(viewScript);
	self:RemoveOpenedView(viewScript);
	if isDestory then 
		self:RemoveInitView(viewScript);
	end
	viewScript:Close(closeFinishCall,isDestory);
end
#endregion

#region 对内接口
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

function _M:AddInitView(views,isReset)
	if self.initViews then 
		self.initViews;
	end
	if isReset then
		table.Clear(self.initViews);
	end
    table.AddTable(self.initViews,views);
end
function _M:RemoveInitView(view)
	return table.Remove(self.initViews,view,true);
end
function _M:AddOpeningViews(views,isReset)
	if self.openingViews then 
		self.openingViews = {};
	end
	if isReset then
		table.Clear(self.openingViews);
	end
	table.AddTable(self.openingViews,views);
end
function _M:RemoveOpeningView(view)
	return table.Remove(self.openingViews,view,true);
end
function _M:AddOpenedViews(views,isReset)
	if not self.openedViews then 
		self.openedViews = {};
	end
	if isReset then
		table.Clear(self.openedViews);
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
#endregion