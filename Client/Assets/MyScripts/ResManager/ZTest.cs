using UnityEngine;
using System.Collections.Generic;

public class ZTest : MonoBehaviour {

    /// <summary>
    /// 打印帮助
    /// </summary>
    public enum CreateType
    {
        Bundle,
        Asset,
        GameObejct
    }

    /// <summary>
    /// 打印帮助
    /// </summary>
    public enum CreateState
    {
        None,
        Destory,
        Cancel,
    }
    public int index = 0;
    public CreateType createType = CreateType.Bundle;
    public CreateState createState = CreateState.None;
    public string pname = "tex";

	// Use this for initialization
	void Start () {
        // 初始化引用关系
        BundleDependencies.LoadBundleDependencies();
        // 初始化资源和bundle的对应关系
        BundleAsset.LoadBundleAssets();

        // 测试加载
        if (createType == CreateType.Bundle)            CreateBundle();
        else if(createType == CreateType.Asset)         CreateAsset();
        else if(createType == CreateType.GameObejct)    CreateGameObject();
    }
	
    void CreateBundle()
    {
        int requestId = ResourceUtil.CreateAssetBundleAsync(pname, (string tBundleName, AssetBundle tAssetBundle, int tRequestId) =>
        {
            Debug.Log("==========================load bundle success " + tBundleName);
            // 卸载
            if (createState == CreateState.Destory)
                ResourceUtil.DestoryAssetBundle(tBundleName);
        });
        // 取消加载
        if (createState == CreateState.Cancel)
            ResourceUtil.CancelLoadBundleAsync(requestId);
    }

    void CreateAsset()
    {
        int requestId = ResourceUtil.CreateAssetAsync(pname, (Object asset, int tRequestId) =>
        {
            Debug.Log("==========================load asset success " + asset);
            // 卸载
            if (createState == CreateState.Destory)
                ResourceUtil.DestoryAsset(pname);
        });
        // 取消加载
        if (createState == CreateState.Cancel)
            ResourceUtil.CancelCreateAssetAsync(requestId);
    }

    void CreateGameObject()
    {
        int requestId = ResourceUtil.CreateGameObjectAsync(1,pname, (int tInstanceId,int tRequestId)=> {
            Debug.Log("==========================load gameObject success " + pname);
            GameObject obj = GameObjectPool.GetGameObject(tInstanceId);
            obj.transform.parent = transform;
            // 卸载
            if (createState == CreateState.Destory)
                ResourceUtil.DestoryGameObject(tInstanceId);
        });
        // 取消加载
        if (createState == CreateState.Cancel)
            ResourceUtil.CancelCreateGameObjectAsync(requestId);
    }

	// Update is called once per frame
	void Update () {
        // 检测 加载bundle状态  等待加载-->加载(加载依赖bundle和自己)-->完成回调
        RequestLoadBundle.Update();
        // 检测 加载asset状态   等待加载-->加载依赖bundle-->加载自己-->完成回调
        RequestLoadAsset.Update();
        // 检测 asset引用       引用计数为零卸载asset
        ReferenceObject.Update();
        // 检测 bundle引用      同上
        ReferenceBundle.Update();
    }
}
