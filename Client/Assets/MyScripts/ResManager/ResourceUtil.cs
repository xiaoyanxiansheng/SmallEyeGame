using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResourceUtil : MonoBehaviour{

    public static bool isLog = false;

    public static string bundleRootPath = Application.dataPath + "/AssetBundles/";

	public static int requestId = 0;

    /// <summary>
    /// 请求Id 每次自增
    /// </summary>
    /// <returns></returns>
    public static int GetRequestId()
    {
        return ++requestId;
    }

    /// <summary>
    /// 异步加载bundle
    /// </summary>
    /// <param name="bundleName">bundle名字</param>
    /// <param name="onCreateAssetBundle">加载成功后的回调</param>
    /// <returns>请求Id</returns>
    public static int CreateAssetBundleAsync(string bundleName, RequestLoadBundle.OnCreateAssetBundle onCreateAssetBundle)
    {
        return RequestLoadBundle.CreateAssetBundleAsync(0,bundleName, onCreateAssetBundle);
    }
    public static void CancelLoadBundleAsync(int requestId)
    {
        RequestLoadBundle.CancelLoadBundleAsync(requestId);
    }
    public static void DestoryAssetBundle(string bundleName)
    {
        ReferenceBundle.ReleaseBundle(bundleName);
    }
    public static int CreateAssetAsync(string assetName , RequestLoadAsset.OnLoadAsset onLoadAsset)
    {
        return RequestLoadAsset.LoadAssetAsync(assetName, onLoadAsset);
    }
    public static void CancelCreateAssetAsync(int requestId)
    {
        RequestLoadAsset.CancelLoadAssetAsync(requestId);
    }
    public static void DestoryAsset(string assetName)
    {
        ReferenceObject.ReleaseObject(assetName);
    }
    /// <summary>
    /// 创建一个实体
    /// </summary>
    /// <param name="type">实体类型 1:GameObject;2:UI</param>
    /// <param name="assetName">资源名称</param>
    /// <param name="onCreateGameObject">创建成功回调</param>
    /// <returns></returns>
    public static int CreateGameObjectAsync(int type,string assetName, GameObjectPool.OnCreateGameObject onCreateGameObject)
    {
        int requestId = CreateAssetAsync(assetName,(Object tAsset ,int tRequestId)=> {
            int instanceId = GameObjectPool.AddGameObject(type, assetName, tAsset);
            onCreateGameObject(instanceId, tRequestId);
        });
        return requestId;
    }
    public static void CancelCreateGameObjectAsync(int requestId)
    {
        CancelCreateAssetAsync(requestId);
    }
    public static void DestoryGameObject(int instanceId)
    {
        GameObjectPool.DestoryGameObject(instanceId);
    }

    public static GameObject GetGameObjectById(int instanceId)
    {
        return GameObjectPool.GetGameObject(instanceId);
    }

    #region 资源流程相关
    void Start()
    {
        // 初始化引用关系
        BundleDependencies.LoadBundleDependencies();
        // 初始化资源和bundle的对应关系
        BundleAsset.LoadBundleAssets();
    }

    void Update()
    {
        // 检测 加载bundle状态  等待加载-->加载(加载依赖bundle和自己)-->完成回调
        RequestLoadBundle.Update();
        // 检测 加载asset状态   等待加载-->加载依赖bundle-->加载自己-->完成回调
        RequestLoadAsset.Update();
        // 检测 asset引用       引用计数为零卸载asset
        ReferenceObject.Update();
        // 检测 bundle引用      同上
        ReferenceBundle.Update();
    }
    #endregion
}
