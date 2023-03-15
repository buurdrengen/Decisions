## DATA-STRUCTURES TEST ## 
using Pkg
using DataStructures
using Distributions
using Random



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