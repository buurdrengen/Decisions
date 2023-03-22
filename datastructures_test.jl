## DATA-STRUCTURES TEST ## 
using Pkg
using DataStructures
using Distributions
using Random

struct Patient
    type::Symbol
    time::Float64
end 

localQueue = PriorityQueue{Patient,Float64}[]
nrPatientTypes = 3

for i = 1:nrPatientTypes
    push!(localQueue,PriorityQueue{Patient,Float64}())
end

arrival = 2.5 
prio = :High 
p = Patient(prio,arrival)
enqueue!(localQueue[1],p,arrival)
println(localQueue)

p1 = Patient(:Normal,3.2)
enqueue!(localQueue[2],p1,3.2)
println(length(localQueue[3]))


println(localQueue)

struct Event
    type::Symbol
    time::Float64
end 

# make 3 individual queues 
queueU = PriorityQueue{Event,Float64}()
queueN = PriorityQueue{Event,Float64}()
queueL = PriorityQueue{Event,Float64}()

enqueue!(queueU,Event(:U,2),2)

# vector queue
mutable struct State
    occupiedRooms::Int32
    totalRooms::Int32
    #t::Float64
    #queue::PriorityQueue{Event,Float64}
    #State() = new(Int32,Int32,0,PriorityQueue{Event,Float64}())
    Stat() = new(0,0)
end

function Q(state::State)
    tt = 10*(1-rand()) # just draw uniformly between 0 and 10.
    # create event
    e = Event(:U,tt)
    enqueue!(state.queue,e,e.time)
    println(queue)
end
function main()
    state = State()
    Q(state)
    println(Q)
end

main()


enqueue!(queue,Event(:U,2),2)

println(queue)



using DataStructures
using Distributions
using Random

a = (:A,3.4)
localc = PriorityQueue{Tuple,Float64}[]
for i=1:3
    push!(localc, PriorityQueue{Tuple,Float64}())
end 
println(localc)