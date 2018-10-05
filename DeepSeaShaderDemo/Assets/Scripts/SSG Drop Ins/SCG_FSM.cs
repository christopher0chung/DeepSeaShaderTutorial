using System;
using System.Collections.Generic;
using System.Diagnostics;

// v1.1

// A generic class that is parameterized on the context type
// Machine doesn't have to cast the context when accessing
public class SCG_FSM<TContext>
{

    private readonly TContext _context;

    // Cache the machine's states in a dictionary easily reaccess
    private readonly Dictionary<Type, State> _stateCache = new Dictionary<Type, State>();

    public State CurrentState { get; private set; }

    // Buffered state for when a transition is called
    private State _pendingState;

    // Initialize the context it's readonly
    public SCG_FSM(TContext context)
    {
        _context = context;
    }

    public void Update()
    {
        // Handle any pending transition if someone called TransitionTo externally
        PerformPendingTransition();
        // Make sure there's always a current state to update...
        Debug.Assert(CurrentState != null, "Updating FSM with null current state.");
        CurrentState.Update();
        // Handle any pending transition that might have happened during the update
        PerformPendingTransition();
    }

    // Queues transition to a new state
    public void TransitionTo<TState>() where TState : State
    {
        // Currently non-recursive
        _pendingState = GetOrCreateState<TState>();
    }

    // Handles transition to new pending state
    private void PerformPendingTransition()
    {
        if (_pendingState != null)
        {
            if (CurrentState != null) CurrentState.OnExit();
            CurrentState = _pendingState;
            CurrentState.OnEnter();
            _pendingState = null;
        }
    }

    // Helper method 
    // Manages caching of the state instances
    private TState GetOrCreateState<TState>() where TState : State
    {
        State state;
        if (_stateCache.TryGetValue(typeof (TState), out state))
        {
            return (TState) state;
        }
        else
        {
            var newState = Activator.CreateInstance<TState>();
            newState.Parent = this;
            newState.Init();
            _stateCache[typeof(TState)] = newState;
            return newState;
        }
    }

    // Base class for states inside the FSM class 
    // Tied to the context type of the FSM class to avoid transition to a state in another context
    public abstract class State
    {

        internal SCG_FSM<TContext> Parent { get; set; }

        protected TContext Context { get { return Parent._context; } }

        protected void TransitionTo<TState>() where TState : State
        {
            Parent.TransitionTo<TState>();
        }


        // Called once when the state is first created
        public virtual void Init() { }

        // Called whenever the state becomes active
        public virtual void OnEnter() { }

        // Standard update method 
        public virtual void Update() { }

        // Called whenever the state becomes inactive
        public virtual void OnExit() { }

        // Called when the state machine is cleared
        // For clearing resources
        public virtual void CleanUp() { }
    }

}