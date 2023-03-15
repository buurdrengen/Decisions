## PROJECT: 3. SIMULATION ## 

# 1, 2, 3, 4: Monte Carlo simulation 
# Normal distributed with mean 40 and standard deviation of 15 
# Cost of leftovers 30 DKK and cost of shortage 100 DKK 
# Objective: Create a function that can evaluate the costs of a fixed number of meals 
# ordered every day for 100 days 
# Choose a number of meals: 40 - to be changed? 

using Distributions
function meals(no_meals,days)
    mu = 40 
    sigma = 15 
    c_left = 30 
    c_shortage = 100 
    total_cost = 0 
    
    for i in 1:days
        drawi = rand(Normal(mu,sigma),1)
        drawi = round.(drawi,digits=0)
        # Check for negative
        #println(drawi)
        if drawi[1] < no_meals
            short_meal = no_meals - drawi[1]
            total_cost += short_meal*c_shortage
            #println(total_cost)
        elseif drawi[1] > no_meals
            left_meal = drawi[1] - no_meals
            total_cost += left_meal*c_left 
            #println(total_cost)
        else 
            total_cost += 0
        end 
    end 
    println("The total cost for 100 days is: ",total_cost)
    println("The cost per day per meal for in total $no_meals meals is: ",(total_cost/100)/no_meals)
end 

meals(40,100)