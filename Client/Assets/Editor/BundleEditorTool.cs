using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
public class BundleEditorTool {

    public static void BuildCommandLine()
    {
        Debug.Log("===================================================");
        BuildAll();
        Debug.Log("===================================================");
    }

    /// <summary>
    /// 全部打包
    /// </summary>
    [MenuItem("Tools/BuildAll")]
    public static void BuildAll()
    {
        BuildDelete();
        BuildAllDiff();
    }
    /// <summary>
    /// 差异化打包
    /// </summary>
    [MenuItem("Tools/BuildAllDiff")]
    public static void BuildAllDiff()
    {
        BuildHelper();
        BuildPipeline.BuildAssetBundles("Assets/AssetBundles", BuildAssetBundleOptions.None | BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows64);
    }

    public static void BuildHelper()
    {
        BuildBefore();
        SetABLabelAll();
    }

    public static void BuildDelete()
    {
        string assetBundlePath = Application.dataPath + "/AssetBundles/";
        if (Directory.Exists(assetBundlePath))
            Directory.Delete(assetBundlePath, true);
        Directory.CreateDirectory(assetBundlePath);
    }

    /// <summary>
    /// 打包前处理
    /// </summary>
    public static void BuildBefore()
    {
        // TODO 按需生成不同质量
    }

    /// <summary>
    /// 设置标签
    /// </summary>
    public static void SetABLabelAll()
    {
        string[] assetPaths = Directory.GetFiles(Application.dataPath + "/BuildResource", "*.*", SearchOption.AllDirectories);
        List<string> assetPathList = new List<string>();
        foreach(string assetPath in assetPaths)
        {
            if (!IsValidAssetPath(assetPath)) continue;

            string tempPath = assetPath;
            tempPath = assetPath.Replace("\\", "/");
            tempPath = "Assets" + tempPath.Replace(Application.dataPath, string.Empty);
            assetPathList.Add(tempPath);
        }
        SetABNamePath(assetPathList.ToArray());
    }

    /// <summary>
    /// 设置标签
    /// </summary>
    /// <param name="assetPaths">Asset及下面的相对路径</param>
    public static void SetABNamePath(string[] assetPaths)
    {
        if (assetPaths == null) return;
        if (assetPaths.Length == 0) return;

        Dictionary<string, BundleAsset.AssetBundleInfo> assetBundleInfoDic = new Dictionary<string, BundleAsset.AssetBundleInfo>();

        foreach (string assetPath in assetPaths)
        {
            // 文件名 不包含路径
            string assetInBundleName = Path.GetFileNameWithoutExtension(assetPath);
            // 文件名 包含路径
            string assetDirectoryName = assetPath.Replace("Assets/BuildResource/", string.Empty);
            assetDirectoryName = string.Format("{0}/{1}", Path.GetDirectoryName(assetDirectoryName), assetInBundleName);
            assetDirectoryName = assetDirectoryName.ToLower();
           
            string abName = GetABName(assetDirectoryName);

            SetABLabel(assetPath, abName);

            BundleAsset.AssetBundleInfo assetBundleInfo = new BundleAsset.AssetBundleInfo();
            assetBundleInfo.assetName = assetDirectoryName;
            assetBundleInfo.assetInBundleName = assetInBundleName;
            assetBundleInfo.bundleName = abName;
            assetBundleInfoDic.Add(assetDirectoryName, assetBundleInfo);
        }

        File.WriteAllText(BundleAsset.assetBundleInfoPath, JsonConvert.SerializeObject(assetBundleInfoDic));
    }

    /// <summary>
    /// 获取AB的名称
    /// </summary>
    /// <param name="assetName"></param>
    /// <returns></returns>
    public static string GetABName(string assetName) 
    {
        // 1 放置一个merge文件标签 控制打包粒度
        string directPath = Path.GetDirectoryName(assetName);
        string mergePath = Application.dataPath + "/BuildResource/" + directPath + "/merge.txt";
        if (File.Exists(mergePath))
        {
            int index = directPath.LastIndexOf("/");
            if (index != -1)
            {
                string lastStr = directPath.Substring(index+1);
                assetName = directPath + "/" + lastStr;
            }
            else
            {
                // 根目录
                assetName = directPath + "/" + directPath;
            }
        }

        return assetName;
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="assetPath"></param>
    /// <param name="abName"></param>
    public static bool SetABLabel(string assetPath,string abName)
    {
        AssetImporter ait = AssetImporter.GetAtPath(assetPath);
        if (ait == null) return false;

        ait.assetBundleName = abName;
        ait.assetBundleVariant = "";

        return true;
    }
    public static bool IsValidAssetPath(string assetPath)
    {
        return !assetPath.EndsWith(".meta");
    }
}
