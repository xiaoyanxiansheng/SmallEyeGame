using UnityEngine;
using System.Collections;
using System.Diagnostics;
public class ZTest : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Stopwatch sw = new Stopwatch();
        sw.Start();
        for(int i = 0; i< 1000; i++)
        {
            UnityEngine.Debug.Log("aaaaaaaa" + i);
        }
        UnityEngine.Debug.LogError("bbbbbb " + sw.Elapsed.TotalSeconds);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
