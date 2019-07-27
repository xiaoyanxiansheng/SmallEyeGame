using UnityEngine;
using System.Collections;

public class GameLogger {


    public static void LogError(string s)
    {
        Debug.LogError(s);
    }
    public static void LogInfo(string s)
    {
        Debug.Log(s);
    }
    public static void LogWarning(string s)
    {
        Debug.LogWarning(s);
    }

}
