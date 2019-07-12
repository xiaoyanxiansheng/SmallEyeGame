--[[
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

-- 加载ui
function _M:Init(params,initFinishCall,...)
	local views = {...};
	local viewCollect = self:GetViewCollect(views);
	if not viewCollect then 
		print("UIManager Init error");
		return;
	end
	viewCollect:Init(params,initFinishCall,views);
end
-- 打开UI或者UI集合
-- 1 当前UI含主UI 关闭上一个UI集合再打开当前
-- 2 当前UI不含主UI 直接打开UI
function _M:Open(views,params)
	-- 加载
	self:Init(views,function(viewCollect)
		-- 显示

		end)
end
-- 关闭UI或者UI集合
-- 1 当前UI是主UI 先关闭当前UI集合然后打开上一次UI集合
-- 2 当前UI不是主UI 直接关闭
function _M:Close(view,isDestory)
end