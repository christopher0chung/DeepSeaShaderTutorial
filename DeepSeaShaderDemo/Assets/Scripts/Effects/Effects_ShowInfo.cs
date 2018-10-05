using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Effects_ShowInfo : MonoBehaviour {

    public List<GameObject> activeWhenTrue;
    public List<GameObject> activeWhenFalse;

    private bool _i;
    private bool _InfoVisible
    {
        get
        {
            return _i;
        }
        set
        {
            if (value != _i)
            {
                _i = value;
                if (_i)
                {
                    foreach (GameObject g in activeWhenTrue)
                        g.SetActive(true);
                    foreach (GameObject g in activeWhenFalse)
                        g.SetActive(false);
                }
                else
                {
                    foreach (GameObject g in activeWhenTrue)
                        g.SetActive(false);
                    foreach (GameObject g in activeWhenFalse)
                        g.SetActive(true);
                }

            }
        }
    }

    void Start()
    {
        _InfoVisible = true;
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.Space))
            _InfoVisible = true;
        else _InfoVisible = false;
    }
}
