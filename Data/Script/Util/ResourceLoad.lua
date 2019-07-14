--[[
	创建实体
		1 GameObject
		2 UI	
--]]

-- 取消加载
function CancelCreateGameObjectAsync(requestId)
	ResourceUtil.CancelCreateGameObjectAsync(requestId);
end
-- 创建GameObject
function CreateGameObjectAsync(objType,name,onCreate)
	return ResourceUtil.CreateGameObjectAsync(objType,name,onCreate);
end

-- 卸载GamObject
function DestoryGameObject(instanceId)
	ResourceUtil.DestoryGameObject(instanceId);
end

-- 创建UI
function CreateUIPanelAsync(name,onCreate)
	return CreateGameObjectAsync(2,name,onCreate);
end