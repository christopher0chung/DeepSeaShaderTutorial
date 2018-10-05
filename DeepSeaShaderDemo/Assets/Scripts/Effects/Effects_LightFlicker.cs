using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Effects_LightFlicker : MonoBehaviour {

    private Light _myLight;

	void Start () {
        _myLight = GetComponent<Light>();
	}
	

	void Update () {
        _myLight.range = Random.Range(5f, 5.5f);
	}
}
