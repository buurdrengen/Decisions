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
    nurseQ::Int32
    doctorQ::Int32
    State() = new(0,0)
end

function nurse_patient_arrival(env::Environment, state::State, events::PriorityQueue{Event,Float64}, t::Float64)
    e = Event(visit_type(env),t+rand(env.arrival_D))
    if t<=env.workhours # do not generate more patients after work hours
        println("A patient for the nurse arrived at time $t")
        enqueue!(events,e,e.time)
        if state.nurseQ==0
            e2 = Event(:DepartureNurse,t+rand(env.nurse_visit_time_D))
            enqueue!(events,e2,e2.time)
        end
        state.nurseQ+=1
    end
end

function doctor_patient_arrival(env::Environment, state::State, events::PriorityQueue{Event,Float64}, t::Float64)
    e = Event(visit_type(env),t+rand(env.arrival_D))
    if t<=env.workhours # do not generate more patients after work hours
        println("A patient for the doctor arrived at time $t")
        enqueue!(events,e,e.time)
        if state.doctorQ==0
            e2 = Event(:DepartureDoctor,t+rand(env.doctor_visit_time_D))
            enqueue!(events,e2,e2.time)
        end
        state.doctorQ+=1
     end
end


function visit_type(env::Environment)
    if rand(env.visit_type_D)==1
        return :ArrivalNurse
    end
    return :ArrivalDoctor 
end

function departure_nurse(env::Environment, state::State, events::PriorityQueue{Event,Float64}, t::Float64)
    println("The nurse is done with a patient at time $t")
    state.nurseQ -= 1
    if state.nurseQ!=0
        e = Event(:DepartureNurse, t+rand(env.nurse_visit_time_D))
        enqueue!(events,e,e.time)
    end
    if rand(env.needs_doctor_D)==1
        state.doctorQ += 1
        println("A patient was moved to the doctor queue at time $t")
    end
end

function departure_doctor(env::Environment, state::State, events::PriorityQueue{Event,Float64}, t::Float64)
    println("The doctor it done with a patient at time $t")
    state.doctorQ -= 1
    if state.doctorQ!=0
        e = Event(:DepartureDoctor, t+rand(env.doctor_visit_time_D))
        enqueue!(events,e,e.time)
    end
end


function simulate(env::Environment)
    t = 0
    state = State()
    events = PriorityQueue{Event,Float64}()
    local e::Event
    if rand(env.visit_type_D)==1
        e = Event(:ArrivalNurse,t+rand(env.arrival_D))
    else
        e = Event(:ArrivalNurse,t+rand(env.arrival_D))
    end
    enqueue!(events,e,e.time)

    while !isempty(events)
        e = dequeue!(events)
        t = e.time
        if e.type==:ArrivalNurse
            
            nurse_patient_arrival(env,state,events,t)
        elseif e.type==:ArrivalDoctor
            
            doctor_patient_arrival(env,state,events,t)
        elseif e.type==:DepartureNurse
            
            departure_nurse(env,state,events,t)
        elseif e.type==:DepartureDoctor
            
            departure_doctor(env,state,events,t)
        end
    end
end

function main()
    env = Environment()
    simulate(env)
end

main()