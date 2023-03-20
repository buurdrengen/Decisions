module Hospital
using Random, Distributions, DataStructures, Plots
#You can use print-lines for debugging. When your code is done, you would like to be able to switch them off easily. 
#Therefore, one can include a boolean "_debug" that is switched on when debugging, and off otherwise.
_debug = true

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
    probDistrPatientType:: Array{Float64}
    serviceTime_patient::Float64
    nrRooms::Int64
    costWaitingPerHour::Matrix{Float64}

end


#DO NOT CHANGE: an event  has a name, starting with ":", and a time.
#You can create one by calling e.g: myEvent = (:myEventTypeName, myTimeasAFloat)
struct Event
    type::Symbol
    time::Float64
end


struct Patient
    type::Symbol
    time::Float64 # of arrival
end


mutable struct SimStats
    n_served::Int64 #total, and per patient type, so nrPatientTypes+1 long 
    waitNormal::Array{Float64}
    waitLow::Array{Float64}
    waitHigh::Array{Float64} #per patient type waiting time + time service start, so nrPatientTypes vectors, and nr patients p patient type long 
    #Store state over time: time, ocupiedRooms, Queuelengths 
    overview_usage::Array{Float64,2}
    costsOfWaiting::Float64
end

#Describes the state of your process, similar to states in Markov. You can include as many variables as you like/need
mutable struct State #for multiple hospitals, change below to matrices
    ocupiedRooms::Int64
    totalRooms::Int64 

    # IDs? 
    queue::Vector{PriorityQueue{Patient,Float64}}  #Queue per priority level, priority level going down 
    t::Float64
    id::Int64


end




#TODO create this function
function arrival_patient(patient::Patient, env::Environment, state::State, events::PriorityQueue{Event,Float64}, stats::SimStats, t::Float64)
    if patient.type ==:High

        if isempty(state.loqalQueue[1])
            if state.totalRooms > state.ocupiedRooms
                e = Event(:serviceStart,t)
            else
                enqueue!(localQueue[1],patient,t)
                stats.overview_usage[1] = t
                stats.overview_usage[3] += 1
                # CORRECT ? 
            end 
        else 
            stats.overview_usage[1] = t
            stats.overview_usage[3] += 1 
            # Queuetimes? 

        end 

    elseif patient.type ==:Normal
        if isempty(state.localQueue[1])
            if isempty(state.localQueue[2])
                if state.totalRooms > state.ocupiedRooms
                    e = Event(:serviceStart,t)
                else 
                    enqueue!(localQueue[2],patient,t)
                    stats.overview_usage[1] = t
                    stats.overview_usage[4] += 1 
                    # CORRECT ? 
                end 
            else 
                enqueue!(localQueue[2],patient,t)
                stats.overview_usage[1] = t
                stats.overview_usage[4] += 1 
                # CORRECT ? 
            end 
            enqueue!(localQueue[2],patient,t)
            stats.overview_usage[1] = t
            stats.overview_usage[4] += 1 
            # CORRECT ? 
        end 
        
    else 
        if isempty(state.localQueue[1])
            if isempty(state.localQueue[2])
                if isempty(state.localQueue[3])
                    if state.totalRooms > state.ocupiedRooms
                        e = Event(:serviceStart,t)
                    else 
                        enqueue!(localQueue[3],patient,t)
                        stats.overview_usage[1] = t 
                        stats.overview_usage[5] += 1 
                        # CORRECT ? 
                    end 
                else 
                    enqueue!(localQueue[3],patient,t)
                    stats.overview_usage[1] = t 
                    stats.overview_usage[5] += 1 
                    # CORRECT ? 
                end 
            else
                enqueue!(localQueue[3],patient,t)
                stats.overview_usage[1] = t 
                stats.overview_usage[5] += 1 
                # CORRECT ? 
            end 
        else 
            enqueue!(localQueue[3],patient,t)
            stats.overview_usage[1] = t 
            stats.overview_usage[5] += 1 
            # CORRECT ? 
        end 
    end 



end



#TO DO create this function
function service_complete(env::Environment, state::State, stats::SimStats, events::PriorityQueue{Event,Float64}, t::Float64)
       
