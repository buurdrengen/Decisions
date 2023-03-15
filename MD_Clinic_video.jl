using Random, Distributions, DataStructures

struct Environment
    workhours::Float64
    arrival_D::Normal
    visit_type_D::DiscreteUniform
    needs_doctor_D::Bernoulli
    doctor_visit_time_D::TriangularDist
    nurse_visit_time_D::TriangularDist

    Environment() = new(420.0, 
                        Normal(15,5),
                        DiscreteUniform(1,2),
                        Bernoulli(0.1),
                        TriangularDist(5,20,13),
                        TriangularDist(5,15,8))
end

struct Event
    type::Symbol
    time::Float64
end

mutable struct State
    #State variables
    nurseQ::Queue{Int32}
    doctorQ::Queue{Int32}

    #Simulation variables
    t::Float64
    events::PriorityQueue{Event,Float64}
    nextID::Int32
    # Output variables
    log_doctorQ::Array{Tuple{Int32,Float64}}
    log_arrival::Array{Float64}
    log_departure::Array{Float64}

    #Constructor
    State() = new(Queue{Int32}(),
                  Queue{Int32}(),
                  0,
                  PriorityQueue{Event,Float64}(),
                  1,
                  [(0,0)],
                  [],
                  [])
end

function schedule_arrival(env::Environment, state::State)
    tt = state.t + rand(env.arrival_D)
    if tt <= env.workhours
        if rand(env.visit_type_D)==1
            e = Event(:AN,tt)
            enqueue!(state.events,e,e.time)
            #println("Shedule :AN at $(e.time)")
        else
            e = Event(:AD,tt)
            enqueue!(state.events,e,e.time)
            #println("Shedule :AD at $(e.time)")
        end
    end
end

function process_arrival_nurse(env::Environment, state::State)
    #println(":AN at $(state.t)")
    patientID = state.nextID
    push!(state.log_arrival,state.t)
    push!(state.log_departure,-10000)
    state.nextID+=1
    if isempty(state.nurseQ)
        e = Event(:DN,state.t+rand(env.nurse_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
    enqueue!(state.nurseQ,patientID)
    schedule_arrival(env,state)
end

function process_arrival_doctor(env::Environment, state::State)
    #println(":AD at $(state.t)")
    patientID = state.nextID
    push!(state.log_arrival,state.t)
    push!(state.log_departure,-10000) 
    state.nextID+=1
    if isempty(state.doctorQ)
        e = Event(:DD,state.t+rand(env.doctor_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
    enqueue!(state.doctorQ,patientID)
    push!(state.log_doctorQ,(length(state.doctorQ),state.t))
    schedule_arrival(env,state)
end

function process_move_doctor(env::Environment, state::State, patientID::Int32)
    #println(":AD at $(state.t)")
    if isempty(state.doctorQ)
        e = Event(:DD,state.t+rand(env.doctor_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
    enqueue!(state.doctorQ,patientID)
    push!(state.log_doctorQ,(length(state.doctorQ),state.t))
    schedule_arrival(env,state)
end

function process_departure_nurse(env::Environment, state::State)
   # println(":DN at $(state.t)")
    patientID = dequeue!(state.nurseQ)
    state.log_departure[patientID]=state.t
    if rand(env.needs_doctor_D)==1
        #println("Move at $(state.t)")
        process_move_doctor(env,state,patientID)       
    end
    if !isempty(state.nurseQ)
        e = Event(:DN,state.t+rand(env.nurse_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
end

function process_departure_doctor(env::Environment, state::State)
    #println(":DD at $(state.t)")
    patientID = dequeue!(state.doctorQ)
    state.log_departure[patientID]=state.t
    push!(state.log_doctorQ,(length(state.doctorQ),state.t))
    if !isempty(state.doctorQ)
        e = Event(:DD,state.t+rand(env.doctor_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
end

function simulate(env::Environment)
    state = State()
    schedule_arrival(env,state)
    while !isempty(state.events)
        e = dequeue!(state.events)
        state.t = e.time
        if e.type==:AN
            process_arrival_nurse(env,state)
        elseif e.type==:AD
            process_arrival_doctor(env,state)
        elseif e.type==:DN
            process_departure_nurse(env,state)
        elseif e.type==:DD
            process_departure_doctor(env,state)
        else
            throw("Unregnised event!")
        end
    end
    Lq = 0
    for i in 2:length(state.log_doctorQ)
        Lq += state.log_doctorQ[i][1]*(state.log_doctorQ[i][2]-state.log_doctorQ[i-1][2])
    end
    Lq/=env.workhours
    #for i in 1:length(state.log_arrival)
    #    println(i," | ",state.log_arrival[i]," | ",state.log_departure[i]," | ",state.log_departure[i]-state.log_arrival[i])
    #end
    W = state.log_departure .- state.log_arrival
    return Lq , mean(W)
end

function main()
    Random.seed!(1234)
    env = Environment()
    n = 10000
    Lq = zeros(n)
    W = zeros(n)
    for i in 1:n
        Lq[i], W[i] = simulate(env)
    end
    println("Lq = $(mean(Lq))")
    println("W = $(mean(W))")
end

main()
