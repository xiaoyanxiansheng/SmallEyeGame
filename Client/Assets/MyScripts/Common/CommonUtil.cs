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
}
