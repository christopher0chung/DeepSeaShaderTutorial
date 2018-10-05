using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SCG_QualityOfLife : MonoBehaviour {

    private bool _p;
    private bool _pause
    {
        get { return _p; }
        set
        {
            if (value != _p)
            {
                _p = value;
                if (_p)
                    Time.timeScale = 0;
                else
                    Time.timeScale = 1;
            }
        }
    }

	void Update () {
        if(Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }

        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            _pause = !_pause;
        }
	}
}
