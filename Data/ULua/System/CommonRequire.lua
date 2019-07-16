-- 全局变量
require "Data/ULua/System/Global";
-- 全局定义
require "Data/Script/Common/Define";
-- 加载模块
require "Data/Script/Util/ResourceLoad";
-- table的扩展功能
require "Data/ULua/System/tableExt";
-- 类模块
require "Data/ULua/System/Class";
-- 消息模块
require "Data/ULua/System/Message";
-- 游戏逻辑
require "Data/ULua/System/GameMain";
----------------------- 数据模块 ------------------------
require "Data/Script/Data/TutData";
------------------------ TODO UI模块 后期需要分开 因为涉及到了服务器 服务器不需要UI相关
require "Data/ULua/UI/UIConst";
require "Data/ULua/UI/UIManager";
require "Data/ULua/UI/UIBaseCollect";
require "Data/ULua/UI/UIBaseView";
require "Data/ULua/UI/UILayer";
require "Data/ULua/UI/Views/Tut/TutManager";