end

#Both after an arrival, or a service completion, a new service can start (someone is admitted to the room). 
#You can create this function for both these cases -- and call it at appropriate places in your code
function serviceStart(env::Environment, state::State, events::PriorityQueue{Event,Float64}, stats::SimStats,patient::Patient,  t::Float64)
   
end



function simulate(env::Environment, id::Int64)
    #Initialize the state of our process:
    localQueue = PriorityQueue{Patient,Float64}[] #Vector{PriorityQueue{Patient,Float64}}(PriorityQueue{Patient,Float64},3) 
    for i= 1:length(env.probDistrPatientType)
    push!(localQueue, PriorityQueue{Patient,Float64}())
    end
    state = State(0,env.nrRooms, localQueue)

    #Create an empty statistics field (n_served, waitingTimeHigh[],waitingTimeNormal[], waitingTimeLow[], overview_usage, costsOfWaiting )
    #overview usage: [current time, nrocupiedRooms, QueueLengthHigh,QueueLengthNormal,QueueLengthLow]
    overview_usage = [0 0 0 0 0]
    waitHigh=Float64[]
    waitNormal=Float64[]
    waitLow=Float64[]
    costsOfWaiting = 0.0
    stats = SimStats(0,waitHigh, waitNormal, waitLow, overview_usage, costsOfWaiting)
    
    #Initialize first event :
    t=0.0;
    events = PriorityQueue{Event,Float64}()
    nextArrival = t + env.arrivalRate_patient # TODO? 
    e1 = Event(:ArrivalPatient,nextArrival)
    enqueue!(events,e1,e1.time)
    
    warmUp = true;

    while !isempty(events)
        e = dequeue!(events)
        t = e.time
        
        if t>= env.warmUpTime+env.timeHorizonH
            agregatedStats = printResults(stats, env, id)
            return agregatedStats
        end

        if warmUp & (t >= env.warmUpTime)
            warmUp = false;
            waitHigh=Float64[]
            waitNormal=Float64[]
            waitLow=Float64[]
            costsOfWaiting = 0.0
            overview_usage = [t state.ocupiedRooms length(state.queue[1]) length(state.queue[2]) length(state.queue[3])]
            println("RESETTING. START OVERVIEW USAGE:", overview_usage)
            stats = stats = SimStats(0,waitHigh, waitNormal, waitLow, overview_usage, costsOfWaiting)
        end

        if e.type==:ArrivalPatient
            typePatient = rand(Uniform(0,1)) # Determine priority type 
            if typePatient < env.probDistrPatientType[2]
                patient = Patient(:Normal, t) 
            elseif typePatient < (env.probDistrPatientType[3]+env.probDistrPatientType[2])
                patient = Patient(:Low, t)
            else 
                patient = Patient(:High,t)
            end 
            arrival_patient(patient, env,state,event,stats,t)

           #ToDo: select priority class for the patient "pPriority, e.g. ":High", ":Normal", or ":Low" 
           #patient = Patient(pPriority, t) 
           #TODO: program function: arrival_patient(patient, env,state,events,stats, t)and then execute the function "patient arrival"
        elseif e.type==:ServiceComplete
                #Todo: program the fuunction "service_complete(env, state, stats, events, t)"
        end
    end
    #Print Results to file
    agregatedStats = printResults(stats, env, id)
    return agregatedStats
end




function printResults(stats::SimStats, env::Environment, id::Int )
#print some results to screen:
println("Nr served requests: ", stats.n_served)
println("Costs of Waiting: ", stats.costsOfWaiting)

#p = plot(stats.overview_usage[:,1],stats.overview_usage[:,2] , label="Ocupied Rooms")
p = plot(stats.overview_usage[:,1],stats.overview_usage[:,3] , label="QueueHigh")
p = plot!(stats.overview_usage[:,1],stats.overview_usage[:,4] , label="QueueNormal")
p = plot!(stats.overview_usage[:,1],stats.overview_usage[:,5] , label="QueueLow")
display(p)

