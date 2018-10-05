using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;
public class Asset_Boid : MonoBehaviour {

    // This version of boids has been modified to respond to the main camera
    // Assumes that the main camera will be the player controlled camera
    // Requires unmodified FSM (v1.1) script

    public float speed;
    public float angTurnRate;
    public Transform childModel;

    public Vector3 POI;

    #region Private Variables

    private SCG_FSM<Asset_Boid> _fsm;
    
    public Vector3 _velocityCurrent { get; private set; }
    private Vector3 _velocityRandom;
    private Vector3 _steeringForce;

    private Asset_BoidsManager _manager;

    private float _weightRandom;
    private float _weightSeparation;
    private float _weightAlignment;
    private float _weightCohesion;
    private float _weightPOI;

    private Transform _camera;

    #endregion

    void Start () {
        _fsm = new SCG_FSM<Asset_Boid>(this);
        _fsm.TransitionTo<Wander>();

        _camera = Camera.main.transform;
	}
	
	void Update () {

        _fsm.Update();

        transform.position += _velocityCurrent * speed * Time.deltaTime;

        childModel.rotation = Quaternion.LookRotation(_velocityCurrent);
    }

    #region Public Functions

    public void ManagerRegister (Asset_BoidsManager bM)
    {
        _manager = bM;
    }

    public void UpdateWeights(float r, float s, float a, float c, float p)
    {
        _weightRandom = r;
        _weightSeparation = s;
        _weightAlignment = a;
        _weightCohesion = c;
        _weightPOI = p;
    }

    public void SetNewPOI(Vector3 poi)
    {
        POI = poi;
    }

    #endregion

    #region Context Functions

    private void NewRandomDir()
    {
        _velocityRandom = Random.insideUnitSphere;
    }

    #endregion

    #region FSM States

    protected class State_Base : SCG_FSM<Asset_Boid>.State
    {
        // Common variables and functions for future states

        protected float _timer;
        protected float _timerRollover;
        protected List<Asset_Boid> _neighbors;

        protected void TimerTick()
        {
            // Use to implement scheduled random behavioral contribution

            _timer += Time.deltaTime;
            if (_timer >= _timerRollover)
            {
                _timer -= _timerRollover;
                _timerRollover = Random.Range(1.1f, 5.0f);

                _neighbors = Context._manager.RequestMyNeighbors(Context);
                Context.NewRandomDir();
            }
        }

        protected Vector3 avoidVel;
        protected void AvoidNeighbors()
        {
            if (_neighbors != null)
            {
                Vector3 myPos = Context.transform.position;
                Vector3 storedPos = Vector3.zero;
                avoidVel = Vector3.zero;
                for (int i = 0; i < _neighbors.Count; i++)
                {
                    storedPos = _neighbors[i].transform.position;
                    avoidVel += (myPos - storedPos) / Vector3.Magnitude(myPos - storedPos);
                }
                avoidVel = Vector3.Normalize(avoidVel);
            }
            else
                avoidVel = Vector3.zero;
        }

        protected Vector3 toCenterVel;
        protected void SeekNeighbors()
        {
            if (_neighbors != null)
            {
                Vector3 myPos = Context.transform.position;
                Vector3 center = Vector3.zero;
                for (int i = 0; i < _neighbors.Count; i++)
                {
                    center += _neighbors[i].transform.position;
                }
                center = center / _neighbors.Count;

                toCenterVel = Vector3.Normalize(center - myPos);
            }
            else
                toCenterVel = Vector3.zero;
        }

        protected Vector3 alignVel;
        protected void AlignToNeighbors()
        {
            if (_neighbors != null)
            {
                Vector3 myPos = Context.transform.position;
                alignVel = Vector3.zero;
                for (int i = 0; i < _neighbors.Count; i++)
                {
                    alignVel += _neighbors[i]._velocityCurrent;
                }
                alignVel = Vector3.Normalize(alignVel / _neighbors.Count);
            }
            else
                toCenterVel = Vector3.zero;
        }

