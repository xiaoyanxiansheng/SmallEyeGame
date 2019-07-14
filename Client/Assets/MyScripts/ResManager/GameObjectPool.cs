using UnityEngine;
using System.Collections.Generic;

public class GameObjectPool {

    public delegate void OnCreateGameObject(int instanceId,int requestId);

    public class GameObjectRef
    {
        public void Clear()
        {
            instanceId = 0;
            assetName = null;
            obj = null;
        }
        public int instanceId;
        public string assetName;
        public GameObject obj;
    }

    private static Dictionary<int, GameObjectRef> _gameObjectRef = new Dictionary<int, GameObjectRef>();
    private static List<GameObjectRef> _freeGameObjectRef = new List<GameObjectRef>();

    private static GameObjectRef GetTempGameObjectRef()
    {
        GameObjectRef gameObjectRef = null;
        if (_freeGameObjectRef.Count > 0)
        {
            gameObjectRef = _freeGameObjectRef[0];
            _freeGameObjectRef.RemoveAt(0);
        }
        else
        {
            gameObjectRef = new GameObjectRef();
        }
        return gameObjectRef;
    }
    private static void RecoveryGameObjectRef(GameObjectRef gameObjectRef)
    {
        if (gameObjectRef == null) return;
        if (gameObjectRef.obj != null)
        {
            GameObject.Destroy(gameObjectRef.obj);
            ReferenceObject.ReleaseObject(gameObjectRef.assetName);
        }
        Debug.Log("gameObejct Destory " + gameObjectRef.assetName);
        if (_gameObjectRef.ContainsKey(gameObjectRef.instanceId))
            _gameObjectRef.Remove(gameObjectRef.instanceId);
        gameObjectRef.Clear();
        _freeGameObjectRef.Add(gameObjectRef);
    }

    public static int AddGameObject(int type,string assetName,Object asset)
    {
        if (asset == null) return 0;
        if (!(asset is GameObject))
        {
            Debug.LogError(assetName + " is not a GameObject");
            return 0;
        }

        Debug.Log("gameObject create " + assetName);

        GameObject obj = (GameObject)GameObject.Instantiate(asset,Vector3.zero,Quaternion.identity);
        obj = InitGameObject(type, obj, assetName);
        obj.SetActive(false);
        int instanceId = obj.GetInstanceID();

        GameObjectRef gameObjectRef = GetTempGameObjectRef();
        gameObjectRef.assetName = assetName;
        gameObjectRef.instanceId = instanceId;
        gameObjectRef.obj = obj;
        _gameObjectRef.Add(instanceId, gameObjectRef);

        return instanceId;
    }

    public static GameObject InitGameObject(int type, GameObject obj, string assetName)
    {
        Transform parent = null;
        Transform son = null;
        // GameObject
        if (type == 1)
        {
            son = obj.transform;
        }
        // UI
        else if(type == 2)
        {
            GameObject root = GameObject.Find("ui/prefab/uipanel_base");
            parent = root.transform;
            son = obj.transform.FindChild("Core");
            GameObject.Destroy(obj);
        }

        if (son != null)
        {
            son.name = assetName;
            if (parent != null)
            {
                son.parent = parent;
            }
            CommonUtil.TrimGameObejct(son.gameObject);
        }

        return son.gameObject;
    }

    public static void DestoryGameObject(int instanceId)
    {
        if (!_gameObjectRef.ContainsKey(instanceId)) return;

        RecoveryGameObjectRef(_gameObjectRef[instanceId]);
    }
    public static GameObject GetGameObject(int instanceId)
    {
        if (!_gameObjectRef.ContainsKey(instanceId)) return null;

        return _gameObjectRef[instanceId].obj;
    }
}
