using UnityEngine;
using System.Collections;
using System;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Console.WriteLine("aaaaaaaaaaaa");
    }
	
	// Update is called once per frame
	void Update () {
        Console.WriteLine("aaaaaaaaaaaa " + Time.deltaTime);
        Console.ReadLine();
    }
}
