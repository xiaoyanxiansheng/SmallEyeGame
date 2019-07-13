--[[
	游戏的入口
--]]

local _M = {
	LuaManager = nil;
	gameLoop = nil;
};

function _M:Init()
	-- 加载UI的根节点
	local UIRootName = "ui/prefab/uipanel_base";
	CreateGameObjectAsync(1,UIRootName,function(instanceId)
			local obj = ResourceUtil.GetGameObjectById(instanceId);
			if obj then 
				obj.transform.position = Vector3.New(0,0,0);
				obj.gameObject:SetActive(true);
				GameObject.DontDestroyOnLoad(obj);

				-- 根节点加载完成之后UI相关的流程才真正开始
				self:InitUI();
			else
				print("GameMian is error " .. UIRootName);
			end
		end);
end

function _M:InitUI()
	-- TODO 测试页面
	UIManager:Open(nil,UIConst.UIPanel_Test);
end

_M:Init();

return _M;