using UnityEngine;
using System.Collections.Generic;
using LuaInterface;
using System;
/// <summary>
/// 提供一些方便方法
/// </summary>
public class CommonUtil{

	public static UIPanel[] GetUIPanels(GameObject go)
    {
        return go.GetComponentsInChildren<UIPanel>(true);
    }

    public static void TrimGameObejct(GameObject go)
    {
        if (go == null) return;
        go.transform.localPosition = Vector3.zero;
        go.transform.localScale = new Vector3(1, 1, 1);
        go.transform.localRotation = Quaternion.identity;
    }

    #region 注册事件
    public static Dictionary<LuaFunction, Delegate> LuaFuncToDel = new Dictionary<LuaFunction, Delegate>();
    /// <summary>
    /// 注册点击事件：触发时最先响应
    /// </summary>
    /// <param name="go"></param>
    /// <param name="luaFunc"></param>
    public static void AddTopClick(GameObject go, LuaFunction luaFunc)
    {
        UIEventListener listener = UIEventListener.Get(go);

        Delegate[] dels = listener.onClick.GetInvocationList();
        List<UIEventListener.VoidDelegate> tempDeList = new List<UIEventListener.VoidDelegate>();
        for (int i = dels.Length - 1; i >= 0; i--)
        {
            Delegate del = dels[i];
            UIEventListener.VoidDelegate tempDel = (UIEventListener.VoidDelegate)del;
            tempDeList.Add(tempDel);
            listener.onClick -= tempDel;
        }
        UIEventListener.VoidDelegate luaFuncDel = (GameObject sender) =>
        {
            if (luaFunc != null)
            {
                luaFunc.Call(sender);
            }
        };
        listener.onClick += luaFuncDel;
        for (int i = tempDeList.Count - 1; i >= 0; i--)
        {
            listener.onClick += tempDeList[i];
        }
    }
    /// <summary>
    /// 注册点击事件
    /// </summary>
    /// <param name="go"></param>
    /// <param name="luaFunc"></param>
    public static void AddClick(GameObject go, LuaFunction luaFunc)
    {
        UIEventListener.VoidDelegate del = (GameObject sender) => {
            if (luaFunc != null)
            {
                luaFunc.Call(sender);
            }
        };
        LuaFuncToDel.Add(luaFunc, del);
        UIEventListener.Get(go).onClick += del;
    }
    /// <summary>
    /// 移除一个注册事件
    /// </summary>
    /// <param name="go"></param>
    /// <param name="luaFunc"></param>
    public static void DelClick(GameObject go , LuaFunction luaFunc)
    {
        Delegate del = null;
        if(LuaFuncToDel.TryGetValue(luaFunc,out del))
        {
            return;
        }
        UIEventListener.Get(go).onClick -= (UIEventListener.VoidDelegate)del;
    }
    #endregion

    #region GameObject 相关
    public static Component AddComponent(GameObject go, string comName)
    {
        return go.AddComponent(Type.GetType(comName));   
    }
    #endregion
}
