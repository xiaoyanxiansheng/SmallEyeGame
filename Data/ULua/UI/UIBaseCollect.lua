--[[
	UI收集器
	作用：当我们需要同时打开多个页面的时候将其组成一个集合
--]]
UIBaseCollect = class("UIBaseCollect");

local _M = UIBaseCollect;

function _M:ctor()
	-- 打开页面参数
	self.params = {};
	-- 已加载页面
	self.initViews = {};
	-- 将要打开的页面
	self.openingViews = {};
	-- 已经打开的页面
	self.openedViews = {};
end

function _M:Open(views,params,showFinishCall)
	if not self:CheckViews(views) then 
		return;
	end

	self:Init(views,params,function()
			self:Show(showFinishCall);
		end);
end

function _M:Init(params,initFinishCall,views)
	if not self:CheckViews(views) then 
		return;
	end
	
	self.params = params;
	self:AddInitView(views);
	self:AddOpenedViews(views);

	local curInitCount = 0;
	local totalInitCount = #views;
	for i=1,totalInitCount do
		-- 获取页面脚本
		local viewScript = views[i];
		viewScript:Init(function()
				curInitCount = curInitCount + 1;
				if curInitCount == totalInitCount then 
					if initFinishCall then 
						initFinishCall();
					end
				end
			end);
end
function _M:Show(showFinishCall,isBack)
	if not self:CheckViews(self.openingViews) then 
		return;
	end

	for i,v in ipairs(self.openingViews) do
		v:Show(isBack);
	end

	table.Clear(self.openingViews);
end
function _M:Hide()
end
function _M:UnInit()
end

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

function _M:AddInitView(views,isReset)
	if isReset then
		table.Clear(self.initViews);
	end
    table.AddTable(self.initViews,views);
end

function _M:AddOpeningViews(views,isReset)
	if isReset then
		table.Clear(self.openingViews);
	end
	table.AddTable(self.openingViews,views);
end

function _M:AddOpenedViews(views,isReset)
	if isReset then
		table.Clear(self.openedViews);
	end
	table.AddTable(self.openedViews,views);
end