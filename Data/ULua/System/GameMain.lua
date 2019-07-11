local _M = {
	LuaManager = nil;
	gameLoop = nil;
};

function _M:Init()
	print("init game main" .. WGTest.aaa)
end

function _M.Update()
	
end

function _M:Uninit()
	self.LuaManager = nil;
end

_M:Init();

return _M;