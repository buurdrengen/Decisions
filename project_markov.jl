## PROJECT: MARKOV ## 

# 3 a) 
# 5 centers. 
# Arrival rate of 0.42 pr hour 
# Average room occupation time for 12.5 hours = 0.08 patient/hour
# 8 rooms = 8 servers

# Solution a) 
# Arrival at 5 centers
lambda = 0.42 # Arrival rate
mu = 0.08 # service rate
s = 8 # Number of servers 
rho = 0.42/(8*0.08) # Occupation rate: 0.65625
summ = 0 # Calculating the sum used to determine p0: 
for i in 0:(s-1)
    summ += ((lambda/mu)^i)/factorial(i)
end 
# The probability that no one is in the rooms or in the queue: 
p0 = 1/( summ + (((lambda/mu)^s)/factorial(s)) * (1/(1-(lambda/(s*mu)))))

# Lq, number of customers in the queue
lq = (p0*((lambda/mu)^s)*rho)/(factorial(s)*((1-rho)^2))

wq = lq/lambda # Waiting time in queue: 56.3 min = 56 min 

# Number of patients in queue where from p1 to p8 is the probability that the 8 rooms are occupied.
# To determine the probability that 1 person is waiting for instance, p9 need to be calculated. 
n = range(1,8)
p_occupied = Vector{Float64}()
for j in n 
    p = (((lambda/mu)^j)/factorial(j))*p0
    push!(p_occupied,p)
end 
#println("The probability that all rooms are full: ",1-sum(p_occupied))
p9 = (((lambda/mu)^9)/factorial(9))*p0
println("(5 center) The probability that at least one person is waiting for a room is: ",1-(sum(p_occupied)))
println("(5 center) The probability that at least two persons is waiting for a room is: ",1-(sum(p_occupied)+p9))

# 3 b)
# 4 centers 
# Arrival rate of 0.525 pr hour 
# Average room occupation time for 12.5 hours = 0.08 patient/hour 
# 10 rooms = 10 servers 
lambda1 = 0.525 # Arrival rate
mu = 0.08 # service rate
s1 = 10 # Number of servers 
rho1 = lambda1/(s1*mu) # Occupation rate: 0.65625
summ1 = 0 # Calculating the sum used to determine p0: 
for i in 0:(s1-1)
    summ1 += ((lambda1/mu)^i)/factorial(i)
end 
# The probability that no one is in the rooms or in the queue: 
p01 = 1/( summ1 + (((lambda1/mu)^s1)/factorial(s1)) * (1/(1-(lambda1/(s1*mu)))))

# Lq, number of customers in the queue
lq1 = (p01*((lambda1/mu)^s1)*rho1)/(factorial(s1)*((1-rho1)^2))

wq1 = lq1/lambda1 # Waiting time in queue: 35 minuttes 

# Number of patients in queue where from p1 to p8 is the probability that the 8 rooms are occupied.
# To determine the probability that 1 person is waiting for instance, p9 need to be calculated. 
n1 = range(1,10)
p_occupied1 = Vector{Float64}()
for j in n1 
    p1 = (((lambda1/mu)^j)/factorial(j))*p01
    push!(p_occupied1,p1)
end 
#println(p_occupied1)
#println("The probability that all rooms are full: ",1-sum(p_occupied))
p11 = (((lambda1/mu)^11)/factorial(11))*p01
println("(4 center) The probability that at least one person is waiting for a room is: ",1-(sum(p_occupied1)))
println("(4 center) The probability that at least two persons is waiting for a room is: ",1-(sum(p_occupied1)+p11))




# 3.5 
# For 5 centers we have probability for 2 or more people waiting 0.09910387095483297 = 9.9%. 
# Determining how much probability that needs to be "cut off" to reach 5% or less: 
s = 9
summ = 0 # Calculating the sum used to determine p0: 
for i in 0:(s-1)
    summ += ((lambda/mu)^i)/factorial(i)
end 
p0 = 1/( summ + (((lambda/mu)^s)/factorial(s)) * (1/(1-(lambda/(s*mu)))))
n = range(1,9)
p_occupied = Vector{Float64}()
for j in n 
    p = (((lambda/mu)^j)/factorial(j))*p0
    push!(p_occupied,p)
end 

p10 = (((lambda/mu)^10)/factorial(10))*p0
println("(5 center) The probability that at least one person is waiting for a room is: ",1-(sum(p_occupied)))
println("(5 center) The probability that at least two persons is waiting for a room is: ",1-(sum(p_occupied)+p10))
# With 9 servers = 9 rooms*5centers = 45 rooms the probability that 2 or more people are in the queue is
# p = 0.04275151052802617

# For 4 centers we have the probability for 2 or more people waiting 0.0741475302248843 = 7.4 %. 
s1 = 11 
summ1 = 0 # Calculating the sum used to determine p0: 
for i in 0:(s1-1)
    summ1 += ((lambda1/mu)^i)/factorial(i)
end 
# p0:
p01 = 1/( summ1 + (((lambda1/mu)^s1)/factorial(s1)) * (1/(1-(lambda1/(s1*mu)))))

# Number of patients in queue where from p1 to p8 is the probability that the 8 rooms are occupied.
# To determine the probability that 1 person is waiting for instance, p9 need to be calculated. 
n1 = range(1,11)
p_occupied1 = Vector{Float64}()
for j in n1 
    p1 = (((lambda1/mu)^j)/factorial(j))*p01
    push!(p_occupied1,p1)
end 
#println(p_occupied1)
#println("The probability that all rooms are full: ",1-sum(p_occupied))
p11 = (((lambda1/mu)^12)/factorial(12))*p01
println("(4 center) The probability that at least one person is waiting for a room is: ",1-(sum(p_occupied1)))
println("(4 center) The probability that at least two persons is waiting for a room is: ",1-(sum(p_occupied1)+p11))
# With 11 servers = 11 rooms*4centers = 44 rooms the probability that 2 or more people are in the queue is
# p = 0.03298138934868655
# AND with 1 person in the queue almost 5 %: 
# p = 0.05151752790626385