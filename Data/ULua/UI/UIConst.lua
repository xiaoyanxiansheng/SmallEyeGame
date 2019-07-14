---@class UIConst
UIConst = {
	UIPanel_Test = "UIPanel_Test",
	UIPanel_Main = "UIPanel_Main",
};

UIPath = {
	-- UI的name
	UIPanel_Test = {
		-- prefab路径 TODO 通过代码转成小写
		"ui/prefab/uipanel_test",
		-- 脚本路径
		"Data/ULua/UI/Views/UIPanel_Test",
	},
	UIPanel_Main = {
		"ui/prefab/uipanel_main",
		"Data/ULua/UI/Views/UIPanel_Main",
	}
}

function GetPrefabPath(name)
	local name = UIConst[name];
	if name then 
		local info = UIPath[name];
		if info then 
			return info[1];
		end
	end
	return nil;
end
function GetUIScriptPath(name)
local name = UIConst[name];
	if name then 
		local info = UIPath[name];
		if info then 
			return info[2];
		end
	end
	return nil;
end

--[[ 
	TODO 后期优化到表格中去 因为UI的配置会有很多
	比如 
		UI的类型：主UI（自动），主UI（手动），子UI的配置
		UI打开关闭：音效的配置
		UI动画配置
		UI是否忽略另外一些UI的打开：比如当前界面是否忽略邀请，忽略提示信息等等
--]]
UISetting = {
	UIPanel_Main = {
		uiType = 1--2,3
	},
	UIPanel_Test = {
		uiType = 1--2,3
	}
}