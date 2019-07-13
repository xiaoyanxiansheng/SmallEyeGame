using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// bundle加载
/// </summary>
public class RequestLoadBundle{

    #region 辅助class
    public delegate void OnCreateAssetBundle(string bundleName, AssetBundle assetBundle, int requestId);

    enum LoadBundleStep
    {
        None,
        LoadWait,       // 等待加载    控制一帧加载上限数量
        Loading,        // 加载中      自已加载中 和 依赖
        WaitCall,       // 完成回调    依赖加载完成 等待回调
    }

    /// <summary>
    /// 加载请求信息
    /// </summary>
    class LoadBundleRequestInfo
    {
        public void Clear()
        {
            requestId = 0;
            onCreateAssetBundle = null;
        }

        public int requestId;
        public OnCreateAssetBundle onCreateAssetBundle;
    }

    /// <summary>
    /// 加载信息
    /// </summary>
    class LoadBundleInfo
    {

        public void Clear()
        {
            if (assetBundle != null)
            {
                //Debug.Log("Destory LoadBundleInfo " + bundleName);
                ReferenceBundle.ReleaseBundle(bundleName);
                assetBundle = null;
            }
            RemoveAllBundleRequest();
            bundleName = null;
            request = null;
            step = LoadBundleStep.None;
        }

        // 加载状态
        public LoadBundleStep step;
        public string bundleName;
        public AssetBundleCreateRequest request;
        public AssetBundle assetBundle;
        // 加载请求信息 一个bundle可能被多次请求
        public List<LoadBundleRequestInfo> loadBundleRequestInfoList = new List<LoadBundleRequestInfo>();

        /// <summary>
        /// 创建请求信息
        /// </summary>
        /// <param name="onCreateAssetBundle">请求回调 多次请求对应多个回调</param>
        /// <returns></returns>
        public int CreateBundleRequest(int requestId, OnCreateAssetBundle onCreateAssetBundle)
        {
            if (requestId == 0)
                requestId = ResourceUtil.GetRequestId();

            LoadBundleRequestInfo loadBundleRequestInfo = GetTempLoadBundleRequestInfo();
            loadBundleRequestInfo.requestId = requestId;
            loadBundleRequestInfo.onCreateAssetBundle = onCreateAssetBundle;
            loadBundleRequestInfoList.Add(loadBundleRequestInfo);

            return requestId;
        }

