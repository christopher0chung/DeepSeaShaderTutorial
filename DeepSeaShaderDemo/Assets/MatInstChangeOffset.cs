using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatInstChangeOffset : MonoBehaviour
{

    MeshRenderer mr;
    // Start is called before the first frame update
    void Start()
    {
        mr = GetComponent<MeshRenderer>();
        mr.material.SetFloat("_TimeOffset", Random.Range(0.00f, 100.00f));
    }

}
