## PROJECT: MARKOV ## 

# 3 a) 
# 5 centers. 
# Arrival rate of 0.42 pr hour 
# Average room occupation time for 12.5 hours = 0.08 patient/hour
# 8 rooms = 8 servers

# Solution a) 
# Arrival at 5 centers
# Waiting time in queue: 56.3 min = 56 min 
# Occupation rate: 0.65625 
0.42/(8*0.08)
# The percentage of time there is atleast one person waiting for a room: The percentage of time no-one is waiting for a room is p0
# so the percentage of time there is at least one person waiting for a room is 1 - p0.
1-(0.004961)
# so 99.5% of the time there is at least one person waiting for a room. 
# Percentage of time there is a queue of 2 or more: First p0 (prob that 0 patients in the queue) = 0.4961 %, then p1 = 2.6045% 
1-(0.004961+0.026045)
# p2 or more = 0.968994 = 96.9 % 

# 3 b) 
# 4 centers 
# Arrival rate of 0.525 pr hour 
# Average room occupation time for 12.5 hours = 0.08 patient/hour 
# 10 rooms = 10 servers 

# Solution b) 
# Arrival at 4 centers 
# Waiting time in queue: 35.2 min
# Occupation rate: 0.65625
0.525/(10*0.08)
# The percentage of time there is atleast one person waiting for a room: The percentage of time no-one is waiting for a room is p0
# so the percentage of time there is at least one person waiting for a room is 1 - p0 
1 - 0.0013584
# so 99.9% of the time there is at least one person waiting for a room. 
# Percentage of time there is a queue of 2 or more: First p0 (prob that 0 patients in the queue) = 0.13584 %, then p1 = 0.8915 % 
1 - (0.0013584 + 0.008915) 
# p2 or more = 0.9897266 = 98.97 % 

# 3.5 
# Assume that the target is to have the amount of time that there are 2 or more people waiting
# for a room to be less than 5%. Calculate the number of available rooms required for the case
# of 4 and 5 birth centers (note the change in arrival rate for these settings as stated above).
# What is the difference in the total number of required rooms?
# The percentage of time where there is 2 or more people in the queue 
1-(0.004961+0.026045+0.06837)

