---@class UIConst
UIConst = {
	-- 单个UI
	UIPanel_Main = "UIPanel_Main",

	-- 单个UI(不受自动打开关闭流程影响,除非手动关闭，否则将一直存在)
	UIPanel_MessageBox = "UIPanel_MessageBox",

	-- 多个UI集合(打开时将下列三个UI全部打开)
	UIPanel_Father = "UIPanel_Father",
	UIPanel_FatherSon1 = "UIPanel_FatherSon1",
	UIPanel_FatherSon2 = "UIPanel_FatherSon2",

	-- 新手引导
	UIPanel_Tut = "UIPanel_Tut",
};

UIPath = {
	-- UI的name
	UIPanel_Main = {
		-- prefab路径 TODO 通过代码转成小写
		"ui/prefab/uipanel_main",
		-- 脚本路径
		"Data/ULua/UI/Views/UIPanel_Main",
	},

	UIPanel_MessageBox = {
		"ui/prefab/uipanel_messagebox",
		"Data/ULua/UI/Views/UIPanel_MessageBox",
	},

	UIPanel_Father = {
		"ui/prefab/uipanel_father",
		"Data/ULua/UI/Views/UIPanel_Father",
	},
	UIPanel_FatherSon1 = {
		"ui/prefab/uipanel_fatherson1",
		"Data/ULua/UI/Views/UIPanel_FatherSon1",
	},
	UIPanel_FatherSon2 = {
		"ui/prefab/uipanel_fatherson2",
		"Data/ULua/UI/Views/UIPanel_FatherSon2",
	},
	UIPanel_Tut = {
		"ui/prefab/uipanel_tut",
		"Data/ULua/UI/Views/Tut/UIPanel_Tut",
	},
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
		UI的类型：1：主UI（自动），2：主UI（手动），0：子UI的配置
		UI的层级：topLayer>0代表上层UI，会一直出现在所有UI的最上层
		UI打开关闭：音效的配置
		UI动画配置
		UI是否忽略另外一些UI的打开：比如当前界面是否忽略邀请，忽略提示信息等等
--]]
UISetting = {
	-- 主UI
	UIPanel_Main = {uiType = 1},
	-- 主UI（上层UI）
	UIPanel_MessageBox = {uiType = 2,topLayer=2},

	UIPanel_Father = {uiType = 1},
	UIPanel_FatherSon1 = {uiType = 0};
	UIPanel_FatherSon2 = {uiType = 0};

	UIPanel_Tut = {uiType = 2,topLayer=1},
}