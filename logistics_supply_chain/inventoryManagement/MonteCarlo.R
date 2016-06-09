# Monte Carlo simulation for decision making under uncertainty

## Generate random varibles ------------------------------------------------------------
# performance of built-in generators - uniform distribution
Nsim = 10^4 # number of random numbers -> significanctly large assures randomness
            # them to be uniformly distributed
x = runif(Nsim) # uniform generator, arg: the number of values to be generated
                # in reality runif is deterministic sequence based on a random starting point
# runif(100, min=2, max=5) # min and max are optional arguments

x1 = x[-Nsim] #vectors to plot
x2 = x[-1] #adjacent pairs
par(mfrow = c(1,3))

# Visualise to check the properties of this uniform generator
# i.e. we want to see that the distribution is indeed random
hist(x,cex.lab = 2, cex.axis=2, cex.main=2, cex.sub=2) # histogram
plot(x1,x2,cex.lab = 2, cex.axis=2, cex.main=2, cex.sub=2) # plot the pairs
acf(x,cex.lab = 2, cex.axis=2, cex.main=2, cex.sub=2) # estimate autocorrelation function


## Deterministic sequence based on the seed ---------------------------------------------
# Produces the same sequence: setting the seed determines all the subsequent values
set.seed(1)
runif(5)
set.seed(1)
runif(5)
set.seed(2)
runif(5)


## Inverse transform to generate non-standard distributions -------------------------------
# Different methods do generate the same
Nsim=10^4 #number of random variables
U=runif(Nsim)
X=-log(1-U) #transforms of uniforms
Y=rexp(Nsim) #exponentials from R
par(mfrow=c(1,2)) #plots
hist(X,freq=F,main="Exp from Uniform")
hist(Y,freq=F,main="Exp from R")


## Generating non-standard discrete distributions  -----------------------------------------
# 
Nsim=10^4 #number of random variables
U=runif(Nsim)
U[U<=0.01] = 4
U[0.01<U & U<=0.03] = 5
U[0.03<U & U<=0.07] = 6
U[0.07<U & U<=0.15] = 7
U[0.15<U & U<=0.24] = 8
U[0.24<U & U<=0.35] = 9
U[0.35<U & U<=0.51] = 10
U[0.51<U & U<=0.71] = 11
U[0.71<U & U<=0.82] = 12
U[0.82<U & U<=0.92] = 13
U[0.92<U & U<=0.96] = 14
U[0.96<U & U<=0.98] = 15
U[0.98<U & U<=0.99] = 16
U[0.99<U & U<=1] = 17
hist(U, breaks=4:18, right=F, freq=F)


# Evaluating monthly payments with the new plan
usage_1000 <- rnorm(1000, mean=23, sd=5)
payment_1000 <- 160+15*pmax((usage_1000-20),0)
mean(payment_1000)
par(mfrow=c(1,2)) #plots
# Histograms are often useful for gaining intuition about the inputs 
# and the outputs involved in a simulation
hist(usage_1000,breaks=20,freq=F,main="Monthly Usage")
hist(payment_1000,breaks=20,freq=F,main="Monthly Payment")


# Validate the random variable generation by comparing the sample mean and 
# standard deviation with the true values
set.seed(1)
usage_10 <- rnorm(10, mean=23, sd=5)
mean(usage_10)
sd(usage_10)
usage_1000 <- rnorm(1000, mean=23, sd=5) # closer to the true values of 23 and 5 than the 
                                          # corresponding sample mean and standard deviation
mean(usage_1000)
sd(usage_1000)
# Expected monthly payment under the new plan: £218.92
