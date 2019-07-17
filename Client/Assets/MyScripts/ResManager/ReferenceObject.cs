using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 已加载资源的引用
/// 引用为0时卸载
/// </summary>
public class ReferenceObject {

    #region menber
    class ObjectReference
    {
        public void Clear()
        {
            obj = null;
            assetName = null;
            refCount = 0;
        }
        public Object obj;
        public string assetName;
        public int refCount;
    }

    private static Dictionary<string, ObjectReference> _objectReferenceList = new Dictionary<string, ObjectReference>();
    private static List<ObjectReference> _freeObjectReferenceList = new List<ObjectReference>();
    #endregion

    #region 内部方法
    private static ObjectReference GetTempObjectReference()
    {
        ObjectReference or = null;

        if (_freeObjectReferenceList.Count > 0)
        {
            or = _freeObjectReferenceList[0];
        }
        else
        {
            or = new ObjectReference();
        }

        return or;
    }
    private static void RecoveryObjectReference(string assetName)
    {
        ObjectReference or = null;
        if (!_objectReferenceList.TryGetValue(assetName,out or))
            return;

        DestroyObject(or);

        _objectReferenceList.Remove(assetName);
        or.Clear();
        _freeObjectReferenceList.Add(or);
    }
    private static void DestroyObject(ObjectReference or)
    {
        // 删除自己
        if (ResourceUtil.isLog) Debug.Log("UnloadAsset " + or.assetName);
        if (!(or.obj is GameObject))
            Resources.UnloadAsset(or.obj);
        //else
        /* GameObejct的释放方法
            1 assetbundle.unload(true)
            2 Resources.UnloadUnusedAsset()
        */


        // 释放引用bundle
        string bundleName = BundleAsset.GetBundleName(or.assetName);
        if (bundleName == null)
            return;
        ReferenceBundle.ReleaseBundle(bundleName);
    }
    #endregion

    #region 检测
    public static void Update()
    {
        if (_objectReferenceList.Count == 0)
            return;

        List<string> tempOrs = new List<string>();
        foreach(string assetName in _objectReferenceList.Keys)
        {
            ObjectReference or = _objectReferenceList[assetName];
            if (or.refCount <= 0)
            {
                tempOrs.Add(assetName);
            }
        }
        foreach(string assetName in tempOrs)
        {
            RecoveryObjectReference(assetName);
        }
    }

    private static void LogRefCount(ObjectReference or, int addRefCount = 1)
    {
        if (ResourceUtil.isLog) Debug.Log("asset recCount " + or.assetName + " " + or.refCount + " " + addRefCount);
    }
    #endregion

    #region 外部接口
    public static bool IsObjectCreate(string assetName)
    {
        return _objectReferenceList.ContainsKey(assetName);
    }
    /// <summary>
    /// 创建Object的是否调用 引用计数为1
    /// </summary>
    /// <param name="assetName"></param>
    /// <param name="obj"></param>
    public static void AddObject(string assetName,Object obj)
    {
        if (obj == null)
            return;

        if (_objectReferenceList.ContainsKey(assetName))
        {
            GetObject(assetName);
        }
        else
        {
            ObjectReference or = GetTempObjectReference();
            or.obj = obj;
            or.assetName = assetName;
            _objectReferenceList.Add(assetName, or);
            GetObject(assetName);
        }
    }
    /// <summary>
    /// 获取一个Object 引用计数+1
    /// </summary>
    /// <param name="assetName"></param>
    /// <returns></returns>
    public static Object GetObject(string assetName)
    {
        ObjectReference or = null;
        if (_objectReferenceList.TryGetValue(assetName, out or))
        {
            or.refCount++;
            LogRefCount(or,1);
            return or.obj;
        }
        return null;
    }
    /// <summary>
    /// 释放Object 引用计数-1
    /// </summary>
    /// <param name="assetName"></param>
    public static void ReleaseObject(string assetName)
    {
        ObjectReference or = null;
        if (_objectReferenceList.TryGetValue(assetName, out or))
        {
            or.refCount--;
            LogRefCount(or, -1);
        }
    }
    /// <summary>
    /// 师范Object 引用计数-1
    /// </summary>
    /// <param name="obj"></param>
    public static void ReleaseObject(Object obj)
    {
        foreach(ObjectReference or in _objectReferenceList.Values)
        {
            if (or.obj == obj)
            {
                or.refCount--;
                break;
            }
        }
    }
   
    #endregion
}
