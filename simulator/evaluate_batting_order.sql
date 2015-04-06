
-- Evaluate batting order given 9 transition matrices and tolerance

create or replace function simulator3.evaluate_batting_order
(float[][], float[][], float[][], float[][], float[][],
 float[][], float[][], float[][], float[][],
 float)
returns float as '

# Passed in: 29x29 transitions matrices for players 1-9, epsilon
#   24 standard 
# Inning evaluations terminate when inning has ended with
#   probability >= 1-epsilon

transitions <- list(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
epsilon <- arg10

# rotation/slot x runs

runs <- matrix(0.0,9,30)

# inning x slot

leadoff <- matrix(0.0,9,9)
leadoff[1,1] <- 1.0

# leadoff slot this inning x leadoff slot next inning

slot <- matrix(0.0,9,9)

# rotation/slot

e_r <- matrix(0.0,9,1)

for (i in 1:9) {

n <- 3

a <- i
b <- (i+1)%%9
if (b==0) b<-9
c <- (i+2)%%9
if (c==0) c<-9

q <- (transitions[[a]]%*%transitions[[b]])%*%transitions[[c]]

runs[i,1] <- q[1,25]
t <- (n+i)%%9
if (t==0) t<-9
slot[i,t] <- q[1,25] + q[1,26] + q[1,27] + q[1,28]

e_r[i] <- q[1,25]*(n-3) + q[1,26]*(n-4) + q[1,27]*(n-5) + q[1,28]*(n-6)

while (q[1,29]<1-epsilon)
{

n <- n+1

s <- (n+i-1)%%9
if (s==0) s<-9

t <- (n+i)%%9
if (t==0) t<-9

q <- q%*%transitions[[s]]

if (n>=3) {runs[i,n-2] <- runs[i,n-2]+q[1,25]}
if (n>=4) {runs[i,n-3] <- runs[i,n-3]+q[1,26]}
if (n>=5) {runs[i,n-4] <- runs[i,n-4]+q[1,27]}
if (n>=6) {runs[i,n-5] <- runs[i,n-5]+q[1,28]}

e_r[i] <- e_r[i] + q[1,25]*(n-3) + q[1,26]*(n-4) + q[1,27]*(n-5) + q[1,28]*(n-6)

slot[i,t] <- slot[i,t] + q[1,25] + q[1,26] + q[1,27] + q[1,28]

}
}

for (i in 2:9) {
leadoff[i,] <- leadoff[i-1,] %*% slot }

e_score <- leadoff%*%e_r
return(sum(e_score))

' LANGUAGE 'plr';
