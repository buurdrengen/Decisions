using Random, Distributions, DataStructures

struct Environment
    workhours::Float64
    arrival_D::Exponential
    visit_type_D::DiscreteUniform
    needs_doctor_D::Bernoulli
    doctor_visit_time_D::TriangularDist
    nurse_visit_time_D::TriangularDist

    Environment() = new(420.0, 
                        Exponential(10),
                        DiscreteUniform(1,2),
                        Bernoulli(0.1),
                        TriangularDist(5,20,15),
                        TriangularDist(5,15,8))
end

struct Event
    type::Symbol
    time::Float64
end

mutable struct State
    # State variables
    nurseQ::Int32
    doctorQ::Int32

    # Simulation variables
    t::Float64
    events::PriorityQueue{Event,Float64}

    # Output variables
    log_doctorQ::Array{Tuple{Int32,Float64}}

    # Constructor 
    State() = new(0,0,0,PriorityQueue{Event,Float64}(),[(0,0)])
end


function nurse_patient_arrival(env::Environment, state::State)
    #println(":AN at $(state.t)")
    if state.nurseQ==0
        e = Event(:DN,state.t+rand(env.nurse_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
    state.nurseQ+=1
    schedule_arrival(env,state)
end

function doctor_patient_arrival(env::Environment, state::State)
    #println(":AD at $(state.t)")
    if state.doctorQ==0
        e = Event(:DD,state.t+rand(env.doctor_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
    state.doctorQ+=1
    push!(state.log_doctorQ,(state.doctorQ,state.t))
    schedule_arrival(env,state)
end


function visit_type(env::Environment)
    # if rand(env.visit_type_D)==1
    #     return :ArrivalNurse
    # end
    # return :ArrivalDoctor 
end

function departure_nurse(env::Environment, state::State)
    #println(":DN at $(state.t)")
    state.nurseQ -= 1
    if rand(env.needs_doctor_D)==1
        #println("Move at $(state.t)")
        doctor_patient_arrival(env,state)
    end
    if state.nurseQ>0
        e = Event(:DN, state.t+rand(env.nurse_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
end

function departure_doctor(env::Environment, state::State)
    #println(":DD at $(state.t)")
    state.doctorQ -= 1
    push!(state.log_doctorQ,(state.doctorQ,state.t))
    if state.doctorQ>0
        e = Event(:DD, state.t+rand(env.doctor_visit_time_D))
        enqueue!(state.events,e,e.time)
    end
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


function simulate(env::Environment)
    state = State()
    schedule_arrival(env,state)
    while !isempty(state.events)
        e = dequeue!(state.events)
        state.t = e.time
        if e.type==:AN
            nurse_patient_arrival(env,state)
        elseif e.type==:AD
            doctor_patient_arrival(env,state)
        elseif e.type==:DN
            departure_nurse(env,state)
        elseif e.type==:DD
            departure_doctor(env,state)
        else 
            throw("Unrecognised event")
        end
    end
    
    # for log in state.log_doctorQ
    #     println("$(log[1]) | $(log[2])")
    # end 
    Lq = 0 
    for i in 2:length(state.log_doctorQ)
       Lq += state.log_doctorQ[i][1]*(state.log_doctorQ[i][2] - state.log_doctorQ[i-1][2])
    end 
    Lq /= env.workhours
    return Lq
end 

function main()
    Random.seed!(1234)
    env = Environment()
    n = 10000
    Lq = zeros(n)
    for i in 1:n
        Lq[i] = simulate(env)
    end
    # Lq = simulate(env)
    println("Lq = $(mean(Lq))")
    # println("Lq = $(mean(Lq))")
end

main()