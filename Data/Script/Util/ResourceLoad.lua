--[[
	创建实体
		1 GameObject
		2 UI	
--]]
-- 创建GameObject
function CreateGameObjectAsync(objType,name,onCreate)
	print("CreateGameObjectAsync " .. name);
	return ResourceUtil.CreateGameObjectAsync(objType,name,onCreate);
end

-- 卸载GamObject，也会自动处理加载中的情况
function DestoryGameObject(instanceId)
	ResourceUtil.DestoryGameObject(instanceId);
end

-- 创建UI
function CreateUIPanelAsync(name,onCreate)
	return CreateGameObjectAsync(2,name,onCreate);
end