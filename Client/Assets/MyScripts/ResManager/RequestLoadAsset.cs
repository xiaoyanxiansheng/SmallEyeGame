using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 资源请求
/// </summary>
public class RequestLoadAsset{

    #region 辅助class
    public delegate void OnLoadAsset(Object obj, int requestId);

    enum LoadAssetStep
    {
        None,
        LoadWait,       // 等待加载         控制一帧加载上限数量
        LoadDepend,     // 依赖加载中       等待加载依赖bundle
        Loading,        // 加载资源中       
        WaitCall,       // 等待回调         已加载成功 等待回调
    }

    /// <summary>
    /// 请求加载asset信息
    /// </summary>
    class LoadAssetInfo
    {
        public void Clear()
        {
            if (asset != null)
            {
                ReferenceObject.ReleaseObject(assetName);
                asset = null;
            }
            if (assetBundle != null)
            {
                ReferenceBundle.ReleaseBundle(bundleName);
                assetBundle = null;
            }
            step = LoadAssetStep.None;
            bundleName = null;
            requestId = 0;
            request = null;
            assetName = null;
            onLoadAsset = null;
        }
        public LoadAssetStep step = LoadAssetStep.None;
        // 依赖加载 作为索引去寻找PendingLoadAssetInfo
        public string bundleName;
        public AssetBundle assetBundle;
        // 已请求
        public int requestId;
        public AssetBundleRequest request;
        // 已加载
        public Object asset;

        public string assetName;
        public OnLoadAsset onLoadAsset;
    }

    /// <summary>
    /// 依赖加载信息 bundle未加载之前需要先加载bundle然后加载asset
    /// </summary>
    class PendingLoadAssetInfo
    {
        public void Clear()
        {
            reqeustId = 0;
            bundleName = null;
        }
        public int reqeustId;
        public string bundleName;
    }

    #endregion

    #region menber
    // 每帧加载的数量上限
    private static int _frameLoadMaxCount = 8;

    // 资源加载列表
    private static List<LoadAssetInfo> _loadAssetInfoList = new List<LoadAssetInfo>();
    // 依赖加载列表
    private static Dictionary<string, PendingLoadAssetInfo> _pendingLoadAssetInfoList = new Dictionary<string, PendingLoadAssetInfo>();

    // 缓存对象
    private static List<LoadAssetInfo> _freeLoadAssetInfoList = new List<LoadAssetInfo>();
    private static List<PendingLoadAssetInfo> _freePendingLoadAssetInfoList = new List<PendingLoadAssetInfo>();
    #endregion

    #region 辅助方法
    /// <summary>
    /// 异步加载资源
    /// </summary>
    /// <param name="assetName">资源名</param>
    private static void LoadAssetAsync(LoadAssetInfo loadAssetInfo)
    {
        AssetBundle assetBundle = ReferenceBundle.GetAssetBundle(loadAssetInfo.bundleName);
        string assetInBundleName = BundleAsset.GetAssetInBundleName(loadAssetInfo.assetName);
        AssetBundleRequest request = assetBundle.LoadAssetAsync(assetInBundleName);
        loadAssetInfo.request = request;
        EnterLoading(loadAssetInfo);
    }
    /// <summary>
    /// bundle成功加载后的回调
    /// </summary>
    /// <param name="bundleName"></param>
    /// <param name="assetBundle"></param>
    /// <param name="abRequestId"></param>
    private static void OnLoadPeningBundle(string bundleName, AssetBundle assetBundle, int abRequestId)
    {
        PendingLoadAssetInfo peningInfo = _pendingLoadAssetInfoList[bundleName];
        if (peningInfo == null) return;

        foreach (LoadAssetInfo loadAssetInfo in _loadAssetInfoList)
        {
            if (loadAssetInfo.bundleName == bundleName)
            {
                // 进入加载资源状态
                loadAssetInfo.assetBundle = assetBundle;
                LoadAssetAsync(loadAssetInfo);
            }
        }
        // 回收依赖信息
        RecoveryPendingLoadAssetInfo(peningInfo);
    }

    /// <summary>
    ///依赖bundle加载状态
    /// </summary>
    /// <param name="loadAssetInfo"></param>
    private static void PushPending(LoadAssetInfo loadAssetInfo)
    {
        EnterLoadDepend(loadAssetInfo);
        string bundleName = loadAssetInfo.bundleName;
        if (!_pendingLoadAssetInfoList.ContainsKey(bundleName))
        {
            // 加载bundle
            int abRequestId = ResourceUtil.CreateAssetBundleAsync(bundleName, OnLoadPeningBundle);
            PendingLoadAssetInfo pendingInfo = new PendingLoadAssetInfo();
            pendingInfo = GetTempPendingLoadAssetInfo();
            pendingInfo.reqeustId = abRequestId;
            pendingInfo.bundleName = bundleName;
            _pendingLoadAssetInfoList.Add(bundleName, pendingInfo);
        }
    }

