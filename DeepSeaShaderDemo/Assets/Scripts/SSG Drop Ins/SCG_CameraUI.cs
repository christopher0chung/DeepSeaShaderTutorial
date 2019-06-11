using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SCG_CameraUI : MonoBehaviour {

    public Camera observedCamera;
    public Text uiTextField;

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
        _avgDeltaTime = Time.deltaTime;
    }

    private void _UIUpdate()
    {
        _avgDeltaTime = Mathf.Lerp(_avgDeltaTime, Time.unscaledDeltaTime, .05f);

        _avgFPS = string.Format("{0:000.00}", 1 / _avgDeltaTime);

        uiTextField.text = "Camera Frustum Angle: " + observedCamera.fieldOfView + "\nAverage FPS: " + _avgFPS;
    }
}
