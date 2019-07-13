using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 提供一些方便方法
/// </summary>
public class CommonUtil{

	public static UIPanel[] GetUIPanels(GameObject go) {
        return go.GetComponentsInChildren<UIPanel>();
    }

}
