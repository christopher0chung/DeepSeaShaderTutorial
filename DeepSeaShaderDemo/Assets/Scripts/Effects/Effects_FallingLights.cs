using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Effects_FallingLights : MonoBehaviour {

    [Range(0f, 20f)]
    public float speed;
    private Vector3 position;

    void Start()
    {
        Vector2 nextLoc = Random.insideUnitCircle * 30f;
        position.x = nextLoc.x;
        position.z = nextLoc.y;
        position.y = Random.Range(-39f, 39f);
    }

    void Update () {
        position -= Vector3.up * speed * Time.deltaTime;

        transform.position = position;

        if (position.y <= -40f)
        {
            Vector2 nextLoc = Random.insideUnitCircle * 30f;
            position.x = nextLoc.x;
            position.z = nextLoc.y;
            position.y = 40;
        }
	}
}
