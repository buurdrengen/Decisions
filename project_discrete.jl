using Random, Distributions, DataStructures, Plots

##############################################################################################
#Environment describes all your important settings
# timeHorizonH: the amount of simulated time in hours
# warmUpTime: the warm-up period time (out of total time)
# base: number of hours per period, e.g. 24 if time is registered in hours, and a day lasts 24 hours  
# arrivalRate_patient: the arrival rate per hour of patients
# probDistrPatientType: 
# serviceTime_patient: a matrix [nr of patient types]  x 1 storing the service time (time room is occupied)
# nrRooms: number of available rooms for delivery
# costWaitingPerHour::Matrix{Float64}
struct Environment
    timeHorizonH::Float64
    warmUpTime::Int64   
    base::Int64 
    arrivalRate_patient::Float64   
    probDistrPatientType:: Matrix{Float64}
    serviceTime_patient::Float64 # Change this to a Matrix{Float64} ? 
    nrRooms::Int64
    costWaitingPerHour::Matrix{Float64}
end
##############################################################################################

# Events arriving
struct Event
    type::Symbol
    time::Float64
end 

# Patients arriving 
struct Patient
    type::Symbol # x,y,z for urgent, normal, low? 
    time::Float64
end

# States 
mutable struct State
    # State variables
    occupiedRooms::Int64
    totalRooms::Int64

    # Queues 
    urgentQ::Queue{Int32}
    normalQ::Queue{Int32}
    lowQ::Queue{Int32}

    # Simulation variables - USE OR REDEFINE? 
    t::Float64
    queue::PriorityQueue{Event,Float64}
    nextID::Int32
    # Output
    log_urgentQ::Array{Tuple{Int32,Float64}}
    log_normalQ::Array{Tuple{Int32,Float64}}
    log_lowQ::Array{Tuple{Int32,Float64}}
    log_arrival::Array{Float64} # ? 
    log_departureH::Array{Float64}

    # Constructor state missing
    # State() = new(...)
end