    /// <summary>
    /// 获取一个临时asset加载信息
    /// </summary>
    /// <returns></returns>
    private static LoadAssetInfo GetTempLoadAssetInfo()
    {
        LoadAssetInfo assetInfo = null;

        if (_freeLoadAssetInfoList.Count > 0)
        {
            assetInfo = _freeLoadAssetInfoList[0];
            _freeLoadAssetInfoList.RemoveAt(0);
        }
        else
        {
            assetInfo = new LoadAssetInfo();
        }

        return assetInfo;
    }
    /// <summary>
    /// 回收资源加载信息
    /// </summary>
    /// <param name="assetInfo">asset加载信息</param>
    private static void RecoveryLoadAssetInfo(LoadAssetInfo info)
    {
        if (info == null) return;


        foreach(LoadAssetInfo loadAssetInfo in _loadAssetInfoList)
        {
            if (loadAssetInfo == info)
            {
                _loadAssetInfoList.Remove(loadAssetInfo);
                break;
            }
        }

        info.Clear();
        _freeLoadAssetInfoList.Add(info);
    }
    /// <summary>
    /// 获取依赖加载信息
    /// </summary>
    /// <returns></returns>
    private static PendingLoadAssetInfo GetTempPendingLoadAssetInfo()
    {
        PendingLoadAssetInfo assetInfo = null;

        if (_freePendingLoadAssetInfoList.Count > 0)
        {
            assetInfo = _freePendingLoadAssetInfoList[0];
            _freePendingLoadAssetInfoList.RemoveAt(0);
        }
        else
        {
            assetInfo = new PendingLoadAssetInfo();
        }

        return assetInfo;
    }
    /// <summary>
    /// 回收依赖加载信息
    /// </summary>
    /// <param name="info"></param>
    private static void RecoveryPendingLoadAssetInfo(PendingLoadAssetInfo info)
    {
        if (info == null) return;

        if (_pendingLoadAssetInfoList.ContainsKey(info.bundleName))
            _pendingLoadAssetInfoList.Remove(info.bundleName);

        info.Clear();
        _freePendingLoadAssetInfoList.Add(info);
    }
    
    private static LoadAssetInfo GetLoadAssetInfo(int requestId)
    {
        foreach (LoadAssetInfo loadAssetInfo in _loadAssetInfoList)
        {
            if (loadAssetInfo.requestId == requestId)
            {
                return loadAssetInfo;
            }
        }

        return null;
    }

    /// <summary>
    /// 进入等待加载
    /// </summary>
    /// <param name="loadAssetInfo"></param>
    private static void EnterLoadWait(LoadAssetInfo loadAssetInfo)
    {
        loadAssetInfo.step = LoadAssetStep.LoadWait;
        if (ResourceUtil.isLog) Debug.Log("loadAsset step 1 EnterLoadWait : " + loadAssetInfo.assetName);
    }
    /// <summary>
    /// 进入依赖加载
    /// </summary>
    /// <param name="loadAssetInfo"></param>
    private static void EnterLoadDepend(LoadAssetInfo loadAssetInfo)
    {
        loadAssetInfo.step = LoadAssetStep.LoadDepend;
        if (ResourceUtil.isLog) Debug.Log("loadAsset step 2 EnterLoadDepend : " + loadAssetInfo.assetName);
    }
    /// <summary>
    /// 进入加载
    /// </summary>
    /// <param name="loadAssetInfo"></param>
    private static void EnterLoading(LoadAssetInfo loadAssetInfo)
    {
        loadAssetInfo.step = LoadAssetStep.Loading;
        if (ResourceUtil.isLog) Debug.Log("loadAsset step 3 EnterLoading : " + loadAssetInfo.assetName);
    }
    /// <summary>
    /// 进入加载回调
    /// </summary>
    /// <param name="loadAssetInfo"></param>
    private static void EnterWaitCall(LoadAssetInfo loadAssetInfo)
    {
        loadAssetInfo.step = LoadAssetStep.WaitCall;
        if (ResourceUtil.isLog) Debug.Log("loadAsset step 4 EnterWaitCall : " + loadAssetInfo.assetName);
    }
    #endregion

