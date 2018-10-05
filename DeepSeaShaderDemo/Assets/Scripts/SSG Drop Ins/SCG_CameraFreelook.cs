using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SCG_CameraFreelook : MonoBehaviour {

    // Drop in smooth freelook camera

    public float lookPitchAngleRate;
    public float lookYawAngleRate;
    public float moveFwdAftSpeed;
    public float moveStrafeSpeed;
    public Vector2 xMinMax;
    public Vector2 yMinMax;
    public Vector2 zMinMax;

    #region Internal Variables

    private Camera _cam;
    private float _fov;
    private float _yEulerRot;
    private float _xEulerRot;
    private Vector3 _camEurlerLookRot;
    private Vector3 _cameraPositionPredamped;
    private Vector3 _cameraPositionDamped;
    private float _positionDelta;
    private float _dampingMultiplier = 3.25f;

    #endregion

    void Start() {
        _Initialize();
    }

    void Update() {
        _CameraFreelook();

        _FOV();

        _StrafeMove();
        _ClampPos();
        _DampedMovement();
    }

    #region Internal Functions

    private void _Initialize()
    {
        _cam = GetComponent<Camera>();
        _fov = _cam.fieldOfView;

        _camEurlerLookRot = Vector3.zero;

        _cameraPositionDamped = _cameraPositionPredamped = transform.position;

        Cursor.visible = false;
    }

    private void _FOV()
    {
        // Camera FOV adjustment
        // Keyboard and mouse input

        if (Input.GetKey(KeyCode.Q))
            _fov *= .99f;
        if (Input.GetKey(KeyCode.E))
            _fov /= .99f;

        if (Input.GetAxis("Mouse ScrollWheel") > 0)
            _fov /= .95f;
        if (Input.GetAxis("Mouse ScrollWheel") < 0)
            _fov *= .95f;

        _fov = Mathf.Clamp(_fov, 15.0f, 90.0f);

        _cam.fieldOfView = _fov;
    }

    private void _CameraFreelook()
    {
        // Clamped freelook constrained to -+ 60 vertically
        // Y-angle rolls over at 360

        if (Input.GetAxis("Mouse X") != 0)
            _camEurlerLookRot.y += Input.GetAxis("Mouse X") * lookPitchAngleRate * Time.unscaledDeltaTime;

        if (Input.GetAxis("Mouse Y") != 0)
            _camEurlerLookRot.x -= Input.GetAxis("Mouse Y") * lookYawAngleRate * Time.unscaledDeltaTime;

        _camEurlerLookRot.y = (_camEurlerLookRot.y + 360.0f) % 360.0f;

        _camEurlerLookRot.x = Mathf.Clamp(_camEurlerLookRot.x, -60.0f, 60.0f);

        transform.rotation = Quaternion.Euler(_camEurlerLookRot);
    }

    private void _StrafeMove()
    {
        // Framerate independent movement
        // WASD - strafe movement scheme

        // Fwd/Aft Movement
        if (Input.GetKey(KeyCode.W))
            _cameraPositionPredamped += transform.forward * moveFwdAftSpeed * Time.unscaledDeltaTime;
        if (Input.GetKey(KeyCode.S))
            _cameraPositionPredamped -= transform.forward * moveFwdAftSpeed * Time.unscaledDeltaTime;

        // Strafe Movement
        if (Input.GetKey(KeyCode.D))
            _cameraPositionPredamped += transform.right * moveStrafeSpeed * Time.unscaledDeltaTime;
        if (Input.GetKey(KeyCode.A))
            _cameraPositionPredamped -= transform.right * moveStrafeSpeed * Time.unscaledDeltaTime;

    }

    private void _ClampPos()
    {
        // Optional clamp
        // Having any non-zero clamp value will impose clamping

        if (Vector2.Distance(xMinMax, Vector2.zero) > 0 || Vector2.Distance(yMinMax, Vector2.zero) > 0 || Vector2.Distance(zMinMax, Vector2.zero) > 0)
        {
            _cameraPositionPredamped.x = Mathf.Clamp(_cameraPositionPredamped.x, xMinMax.x, xMinMax.y);
            _cameraPositionPredamped.y = Mathf.Clamp(_cameraPositionPredamped.y, yMinMax.x, yMinMax.y);
            _cameraPositionPredamped.z = Mathf.Clamp(_cameraPositionPredamped.z, zMinMax.x, zMinMax.y);
        }
    }

    private void _DampedMovement()
    {
        // Framerate independent positional smoothing
        // Proportional control input
        // Non-jittering smooth movement

        _positionDelta = Vector3.Distance(_cameraPositionPredamped, _cameraPositionDamped);

        _cameraPositionDamped = Vector3.MoveTowards(_cameraPositionDamped, 
            _cameraPositionPredamped, 
            _positionDelta * Time.unscaledDeltaTime * _dampingMultiplier);

        transform.position = _cameraPositionDamped;
    }

    #endregion
}
