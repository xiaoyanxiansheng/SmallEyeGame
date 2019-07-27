---
--- 编辑使用
--- 将文件转化成树结构
---

---@class ActionTreeTool
ActionTreeTool = {

};

local _M = ActionTreeTool;

-- region 注册
-- 注册模块
function BEGIN_MODEL()
    _M.TEMP_CUR_TRIGGERS = {};
    return _M.TEMP_CUR_TRIGGERS;
end
function END_MODEL()

end
-- 注册事件
function BEGIN_EVENT(eventType)
    local eventClass = ActionTreeManager.registreEvents[eventType];
    local eventIns = eventClass.New(eventType);
    table.insert(_M.TEMP_CUR_TRIGGERS,eventIns);
end
function END_EVENT()

end
-- 注册父节点
function BEGIN_FATHER_NODE(nodeType,...)
    local nodeClass = ActionTreeManager.registerNodes[nodeType];
    local fatherIns = nodeClass.New(nodeType);
    SET_PROP_VALUE(fatherIns,...);
    local eventIns = _M.TEMP_CUR_TRIGGERS[#_M.TEMP_CUR_TRIGGERS];
    if not eventIns.treeRoot then
        eventIns.treeRoot = fatherIns;
    else
        _M.TEMP_CUR_FATHER_NODE:AddChildNode(fatherIns);
        fatherIns.parentNode = _M.TEMP_CUR_FATHER_NODE;
    end
    _M.TEMP_CUR_FATHER_NODE = fatherIns;
end
function END_FATHER_NODE()
    _M.TEMP_CUR_FATHER_NODE = _M.TEMP_CUR_FATHER_NODE.parentNode;
end
-- 注册子节点
function ADD_NODE(nodeType,...)
    local nodeClass = ActionTreeManager.registerNodes[nodeType];
    local nodeIns = nodeClass.New();
    SET_PROP_VALUE(nodeIns,...);
    _M.TEMP_CUR_FATHER_NODE:AddChildNode(nodeIns);
    nodeIns.parentNode = _M.TEMP_CUR_FATHER_NODE;
end
-- endregion

-- region 属性设置
VT = {
    INT = 1,
    FLOAT = 2,
    STRING = 3,
    LUAFUNCTION = 4,
    BOOL = 5,
}
function SET_PROP(t,keyStr,propValueType,propValue)
    if not t.prop then
        t.propKey = {};
        t.propValueType = {};
        t.propValue = {};
    end
    table.insert(t.propValueType,propValueType);
    table.insert(t.propValue,propValue);
    t.propKey[keyStr] = #t.propValueType;
end
function SET_PROP_VALUE(t,...)
    t.propValue = {...};
end
function GET_PROP(t,keyStr)
    local index = t.propKey[keyStr];
    if not index then
        return nil;
    end
    local value = nil;
    local propType = t.propValueType[index];
    local propValue = t.propValue[index];
    if propType == VT.LUAFUNCTION then
        value = propValue();
    else
        value = propValue;
    end
    return value;
end
-- endregion