        protected Vector3 toPOIVel;
        protected void ToPOI()
        {
            if (_neighbors != null)
            {
                Vector3 myPos = Context.transform.position;
                Vector3 myPOI = Context.POI;

                toPOIVel = Vector3.Normalize((myPOI - myPos) * Vector3.Distance(myPOI, myPos) * Vector3.Distance(myPOI, myPos) * Vector3.Distance(myPOI, myPos));
            }
            else
                toCenterVel = Vector3.zero;
        }
    }

    protected class Wander : State_Base
    {
        // Uses a normalized vector based on competing dynamic constraints to determine desired direction
        // Avoid neighbors was formerly the most performance intensive

        public override void OnEnter()
        {
            base.OnEnter();
            Context.NewRandomDir();
            _timer = 0;
        }

        private Vector3 WeightAppliedResultant()
        {
            return Vector3.Normalize(avoidVel * Context._weightRandom + 
                toCenterVel * Context._weightCohesion + 
                alignVel * Context._weightAlignment + 
                Context._velocityRandom * Context._weightRandom + 
                toPOIVel * Context._weightPOI);
        }

        public override void Update()
        {
            base.Update();

            //Profiler.BeginSample("Avoid");
            AvoidNeighbors();
            //Profiler.EndSample();

            SeekNeighbors();
            AlignToNeighbors();
            ToPOI();

            Context._velocityCurrent = Quaternion.RotateTowards(Quaternion.LookRotation(Context._velocityCurrent), Quaternion.LookRotation(WeightAppliedResultant()), Context.angTurnRate * Time.deltaTime) * Vector3.forward;

            TimerTick();

            if (((Vector3.Distance(Context.transform.position, Context._camera.position) <= 15) && 
                Vector3.Angle(Context._camera.forward, Vector3.Normalize(Context.transform.position - Context._camera.position)) < 10f) ||
                Vector3.Distance(Context.transform.position, Context._camera.position) <= 5)
            {
                TransitionTo<Flee>();
            }
        }
    }

    protected class Flee : State_Base
    {
        // Similar to Wander in structure
        // Upon entering Flee, linear and rotational speed increase
        // The boost decrements linearly over time to original value
        // Direction of fleeing will be in the direction opposite of the camera at moment of entering flee
        // Will return to wandering after exitTimer exceeds random exitTime

        private float _exitTime;
        private float _exitTimer;

        private float _originalSpeed;
        private float _originalAngRotSpeed;

        public override void OnEnter()
        {
            base.OnEnter();
            Context.NewRandomDir();

            _timer = 0;
            _exitTime = Random.Range(4.5f, 4.9f);
            _exitTimer = 0;

            _originalSpeed = Context.speed;
            _originalAngRotSpeed = Context.angTurnRate;

            Context.speed *= 6f;
            Context.angTurnRate *= 4f;
        }

        private Vector3 WeightAppliedResultant()
        {
            return Vector3.Normalize(Context.transform.position - Context._camera.position);
        }

        public override void Update()
        {
            base.Update();

            _exitTimer += Time.deltaTime;
            if (_exitTimer > _exitTime)
                TransitionTo<Wander>();

            Context.speed = Mathf.Lerp(Context.speed, _originalSpeed, _exitTimer / _exitTime);
            Context.angTurnRate = Mathf.Lerp(Context.angTurnRate, _originalAngRotSpeed, _exitTimer / _exitTime);

            Context._velocityCurrent = Quaternion.RotateTowards(Quaternion.LookRotation(Context._velocityCurrent), Quaternion.LookRotation(WeightAppliedResultant()), Context.angTurnRate * Time.deltaTime) * Vector3.forward;

        }

        public override void OnExit()
        {
            base.OnExit();
            Context.speed = _originalSpeed;
            Context.angTurnRate = _originalAngRotSpeed;
        }
    }

    #endregion
}