averageRoomOccupation = timeWeightedAverage(stats.overview_usage[:,1], stats.overview_usage[:,2])
averageQueueLengthHigh = timeWeightedAverage(stats.overview_usage[:,1], stats.overview_usage[:,3])
averageQueueLengthNormal = timeWeightedAverage(stats.overview_usage[:,1], stats.overview_usage[:,4])
averageQueueLengthLow = timeWeightedAverage(stats.overview_usage[:,1], stats.overview_usage[:,5])
println("Average Room Occupation: " , averageRoomOccupation)
println("Average Queue Length High: " , averageQueueLengthHigh)
println("Average Queue Length Normal: " , averageQueueLengthNormal)
println("Average Queue Length Low: " , averageQueueLengthLow)


avWHigh = mean(stats.waitHigh) 
avWNorm = mean(stats.waitNormal)
avWLow=   mean(stats.waitLow)
println( "Average Waiting Time High", avWHigh)
println( "Average Waiting Time Normal", avWNorm)
println( "Average Waiting Time Low", avWLow)

#print detailed stats results to file, so you can review and analyze also later
open("C:/Users/evdh/OneDrive - Danmarks Tekniske Universitet/Teaching/DecisionUnderUncertainty/Simulation/resultsHospital$id.txt","a") do io
    println(io, "nrServed ", stats.n_served)
    println(io, "Costs of Waiting ", stats.costsOfWaiting)
    println(io, "Average Room Occupation: " , averageRoomOccupation)
    println(io, "Average Queue Length High: " , averageQueueLengthHigh)
    println(io, "Average Queue Length Normal: " , averageQueueLengthNormal)
    println(io, "Average Queue Length Low: " , averageQueueLengthLow)
    println(io, "Average Waiting Time High", avWHigh)
    println(io, "Average Waiting Time Normal", avWNorm)
    println(io, "Average Waiting Time Low", avWLow)
    println(io, stats.overview_usage)
    println(io, "-------------------------------")
    println(io, stats.waitHigh)
    println(io, stats.waitNormal)
    println(io, stats.waitLow)
 end

 return [stats.costsOfWaiting   averageRoomOccupation averageQueueLengthHigh averageQueueLengthNormal averageQueueLengthLow]
end


function printToFile(aggregatedStats)
    #print detailed stats results to file, so you can review and analyze also later
open("C:/Users/evdh/OneDrive - Danmarks Tekniske Universitet/Teaching/DecisionUnderUncertainty/Simulation/resultsHospitalAggregated.txt","a") do io
    println(io, aggregatedStats)
 end
end

function timeWeightedAverage(time::Array{Float64}, queueLength::Array{Float64})
timeWeightedAverage = 0
for i=2:length(queueLength)
    timeWeightedAverage += queueLength[i]*(time[i]-time[i-1])
end
timeWeightedAverage = timeWeightedAverage / (time[length(time)] - time[1])
end

function main()
    #The below will call the function "simulate" for "totalSimulations", and print results to file
    ###################################################
    #Settings
    t = 0.0
    totalRooms = 7
    weeksSimTime = 6
    weeksWarmUp = 2
    base = 24
    arrivalRate = 1/0.42
    serviceRate = 12.5
    probPerPatientType = [0.1, 0.6, 0.3]
    costsPerPatientType =  [10000.0 1000.0 100.0]
    nrPatientTypes = length(probPerPatientType)
    ###################################################

    ###################################################
    #Initialize variables
    #1. Environment   
    env = Environment(
        weeksSimTime*24*7, #6 weeks '
        weeksWarmUp*24*7,
        base,
        arrivalRate,
        probPerPatientType,
        serviceRate,
        totalRooms, 
        costsPerPatientType
        ) 

    totalSimulations = 1;
    curRun = 0
    overallStats=Array{Float64,2}
    while true
        aggregatedStats = simulate(env, curRun)
        println("Completed run $curRun")
        println("AggregatedStats: ", aggregatedStats)
        vcat(overallStats, aggregatedStats)
        curRun+=1;

    #If reached target, end loop
        if  curRun >= totalSimulations
            println("Completed $curRun runs")
            printToFile(overallStats)
            return
        end
    end
end

main()
end


