module Hospital
using Random, Distributions, DataStructures, Plots
#You can use print-lines for debugging. When your code is done, you would like to be able to switch them off easily. 
#Therefore, one can include a boolean "_debug" that is switched on when debugging, and off otherwise.
_debug = false

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

#Events arriving
struct Event
    type::Symbol
    time::Float64
end

#Patient priority and arrival time
struct Patient
    type::Symbol
    time::Float64
end

#Describes the state of your process, similar to states in Markov. You can include as many variables as you like/need
mutable struct State #for multiple hospitals, change below to matrices
    ocupiedRooms::Int64
    totalRooms::Int64 
    queue::Vector{PriorityQueue{Event,Float64}}  #Queue per priority level, priority level going down 
    #State() = new(0,nrRooms,...)
end


mutable struct SimStats
    #TODO
end

function simulate(env::Environment, totalFeeltsize::Int64, morningShareSt1::Float64, afternoonShareSt1::Float64)
    
    #2. State
    localQueue = Vector{PriorityQueue{Patient,Float64}}(PriorityQueue{Event,Float64},3) 
    for i= 1:nrPatientTypes
    localQueue[i]= PriorityQueue{Patient,Float64}()
    end
    state = State(0,totalRooms, localQueue)
    
    #3. stats
    #TODO  
    
    #4. event list and initial event
    events = PriorityQueue{Event,Float64}()
    #TODO


    #################################################################
    # Simulation main loop
     #TODO
end


function main()
    #TODO: set seed
    ###################################################
    #Settings
    t = 0.0
    totalRooms = 8
    weeksSimTime = 6
    weeksWarmUp = 2
    base = 24
    arrivalRate = 1/0.42
    serviceRate = 12.5
    probPerPatientType = [0.1 0.6 0.3]
    costsPerPatientType =  [10000 1000 100]
    nrPatientTypes = length(probPerPatientType)
    ###################################################

    ###################################################
    #Initialize variables
    #1. Environment
    Environment() = new(
    weeksSimTime*24*7, #6 weeks '
    weeksWarmUp*24*7,
    base,
    arrivalRate,
    probPerPatientType,
    serviceRate,
    totalRooms, 
    costsPerPatientType
    )

   #TODO call simulation function

end

main()
end
