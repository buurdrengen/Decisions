## PROJECT: 3. SIMULATION ## 

# 1, 2, 3, 4: Monte Carlo simulation 
# Normal distributed with mean 40 and standard deviation of 15 
# Cost of leftovers 30 DKK and cost of shortage 100 DKK 
# Objective: Create a function that can evaluate the costs of a fixed number of meals 
# ordered every day for 100 days 
using Distributions
using HypothesisTests
function meals(no_meals)
    #no_meals = 40
    days = 100
    mu = 40 
    sigma = 15 
    c_left = 30 
    c_shortage = 100 
    total_cost_1 = Vector{Float64}()
    #print(total_cost)
    
    for i in 1:days
        #println("no_meals = ",no_meals)
        normal= Normal(mu,sigma)
        td = truncated(normal,0,Inf)
        drawi = rand(td,1)
        drawi = round.(drawi,digits=0)
        # truncated distribution to get positive values 

        #println("draw: ",drawi)
        if drawi[1] > no_meals
            short_meal = drawi[1] - no_meals
            if short_meal < 10 
                cost_short = 90*short_meal
            elseif short_meal < 25 
                cost_short = 110*short_meal
            else 
                cost_short = rand(Normal(150,20),1)*short_meal
            end 
            # cost_short = c_shortage*no_meals 
            push!(total_cost_1,cost_short[1])
        elseif drawi[1] < no_meals
            left_meal = no_meals - drawi[1]
            cost_left = left_meal*c_left 
            push!(total_cost_1,cost_left)
            #println(total_cost)
            #no_meals -= 2
        else 
            push!(total_cost_1,0)
        end 
    end 
    #avegare_meal = total_cost ./ no_meals
    #conf = confint(OneSampleTTest(avegare_meal), level=0.95)
    #println("Conf interval: ", conf, "with mean: ",(mean(total_cost))./no_meals)
    #println("The total cost for 100 days is: ",total_cost)
    #println("The cost per day per meal for in total $no_meals meals is: ",)
    return total_cost_1
end 

# Meals function for the second hospital
function meals2(no_meals)
    #no_meals = 40
    days = 100
    mu = 80
    sigma = 30 
    c_left = 30 
    c_shortage = 100 
    total_cost_2 = Vector{Float64}()
    #print(total_cost)
    
    for i in 1:days
        #println("no_meals = ",no_meals)
        normal= Normal(mu,sigma)
        td = truncated(normal,0,Inf)
        drawi = rand(td,1)
        drawi = round.(drawi,digits=0)
        # truncated distribution to get positive values 

        #println("draw: ",drawi)
        if drawi[1] > no_meals
            short_meal = drawi[1] - no_meals
            cost_short = short_meal*c_shortage
            push!(total_cost_2,cost_short)
        elseif drawi[1] < no_meals
            left_meal = no_meals - drawi[1]
            cost_left = left_meal*c_left 
            push!(total_cost_2,cost_left)
            #println(total_cost)
            #no_meals -= 2
        else 
            push!(total_cost_2,0)
        end 
    end 
    #avegare_meal = total_cost ./ no_meals
    #conf = confint(OneSampleTTest(avegare_meal), level=0.95)
    #println("Conf interval: ", conf, "with mean: ",(mean(total_cost))./no_meals)
    #println("The total cost for 100 days is: ",total_cost)
    #println("The cost per day per meal for in total $no_meals meals is: ",)
    return total_cost_2
end 

function simulmeals(Nrep)
    average_meal_list = zeros((8,Nrep))
    no_meals = 1
    quant = quantile(Normal(0.0, 1.0),1-(1-0.95)/2)
    for i in 1:Nrep
        #First/original hospital loop, fill in cost pr meal with confidence intervals 
        total_cost_1 = meals(no_meals)
        amount = (mean(total_cost_1))/no_meals
        s = std(total_cost_1)
        lowconf = amount - (quant*s)/100 # n = 100 for 100 days simulated
        lowconf = round.(lowconf,digits=1)
        upconf = amount + (quant*s)/100
        upconf = round.(upconf,digits=1)
        amount = round.(amount,digits=1)
        average_meal_list[1,i] = no_meals
        average_meal_list[3,i] = amount 
        average_meal_list[2,i] = lowconf
        average_meal_list[4,i] = upconf
        
        # Second hospital
        total_cost_2 = meals2(no_meals)
        cost_meal = (mean(total_cost_2))/no_meals 
        s2 = std(total_cost_2)
        lowconf2 = cost_meal - (quant*s2)/100 
        lowconf2 = round.(lowconf2,digits=1)
        upconf2 = cost_meal + (quant*s2)/100
        upconf2 = round.(upconf2,digits=1)
        cost_meal = round.(cost_meal,digits=1)   
        average_meal_list[5,i] = no_meals
        average_meal_list[6,i] = lowconf2
        average_meal_list[7,i] = cost_meal
        average_meal_list[8,i] = upconf2 

        no_meals += 1 
    end 
    min_meals1 = findmin(average_meal_list[3,:])
    max_meals1 = findmax(average_meal_list[3,:])
    min_meals2 = findmin(average_meal_list[7,:])
    max_meals2 = findmax(average_meal_list[7,:])
    #println("Meal price list: ", average_meal_list)
    println("Minimum cost pr meal is with the index - hosp 1: ",min_meals1)
    println("Maximum cost pr meal is with the index - hosp 1: ",max_meals1)
    println("Minimum cost pr meal is with the index - hosp 2: ",min_meals2)
    println("Maximum cost pr meal is with the index - hosp 2: ",max_meals2)
    # if Nrep > 1 
    #     conf = confint(OneSampleTTest(average_meal_list),level=0.95)
    #     println("Conf interval: ",conf) 
    # else 
    #     println("Confidence can't be determined from 1 rep!") 
    # end  
    return average_meal_list     
end
average_meal_list = simulmeals(200)



 
using DelimitedFiles
writedlm("results_monte3.csv",average_meal_list,",")

resultsfile = "results_monte.txt"
open(resultsfile,"w") do f 
    for j in average_meal_list
        println(f,j)
    end 
end