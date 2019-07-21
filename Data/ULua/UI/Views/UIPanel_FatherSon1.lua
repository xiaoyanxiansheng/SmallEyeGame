
UIPanel_FatherSon1 = UIBaseView.New(UIConst.UIPanel_FatherSon1);

function UIPanel_FatherSon1:OnCreate()
	---------------------- 写法一 -----------------
	-- 等级
    local lvLabTrans = self:GetNode("main/Sprite/Label");
    if lvLabTrans then 
    	self.lvLab = lvLabTrans.GetComponent("UIlabel");
    end
    -- 血量
    local bloodLabTrans = self:GetNode("main/Sprite/Label (1)");
    if bloodLabTrans then 
    	self.bloodLab = bloodLabTrans.GetComponent("UIlabel");
    end
    -- 战力
    local powerLabTrans = self:GetNode("main/Sprite/Label (2)");
    if powerLabTrans then 
    	self.powerLab = powerLabTrans.GetComponent("UIlabel");
    end
    -- 速度
    local speedLabTrans = self:GetNode("main/Sprite/Label (3)");
    if speedLabTrans then 
    	self.speedLab = speedLabTrans.GetComponent("UIlabel");
    end

    ---------------------- 写法二 -----------------
    self.labs = {};
    local labPathList = {"main/Sprite/Label","main/Sprite/Label (1)","main/Sprite/Label (2)","main/Sprite/Label (3)"};
    for i = 1,#labPathList do 
    	local labTrans = self:GetNode(labPathList);
    	if labTrans then 
    		table.insert(self.labs,labTrans);
    	end
    end

    ---------------------- 写法三 -----------------
    self.lvLab
    self.bloodLab
    self.powerLab
    self.speedLab
end

function UIPanel_FatherSon1:OnRegisterMessage()
    print("UIPanel_FatherSon1 OnRegisterMessage");
end

function UIPanel_FatherSon1:OnShow()
	---------------------- 写法一 -----------------
    self.lvLab.text 	= "等级：1";
    self.bloodLab.text 	= "血量：1";
    self.powerLab.text 	= "战力：1";
    self.speedLab.text 	= "速度：1";

    ---------------------- 写法二 -----------------
    PlayerDisplayPlugin.ShowDirect(self.playerCore);
end

function UIPanel_FatherSon1:OnClose()
    print("UIPanel_FatherSon1 OnClose");
end

function UIPanel_FatherSon1:OnDestory()
    print("UIPanel_FatherSon1 OnDestory");
end