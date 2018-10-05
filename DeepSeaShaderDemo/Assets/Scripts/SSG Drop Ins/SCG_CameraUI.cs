using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SCG_CameraUI : MonoBehaviour {

    private Camera _observedCamera;
    private Text _uiTextField;

    private float _avgDeltaTime;
    private string _avgFPS;

	void Start () {
        _Initialize();
	}
	
	void Update () {
        _UIUpdate();
	}

    private void _Initialize()
    {
        _observedCamera = transform.root.GetComponent<Camera>();
        _uiTextField = transform.GetChild(0).GetComponent<Text>();

        _avgDeltaTime = Time.deltaTime;
    }

    private void _UIUpdate()
    {
        _avgDeltaTime = Mathf.Lerp(_avgDeltaTime, Time.deltaTime, .01f);

        _avgFPS = string.Format("{0:000.00}", 1 / _avgDeltaTime);

        _uiTextField.text = "Camera Frustum Angle: " + _observedCamera.fieldOfView + "\nAverage FPS: " + _avgFPS;
    }
}