    #region 检测
    /// <summary>
    /// 每帧调用
    /// </summary>
    public static void Update()
    {
        if (_loadAssetInfoList.Count == 0)
            return;

        // 检测依赖bundle是否加载
        CheckLoadDepend();
        // 检测资源是否加载
        CheckLoad();
        // 检测加载回调
        CheckWaitCall();
    }
    /// <summary>
    /// 检测依赖bundle是否加载
    /// </summary>
    private static void CheckWaitCall()
    {
        List<LoadAssetInfo> loadedAssetInfoList = GetLoadAssetStateList(LoadAssetStep.WaitCall, true);

        foreach (LoadAssetInfo loadAssetInfo in loadedAssetInfoList)
        {
            Object asset = ReferenceObject.GetObject(loadAssetInfo.assetName);
            loadAssetInfo.onLoadAsset(asset, loadAssetInfo.requestId);
            RecoveryLoadAssetInfo(loadAssetInfo);
        }
    }
    /// <summary>
    /// 检测资源是否加载
    /// </summary>
    private static void CheckLoadDepend()
    {
        // bundle的加载依赖回调 所以这里不需要检测状态
    }
    /// <summary>
    /// 检测加载回调
    /// </summary>
    private static void CheckLoad()
    {
        List<LoadAssetInfo> loadAssetInfoList = GetLoadAssetStateList(LoadAssetStep.Loading);

        if (loadAssetInfoList.Count == 0) return;

        foreach (LoadAssetInfo loadAssetInfo in loadAssetInfoList)
        {
            AssetBundleRequest request = loadAssetInfo.request;
            if (request == null) continue;
            if (!request.isDone) continue;

            Object asset = request.asset;
            if (asset == null) continue;

            // 资源加载成功 进入等待回调状态
            string assetInBundleName = BundleAsset.GetAssetInBundleName(loadAssetInfo.assetName);
            if (asset.name == assetInBundleName)
            {
                ReferenceObject.AddObject(loadAssetInfo.assetName, asset);
                loadAssetInfo.asset = asset;
                EnterWaitCall(loadAssetInfo);
                // 加载成功一个资源之后 从等待列表中释放一个 维持每帧加载上线
                List<LoadAssetInfo> loadWaitAssetList = GetLoadAssetStateList(LoadAssetStep.LoadWait);
                if (loadWaitAssetList.Count > 0)
                {
                    LoadAssetAsync(loadWaitAssetList[0]);
                }
                break;
            }
        }
    }

    /// <summary>
    /// 获取某一步的列表
    /// </summary>
    /// <param name="step"></param>
    /// <returns></returns>
    private static List<LoadAssetInfo> GetLoadAssetStateList(LoadAssetStep step ,bool isDelete = false)
    {
        List<LoadAssetInfo> list = new List<LoadAssetInfo>();

        for(int i = _loadAssetInfoList.Count - 1; i >= 0; i--)
        {
            LoadAssetInfo loadAssetInfo = _loadAssetInfoList[i];
            if (step == loadAssetInfo.step)
            {
                list.Add(loadAssetInfo);
                if (isDelete)
                    _loadAssetInfoList.RemoveAt(i);
            }
        }

        return list;
    }
    #endregion

    #region 开放接口
    /// <summary>
    /// 异步加载资源
    /// </summary>
    /// <param name="assetName">需要加载的资源路径</param>
    /// <param name="onLoadAsset">加载成功之后的回调</param>
    /// <returns>请求Id</returns>
    public static int LoadAssetAsync(string assetName, OnLoadAsset onLoadAsset)
    {
        // 回调不存在不允加载
        if (onLoadAsset == null)
            return 0;

        // 资源对应bundle名
        string abName = BundleAsset.GetBundleName(assetName);
        // 获取请求ID
        int requestId = ResourceUtil.GetRequestId();

        LoadAssetInfo loadAssetInfo = GetTempLoadAssetInfo();
        loadAssetInfo.requestId = requestId;
        loadAssetInfo.assetName = assetName;
        loadAssetInfo.onLoadAsset = onLoadAsset;
        loadAssetInfo.bundleName = abName;
        EnterLoadWait(loadAssetInfo);

        // 1 asset是否已加载
        if (ReferenceObject.IsObjectCreate(loadAssetInfo.assetName))
        {
            EnterWaitCall(loadAssetInfo);
        }

        // 2 bundle是否已加载
        else if (!ReferenceBundle.IsAssetBundleCraete(abName))
            PushPending(loadAssetInfo);

        // 3 从bundle加载资源
        else
        {
            List<LoadAssetInfo> loadingAssetList = GetLoadAssetStateList(LoadAssetStep.Loading);
            if (loadingAssetList.Count < _frameLoadMaxCount)
                LoadAssetAsync(loadAssetInfo);
        }

        _loadAssetInfoList.Add(loadAssetInfo);

        return requestId;
    }

    /// <summary>
    /// 取消加载 
    /// 如果正在加载中 加载成功之后会卸载，同时回调也不会触发
    /// </summary>
    /// <param name="requestId"></param>
    /// <returns></returns>
    public static void CancelLoadAssetAsync(int requestId)
    {
        LoadAssetInfo loadAssetInfo = GetLoadAssetInfo(requestId);
        if (loadAssetInfo == null) return;

        // 等待加载状态中 直接回收(如果不回收将会先加载在卸载)
        if (loadAssetInfo.step == LoadAssetStep.LoadWait)
        {
            RecoveryLoadAssetInfo(loadAssetInfo);
        }
        else
        {
            PendingLoadAssetInfo pendingLoadAssetInfo = _pendingLoadAssetInfoList[loadAssetInfo.bundleName];
            // 资源还未加载 因为在加载依赖的bundle
            if (pendingLoadAssetInfo != null)
            {
                // 取消依赖加载bundle
                RequestLoadBundle.CancelLoadBundleAsync(pendingLoadAssetInfo.reqeustId);
                RecoveryPendingLoadAssetInfo(pendingLoadAssetInfo);
                // 这时资源还未加载 直接回收
                RecoveryLoadAssetInfo(loadAssetInfo);
            }
        }
    }
    #endregion
}