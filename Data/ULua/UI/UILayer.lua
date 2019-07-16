--[[
	UI的层级管理
		1 普通UI：层级会随着打开的顺序依次增加
		2 上层UI：层级是固定的
	注意点
		打开UI的顺序一定是先关闭当前UI再打开UI，不然会导致UI的最高层级一直增加，
		最终会导致普通UI的层级高于上层UI层级
--]]

UILayer = {
	-- 设置三个上层UI层级 一般情况下上层UI的显示只会有一个 比如一些通用的弹出框、提示之类的
	topLayers = {500,510,520};
	-- 普通UI层级 
	commonLayers = {};
};

local _M = UILayer;

-- 计算出一个可用层级 
-- 在当前最高层级的基础上加1
function _M:CalculateLayer(view)
	local name = view:GetName();

	-- 上层UI层级
	local layer = self:GetTopLayer(name);
	if layer > 0 then
		return layer;
	end

	-- 普通UI层级
	self.commonLayers[name] = nil;
	local maxLayer = 0;
	for k,v in pairs(self.commonLayers) do
		if v > maxLayer then 
			maxLayer = v;
		end
	end
	self.commonLayers[name] = maxLayer + 1;
	return self.commonLayers[name];
end

-- 删除一个层级
function _M:DelLayer(view)
	local name = view:GetName();

	-- 上层UI层级
	local layer = self:GetTopLayer(name);
	if layer > 0 then
		return layer;
	end

	-- 普通UI层级
	if self.commonLayers[name] then 
		layer = self.commonLayers[name];
		self.commonLayers[name] = nil;
	end

	return layer;
end

-- 上层UI层级
function _M:GetTopLayer(name)
	local topLayerIndex = 0;
	if UISetting[name] and UISetting[name]["topLayer"] then
		topLayerIndex = UISetting[name]["topLayer"];
	end
	if topLayerIndex > 0 then
		return self.topLayers[topLayerIndex]
	end
	return 0;
end