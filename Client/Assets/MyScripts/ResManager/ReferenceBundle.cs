using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ReferenceBundle {

    #region menber
    class BundleReference
    {
        public void Clear()
        {
            bundleName = null;
            assetBundle = null;
            refCount = 0;
        }
        public string bundleName;
        public AssetBundle assetBundle;
        public int refCount;
    }

    private static Dictionary<string, BundleReference> _bundleReferenceList = new Dictionary<string, BundleReference>();
    private static List<BundleReference> _freeBundleReferenceList = new List<BundleReference>();
    #endregion

    private static BundleReference GetTempBundleReference()
    {
        BundleReference br = null;

        if (_freeBundleReferenceList.Count > 0)
        {
            br = _freeBundleReferenceList[0];
        }
        else
        {
            br = new BundleReference();
        }

        return br;
    }

    private static void RecoveryObjectReference(string bundleName)
    {
        BundleReference br = null;
        if (!_bundleReferenceList.TryGetValue(bundleName, out br))
            return;

        // bundle引用为0
        if (br.assetBundle)
        {
            if (ResourceUtil.isLog) Debug.Log("assetBundle Unload(true) " + bundleName);
            br.assetBundle.Unload(true);
        }

        _bundleReferenceList.Remove(bundleName);
        br.Clear();
        _freeBundleReferenceList.Add(br);
    }

    #region 检测
    public static void Update()
    {
        if (_bundleReferenceList.Count == 0)
            return;

        List<string> tempBrs = new List<string>();
        foreach (string bundleName in _bundleReferenceList.Keys)
        {
            BundleReference br = _bundleReferenceList[bundleName];
            if (br.refCount <= 0)
            {
                tempBrs.Add(bundleName);
            }
        }
        foreach (string bundleName in tempBrs)
        {
            RecoveryObjectReference(bundleName);
        }
    }
    #endregion

    public static bool IsAssetBundleCraete(string bundleName)
    {
        BundleReference br = GetBundleReference(bundleName);
        if (br != null)
        {
            return br.assetBundle != null;
        }
        return false;
    }

    public static void ReleaseBundle(string bundleName)
    {
        BundleReference br = null;
        if (_bundleReferenceList.TryGetValue(bundleName, out br))
        {
            // 释放依赖
            List<string> dependencies = BundleDependencies.GetAssetBundleDependencies(bundleName);
            if (dependencies != null)
            {
                foreach(string dependBundleName in dependencies)
                {
                    ReleaseBundle(dependBundleName);
                }
            }

            br.refCount--;
            LogRefCount(br,-1);
        }
    }

    public static void AddBundle(string bundleName, AssetBundle assetBundle)
    {
        if (assetBundle == null) return;

        if (_bundleReferenceList.ContainsKey(bundleName))
        {
            GetAssetBundle(bundleName);
        }
        else
        {
            BundleReference br = GetTempBundleReference();
            br.bundleName = bundleName;
            br.assetBundle = assetBundle;
            _bundleReferenceList.Add(bundleName, br);
            GetAssetBundle(bundleName);
        }
    }

    /// <summary>
    /// 获取一个bundle 每次获取引用计数都会加1
    /// </summary>
    /// <param name="bundleName"></param>
    /// <returns></returns>
    public static AssetBundle GetAssetBundle(string bundleName)
    {
        BundleReference br = GetBundleReference(bundleName); ;
        if (br != null)
        {
            br.refCount++;
            LogRefCount(br,1);

            // 增加依赖
            List<string> denpendencies = BundleDependencies.GetAssetBundleDependencies(bundleName);
            if (denpendencies != null)
            {
                foreach(string denpendBundleName in denpendencies)
                {
                    GetAssetBundle(denpendBundleName);
                }
            }

            return br.assetBundle;
        }
        return null;
    }

    public static AssetBundle GetAssetBundleDirect(string bundleName)
    {
        BundleReference br = GetBundleReference(bundleName); ;
        if (br != null)
            return br.assetBundle;
        return null;
    }

    private static BundleReference GetBundleReference(string bundleName)
    {
        BundleReference br = null;
        if (_bundleReferenceList.TryGetValue(bundleName, out br))
        {
            return br;
        }
        return null;
    }

    private static void LogRefCount(BundleReference br , int addRefCount = 1)
    {
        if (ResourceUtil.isLog) Debug.Log("assetBundle recCount " + br.bundleName + " " + br.refCount + " " + addRefCount);
    }
}
