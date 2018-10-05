using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asset_BoidsManager : MonoBehaviour {

    public GameObject boid;
    public int numberOfBoids;

    [Range(0f, 1f)]
    public float _weightRandom;
    [Range(0f, 1f)]
    public float _weightSeparation;
    [Range(0f, 1f)]
    public float _weightAlightment;
    [Range(0f, 1f)]
    public float _weightCohesion;
    [Range(0f, 1f)]
    public float _weightPOI;

    #region Private Variables

    private List<Asset_Boid> boids = new List<Asset_Boid>();
    private Vector3 newPOI;
    private float newPOITime;
    private float newPOITimer;

    #endregion


    void Start () {

        _GetNewPOI();

		for (int i = 0; i < numberOfBoids; i++)
        {
            GameObject b = Instantiate(boid, newPOI + Random.insideUnitSphere * 5, Quaternion.identity, null);
            Asset_Boid bd = b.GetComponent<Asset_Boid>();

            bd.ManagerRegister(this);
            boids.Add(bd);
        }
        _SetTuningValues();

        newPOITime = Random.Range(0.0f, 15.0f);
        newPOITimer = Random.Range(0.0f, 15.0f);
	}

    public void Update()
    {
        // Sends new Point of Interest to managed flock on variable interval

        newPOITimer += Time.deltaTime;

        if(newPOITimer >= newPOITime)
        {
            newPOITimer = 0;
            newPOITime = Random.Range(8.0f, 15.0f);
            _GetNewPOI();
            _SetNewPOI();
        }
    }

    #region Public Functions

    public List<Asset_Boid> RequestMyNeighbors(Asset_Boid b)
    {
        // Using manager based neighbor calulation for better scheduling
        // Permits significanly greater number of simultaneously active boids with less chance of variable frame hits

        List<Asset_Boid> _neighborsToReturn = new List<Asset_Boid>();

        for (int i = 0; i < boids.Count; i++)
        {
            if (b != boids[i])
            {
                if (Vector3.Distance(b.transform.position, boids[i].transform.position) <= 20)
                {
                    _neighborsToReturn.Add(boids[i]);
                }

                if (_neighborsToReturn.Count > 20)
                    return (_neighborsToReturn);
            }
        }

        if (_neighborsToReturn.Count == 0)
            return null;
        else
            return _neighborsToReturn;
    }

    #endregion

    #region Internal Functions

    private void _SetTuningValues()
    {
        foreach (Asset_Boid b in boids)
        {
            b.UpdateWeights(_weightRandom, _weightSeparation, _weightAlightment, _weightCohesion, _weightPOI);
        }
    }

    private void _GetNewPOI()
    {
        newPOI = Random.insideUnitSphere * 10;
    }

    private void _SetNewPOI()
    {
        foreach (Asset_Boid b in boids)
        {
            b.SetNewPOI(newPOI);
        }
    }

    #endregion
}
