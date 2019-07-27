MsgConst = {

    -- region 服务器返回消息 由于没有服务器，所以现在客户端直接转化 这个流程得先建立起来 后续改服务器战斗的时候就容易多了
	S2C_Tut_End = 1,                -- 新手引导完成
    S2C_Battle_CreateBattle = 5,    -- 创建战斗
    S2C_Battle_LoaingFinish = 6,    -- 加载完成
    S2C_Battle_StartBattle  = 7,    -- 开始战斗
    -- endregion

	---------------------------------------------------------------------------------------------

    -- region 战斗消息 10000-20000
    Battle_CreateBattle = 10000,    -- 创建战斗

    Preform_Load_Level  = 11000,    -- 加载关卡
    Load_Level_Finish   = 11001,    -- 加载完成
    -- endregion

    -- region UI消息 20000-30000
    UI_Open     = 20001,            -- UI被打开
    UI_Close    = 20002,            -- UI被关闭
    UI_Click    = 20003,            -- 控件被点击
    Tut_End     = 20101,            -- 新手引导完成
    Level_Up    = 29000,	        -- 测试消息
    -- endregion

    -- region 行为树消息 30000-40000
    ActionTree_TriggerEvent = 30000,
    -- endregion
};