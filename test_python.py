import simpy
import random

# Define the constants
NUM_ROOMS = 10
URGENT_PROB = 0.1
NORMAL_PROB = 0.6
LOW_PROB = 0.3
SIM_TIME = 24*7 # 1 week
AVAILABILITY_COSTS = {
    "urgent": 10000,
    "normal": 1000,
    "low": 100
}

# Define the processes
def patient(env, name, priority, wait_time, delivery_time, delivery_duration, delivery_room):
    """A patient arrives, waits for a room, delivers, and leaves."""
    arrival_time = env.now
    print(f"{name} arrives at {arrival_time:.2f} with priority {priority}.")
    
    with delivery_room.request(priority) as req:
        yield req
        wait_time += env.now - arrival_time
        print(f"{name} enters the room at {env.now:.2f} after waiting for {wait_time:.2f}.")
        yield env.timeout(delivery_duration)
        print(f"{name} delivers at {env.now:.2f}.")
    
    delivery_time += env.now - arrival_time
    print(f"{name} leaves at {env.now:.2f} after spending {delivery_time:.2f} in the hospital.")

# Define the simulation environment
def hospital(env, num_rooms):
    """A hospital has a limited number of delivery rooms (resources) that patients need."""
    delivery_rooms = simpy.PriorityResource(env, capacity=num_rooms)
    wait_times = {"urgent": [], "normal": [], "low": []}
    delivery_times = {"urgent": [], "normal": [], "low": []}
    
    # Generate patients with random arrival times and priorities
    for i in range(1000):
        priority = "low"
        if random.random() < URGENT_PROB:
            priority = "urgent"
        elif random.random() < NORMAL_PROB:
            priority = "normal"
        
        delivery_duration = random.expovariate(1/12.5)
        delivery_room = delivery_rooms
        wait_time = 0
        delivery_time = 0
        
        env.process(patient(env, f"Patient {i}", priority, wait_time, delivery_time, delivery_duration, delivery_room))
        yield env.timeout(random.expovariate(1/5)) # Generate new patients every 5 hours
    
    # Print the wait times and delivery times for each priority category
    for priority in ["urgent", "normal", "low"]:
        avg_wait_time = sum(wait_times[priority])/len(wait_times[priority])
        avg_delivery_time = sum(delivery_times[priority])/len(delivery_times[priority])
        availability_costs = AVAILABILITY_COSTS[priority] * (SIM_TIME - sum(delivery_times[priority]))
        print(f"Priority: {priority}, Avg. Wait Time: {avg_wait_time:.2f}, Avg. Delivery Time: {avg_delivery_time:.2f}, Availability Costs: {availability_costs:.2f} DKK.")
    
# Run the simulation
env = simpy.Environment()
env.process(hospital(env, NUM_ROOMS))
env.run(until=SIM_TIME)