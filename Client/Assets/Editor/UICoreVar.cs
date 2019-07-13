using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(UICore))]
public class UICoreVar : Editor {

    public UICore _script;
    public GameObject _gameObject;

    public void OnEnable()
    {
        UICore tempScript = (UICore)(serializedObject.targetObject);
        if (tempScript != null)
        {
            _script = tempScript;
            _gameObject = tempScript.gameObject;
        }
        else
        {
            Debug.LogError("serializedObject null");
        }
    }

    public void OnDisable()
    {
        _script = null;
        _gameObject = null;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Save"))
        {
            _script.BindAllWidgets();
        }
    }
}
