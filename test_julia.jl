using Distributions
using DataStructures

# Define patient types
struct Patient
    priority::Int  # 1 for urgent, 2 for normal, 3 for low
    arrival::Float64
    start::Union{Nothing, Float64}
    finish::Union{Nothing, Float64}
end

# Define room type
struct Room
    id::Int
    available::Bool
end

# Define simulation parameters
num_patients = 1000
urgency_probs = [0.1, 0.6, 0.3]
mean_duration = 12.5

# Initialize simulation state
patients = PriorityQueue{Float64, Patient}()
rooms = [Room(i, true) for i in 1:10]
current_time = 0.0

# Define event handlers
function handle_patient_arrival()
    # Generate a new patient and add to queue
    priority = rand(Categorical(urgency_probs))
    arrival_time = current_time
    patient = Patient(priority, arrival_time, nothing, nothing)
    push!(patients, (arrival_time, patient))
end

function handle_room_assignment()
    # Assign the first available room to the longest-waiting patient
    for room in rooms
        if room.available
            for (_, patient) in patients
                if patient.priority == 1 && patient.start == nothing
                    # Assign to urgent patient
                    patient.start = current_time
                    patient.finish = current_time + rand(Exponential(mean_duration))
                    room.available = false
                    break
                elseif patient.priority == 2 && patient.start == nothing
                    # Assign to normal patient
                    patient.start = current_time
                    patient.finish = current_time + rand(Exponential(mean_duration))
                    room.available = false
                    break
                elseif patient.priority == 3 && patient.start == nothing
                    # Assign to low-priority patient
                    patient.start = current_time
                    patient.finish = current_time + rand(Exponential(mean_duration))
                    room.available = false
                    break
                end
            end
        end
    end
end

# Run simulation
for i in 1:num_patients
    handle_patient_arrival()
    handle_room_assignment()
    current_time, patient = pop!(patients)
    sleep(patient.finish - current_time)
end

# Calculate and print costs
urgent_cost = sum([patient.finish - patient.arrival for (_, patient) in patients if patient.priority == 1]) * 10000
normal_cost = sum([patient.finish - patient.arrival for (_, patient) in patients if patient.priority == 2]) * 1000
low_cost = sum([patient.finish - patient.arrival for (_, patient) in patients if patient.priority == 3]) * 100

println("Total cost: ", urgent_cost + normal_cost + low_cost)
println("Urgent cost: ", urgent_cost)
println("Normal cost: ", normal_cost)
println("Low cost: ", low_cost)