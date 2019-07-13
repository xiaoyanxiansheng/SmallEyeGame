using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using Newtonsoft.Json;

/// <summary>
/// 资源与bundle的对应关系
/// </summary>
public class BundleAsset {

    public static string assetBundleInfoPath = Application.dataPath + "/AssetBundles/assetBundleInfoPath.json";

    public class AssetBundleInfo
    {
        public string assetName;
        public string assetInBundleName;
        public string bundleName;
    }

    private static Dictionary<string, AssetBundleInfo> _assetNameToBundleName = null;

    public static void LoadBundleAssets()
    {
        if (!File.Exists(assetBundleInfoPath))
        {
            return;
        }

        string content = File.ReadAllText(assetBundleInfoPath);
        _assetNameToBundleName = JsonConvert.DeserializeObject<Dictionary<string, AssetBundleInfo>>(content);
    }

	public static string GetBundleName(string assetName)
    {
        if (_assetNameToBundleName.ContainsKey(assetName))
            return _assetNameToBundleName[assetName].bundleName;
        return null;
    }

    public static string GetAssetInBundleName(string assetName)
    {
        if (_assetNameToBundleName.ContainsKey(assetName))
            return _assetNameToBundleName[assetName].assetInBundleName;
        return null;
    }
}
