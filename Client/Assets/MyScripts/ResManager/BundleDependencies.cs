using System.Collections.Generic;
using UnityEngine;

public class BundleDependencies {

    private static Dictionary<string, List<string>> _dependencies = new Dictionary<string, List<string>>();
    private static Dictionary<string, List<string>> _parents = new Dictionary<string, List<string>>();

    public static void AddDependencies(string bundleName,string[] dependencies)
    {
        if (!_dependencies.ContainsKey(bundleName))
            _dependencies[bundleName] = new List<string>();
        foreach(string dependBundleName in dependencies)
        {
            _dependencies[bundleName].Add(dependBundleName);

            if (!_parents.ContainsKey(dependBundleName))
                _parents[dependBundleName] = new List<string>();
            _parents[dependBundleName].Add(bundleName);
        }
    }

    public static void LoadBundleDependencies()
    {
        string manifestFilePath = ResourceUtil.bundleRootPath + "AssetBundles";
        AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFilePath);
        AssetBundleManifest assetBundleManifest = assetBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        string[] allBundles = assetBundleManifest.GetAllAssetBundles();
        foreach(string bundleName in allBundles)
        {
            string[] dependencies = assetBundleManifest.GetDirectDependencies(bundleName);
            AddDependencies(bundleName,dependencies);
        }
    }

    public static Dictionary<string, List<string>> GetAllBundleDependencies()
    {
        return _dependencies;
    }

    public static List<string> GetAssetBundleDependencies(string bundleName)
    {
        if (_dependencies.ContainsKey(bundleName))
            return _dependencies[bundleName];
        return null;
    }

    public static List<string> GetAssetBundleParents(string bundleName)
    {
        if (_parents.ContainsKey(bundleName))
            return _parents[bundleName];
        return null;
    }
}