        /// <summary>
        /// 删除一个请求信息
        /// </summary>
        public bool RemoveBundleRequest(int requestId)
        {
            for(int i =0;i< loadBundleRequestInfoList.Count; i++)
            {
                LoadBundleRequestInfo loadBundleRequestInfo = loadBundleRequestInfoList[i];
                if (loadBundleRequestInfo.requestId == requestId)
                {
                    loadBundleRequestInfoList.RemoveAt(i);
                    loadBundleRequestInfo.Clear();
                    _freeLoadBundleRequestInfoList.Add(loadBundleRequestInfo);
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 删除所有请求信息
        /// </summary>
        /// <param name="requestId"></param>
        public void RemoveAllBundleRequest()
        {
            for (int i = 0; i < loadBundleRequestInfoList.Count; i++)
            {
                LoadBundleRequestInfo loadBundleRequestInfo = loadBundleRequestInfoList[i];
                loadBundleRequestInfo.Clear();
                _freeLoadBundleRequestInfoList.Add(loadBundleRequestInfo);
            }
            loadBundleRequestInfoList.Clear();
        }

        /// <summary>
        /// 检测是否某个请求是否存在
        /// </summary>
        /// <param name="requestId">请求Id</param>
        /// <returns></returns>
        public bool CheckRequestId(int requestId)
        {
            foreach(LoadBundleRequestInfo loadBundleRequestInfo in loadBundleRequestInfoList)
            {
                if (loadBundleRequestInfo.requestId == requestId)
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 请求的回调 表明已经加载成功
        /// </summary>
        public void CallCreateAssetBundle()
        {
            //Debug.Log("LoadBundleInfo CallCreateAssetBundle " + bundleName);
            foreach (LoadBundleRequestInfo loadBundleRequestInfo in loadBundleRequestInfoList)
            {
                AssetBundle assetBundle = ReferenceBundle.GetAssetBundle(bundleName);
                loadBundleRequestInfo.onCreateAssetBundle(bundleName,assetBundle, loadBundleRequestInfo.requestId);
            }
            RemoveAllBundleRequest();
        }

        public LoadBundleRequestInfo GetTempLoadBundleRequestInfo()
        {
            LoadBundleRequestInfo loadBundleRequestInfo = null;
            if (_freeLoadBundleRequestInfoList.Count > 0)
            {
                loadBundleRequestInfo = _freeLoadBundleRequestInfoList[0];
                _freeLoadBundleRequestInfoList.RemoveAt(0);
            }
            else
            {
                loadBundleRequestInfo = new LoadBundleRequestInfo();
            }
            return loadBundleRequestInfo;
        }

    }
    #endregion

    #region menber
    // 每帧加载的数量上限
    private static int _frameLoadMaxCount = 8;

    // 请求列表 存放bundle对应的请求信息
    private static Dictionary<string, LoadBundleInfo> _loadBundleInfoList = new Dictionary<string, LoadBundleInfo>();

    // 缓存列表
    private static List<LoadBundleInfo> _freeLoadBundleInfoList = new List<LoadBundleInfo>();
    private static List<LoadBundleRequestInfo> _freeLoadBundleRequestInfoList = new List<LoadBundleRequestInfo>();
    #endregion

    #region 辅助方法
    private static LoadBundleInfo GetTempLoadBundleInfo()
    {
        LoadBundleInfo loadBundleInfo;

        if (_freeLoadBundleInfoList.Count > 0)
        {
            loadBundleInfo = _freeLoadBundleInfoList[0];
            _freeLoadBundleInfoList.RemoveAt(0);
        }
        else
        {
            loadBundleInfo = new LoadBundleInfo();
        }

        return loadBundleInfo;
    }
    private static void RecoveryLoadBundleInfo(LoadBundleInfo loadBundleInfo)
    {
        loadBundleInfo.Clear();
        _freeLoadBundleInfoList.Add(loadBundleInfo);
    }

    /// <summary>
    /// 获取一个加载信息
    /// </summary>
    /// <param name="requestId"></param>
    /// <returns></returns>
    private static LoadBundleInfo GetLoadBundleInfo(int requestId)
    {
        foreach(LoadBundleInfo tempLoadBundleInfo in _loadBundleInfoList.Values)
        {
            if (tempLoadBundleInfo.CheckRequestId(requestId))
                return tempLoadBundleInfo;
        }
        return null;
    }
    private static LoadBundleInfo GetLoadBundleInfo(string bundleName)
    {
        LoadBundleInfo loadBundleInfo;
        if (_loadBundleInfoList.TryGetValue(bundleName, out loadBundleInfo))
            return loadBundleInfo;
        return null;
    }

    /// <summary>
    /// 获取某状态的列表
    /// </summary>
    /// <param name="step">状态</param>
    /// <returns></returns>
    private static List<LoadBundleInfo> GetLoadBundleStateList(LoadBundleStep step, bool isDelete = false)
    {
        List<string> indexList = new List<string>();
        foreach(string bundleName in _loadBundleInfoList.Keys)
        {
            LoadBundleInfo loadBundleInfo = _loadBundleInfoList[bundleName];
            if (loadBundleInfo.step == step)
                indexList.Add(bundleName);
        }

        List<LoadBundleInfo> list = new List<LoadBundleInfo>();
        foreach (string bundleName in indexList)
        {
            list.Add(_loadBundleInfoList[bundleName]);
            if (isDelete)
                _loadBundleInfoList.Remove(bundleName);
        }

        return list;
    }

    /// <summary>
    /// 加载bundle
    /// </summary>
    /// <param name="loadBundleInfo"></param>
    private static void LoadAssetBundle(LoadBundleInfo loadBundleInfo)
    {
        EnterLoading(loadBundleInfo);
        AssetBundleCreateRequest abRequest = AssetBundle.LoadFromFileAsync(ResourceUtil.bundleRootPath + loadBundleInfo.bundleName);
        loadBundleInfo.request = abRequest;
    }

    /// <summary>
    /// 检测自己及依赖是否全部加载完成
    /// </summary>
    /// <param name="bundleName"></param>
    /// <returns></returns>
    private static bool RecursiveCheckLoad(string bundleName)
    {
        if (!ReferenceBundle.IsAssetBundleCraete(bundleName))
            return false;

        List<string> list = BundleDependencies.GetAssetBundleDependencies(bundleName);
        if (list != null)
        {
            foreach (string tBundleName in list)
            {
                if (!ReferenceBundle.IsAssetBundleCraete(tBundleName))
                {
                    return false;
                }
                else
                {
                    // 当前已加载 再次向下查找
                    RecursiveCheckLoad(tBundleName);
                }
            }
        }
        
        return true;
    }

    /// <summary>
    /// 进入加载等待状态
    /// </summary>
    /// <param name="loadBundleInfo"></param>
    private static void EnterLoadWait(LoadBundleInfo loadBundleInfo)
    {
        loadBundleInfo.step = LoadBundleStep.LoadWait;
        Debug.Log("[load assetbundle] step 1 EnterLoadWait : " + loadBundleInfo.bundleName);
    }
    /// <summary>
    /// 进入加载状态 包括依赖加载
    /// </summary>
    /// <param name="loadBundleInfo"></param>
    private static void EnterLoading(LoadBundleInfo loadBundleInfo)
    {
        loadBundleInfo.step = LoadBundleStep.Loading;
        Debug.Log("[load assetbundle] step 2 EnterLoading : " + loadBundleInfo.bundleName);
    }
    /// <summary>
    /// 加载成功后回调状态
    /// </summary>
    /// <param name="loadBundleInfo"></param>
    private static void EnterWaitCall(LoadBundleInfo loadBundleInfo)
    {
        loadBundleInfo.step = LoadBundleStep.WaitCall;
        Debug.Log("[load assetbundle] step 3 EnterWaitCall : " + loadBundleInfo.bundleName);
    }
    #endregion

    #region 检测
    /// <summary>
    /// 每帧检测
    /// </summary>
    public static void Update()
    {
        // 检测是否已加载
        CheckLoad();
        // 检测加载回调
        CheckWaitCall();
    }

    /// <summary>
    /// 加载成功会回调
    /// </summary>
    private static void CheckWaitCall()
    {
        List<LoadBundleInfo> waitCallLoadBundleInfoList = GetLoadBundleStateList(LoadBundleStep.WaitCall, true);
        // 反向操作 依赖先回调
        for (int i = waitCallLoadBundleInfoList.Count - 1; i >= 0; i--)
        {
            LoadBundleInfo loadBundleInfo = waitCallLoadBundleInfoList[i];
            loadBundleInfo.CallCreateAssetBundle();
            RecoveryLoadBundleInfo(loadBundleInfo);
        }
    }

    /// <summary>
    /// 检测加载是否完成
    /// </summary>
    private static void CheckLoad()
    {
        List<LoadBundleInfo> loadingLoadBundleInfoList = GetLoadBundleStateList(LoadBundleStep.Loading);
        // 反向检测 依赖先检测
        for(int i = loadingLoadBundleInfoList.Count - 1; i >= 0; i--)
        {
            LoadBundleInfo loadBundleInfo = loadingLoadBundleInfoList[i];
            if (!loadBundleInfo.request.isDone) continue;

            if (loadBundleInfo.assetBundle == null)
            {
                AssetBundle assetBundle = loadBundleInfo.request.assetBundle;
                loadBundleInfo.assetBundle = assetBundle;
                ReferenceBundle.AddBundle(loadBundleInfo.bundleName, assetBundle);
            }

            // 递归检测依赖是否加载完成
            if (RecursiveCheckLoad(loadBundleInfo.bundleName))
            {
                EnterWaitCall(loadBundleInfo);
                // 加载成功一个bundle之后 从等待列表中释放一个 维持每帧加载上线
                List<LoadBundleInfo> loadWaitBundleInfoList = GetLoadBundleStateList(LoadBundleStep.LoadWait);
                if (loadWaitBundleInfoList.Count > 0)
                {
                    LoadAssetBundle(loadWaitBundleInfoList[0]);
                }
            }
        }
    }
    #endregion

    #region 开放接口
    /// <summary>
    /// 异步加载bundle
    /// </summary>
    /// <param name="bundleName">bundle路径</param>
    /// <param name="onCreateAssetBundle">加载成功后的回调 取消加载后将回调将失效</param>
    /// <returns></returns>
    public static int CreateAssetBundleAsync(int requestId, string bundleName, OnCreateAssetBundle onCreateAssetBundle)
    {
        // 回调不存在不允加载
        if (onCreateAssetBundle == null)
            return 0;

        LoadBundleInfo loadBundleInfo = GetLoadBundleInfo(bundleName);
        if (loadBundleInfo == null)
        {
            loadBundleInfo = GetTempLoadBundleInfo();
            _loadBundleInfoList.Add(bundleName, loadBundleInfo);
            loadBundleInfo.bundleName = bundleName;
            EnterLoadWait(loadBundleInfo);
        }

        requestId = loadBundleInfo.CreateBundleRequest(requestId,onCreateAssetBundle);
        // 未请求
        if (loadBundleInfo.step == LoadBundleStep.LoadWait)
        {
            // 1 获取依赖列表
            List<string> dependencies = BundleDependencies.GetAssetBundleDependencies(bundleName);
            // 2 递归请求加载
            if (dependencies != null && dependencies.Count > 0)
            {
                foreach (string tempBundleName in dependencies)
                {
                    CreateAssetBundleAsync(requestId,tempBundleName, (string tBundleName, AssetBundle tAssetBundle, int tRequestId) => {
                        // 回调返回会增加引用 所以这里直接释放
                        ReferenceBundle.ReleaseBundle(tBundleName);
                    });
                }
            }
            // 3 正加载列表
            List<LoadBundleInfo> loadingBundleInfoList = GetLoadBundleStateList(LoadBundleStep.Loading);
            if (loadingBundleInfoList.Count < _frameLoadMaxCount)
            {
                LoadAssetBundle(loadBundleInfo);
            }
        }

        return requestId;
    }

    /// <summary>
    /// 取消加载
    /// </summary>
    /// <param name="requestId">请求Id</param>
    /// <returns></returns>
    public static void CancelLoadBundleAsync(int requestId)
    {
        // 1 删除请求信息
        foreach (LoadBundleInfo loadBundleInfo in _loadBundleInfoList.Values)
        {
            loadBundleInfo.RemoveBundleRequest(requestId);
        }

        // 2 等待加载状态 但是已经没有请求了 就不要在走下面的流程 直接删除
        List<LoadBundleInfo> deleteList = new List<LoadBundleInfo>();
        foreach (LoadBundleInfo loadBundleInfo in _loadBundleInfoList.Values)
        {
            if (loadBundleInfo.loadBundleRequestInfoList.Count == 0 && loadBundleInfo.step == LoadBundleStep.LoadWait)
            {
                deleteList.Add(loadBundleInfo);
            }
        }
        foreach(LoadBundleInfo loadBundleInfo in deleteList)
        {
            RecoveryLoadBundleInfo(loadBundleInfo);
        }
    }
    #endregion
}
