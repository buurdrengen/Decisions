## Hands on session week 5 ## 
# Monte-carlo in julia 

# Problem 1 
m = 24.67
sd = 0.23 
w = 0.1
z = 1.96

n = (1/w *sd*z)^2

# Problem 2
using Distributions
using Printf
struct Environment
    omegax::Uniform
    omegay::Uniform
    cost::Float64
    r::Float64

    Environment() = new(Uniform(-1,1),
    Uniform(-1,1),
    4,
    1)
end 

function pi_estimation(ns)
    pi_sampling = Environment()
    cv = zeros(ns)
    for i in 1:ns
        omegaxi = rand(pi_sampling.omegax)
        omegayi = rand(pi_sampling.omegay)
        cv[i] = pi_sampling.cost*(sqrt(omegaxi^2 + omegayi^2 ) <= pi_sampling.r)
    end 
    m = mean(cv)
    sd = std(cv)
    println(sd)
    quants = quantile.(Normal(m,sd),[0.05,0.95])
    println("pi estimate is: ", round.(m,digits=3))
    println("with confidence: ",round.(quants,digits=3))
end

pi_estimation(1000000)

# Problem 3 
function pakkeleg()
    i = 0 
    win = 0
    while win == 0
        drawi = rand(Multinomial(1,6),1) # Draw the dice 
        if drawi[6] == 1 # Check if 6 equals true 
            win = 1 # The game is won 
        end
        i += 1 
    end 
    println("Round at which the present is won is ", i)

    # If the round number is odd, player 1 has won 
    # If the round number is even, player 2 has won 
    if (isodd(i) == true)
        winnerid = 1
    else 
        winnerid = 2
    end 
    return(winnerid)
end 

function simulpakkeleg(Nrep, gain)
    winvec = zeros(2)
    for i in 1:Nrep
        winnerid = pakkeleg()
        winvec[winnerid] += 1 
    end 
    # Calculating the expecting wins 
    expwin = winvec./Nrep
    exputility = expwin.*gain 
    println("Expectation (/prob) to win for player 1: ", expwin[1])
    println("Expectation (/prob) to win for player 2: ", expwin[2])
    println("Expected utility for player 1: ", exputility[1])
    println("Expected utility for player 2: ", exputility[2])
end 

simulpakkeleg(1000,1000)