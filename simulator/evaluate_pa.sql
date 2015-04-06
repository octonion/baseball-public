
-- Evaluate PA given transition matrix and tolerance

create or replace function simulator.evaluate_pa
(float[][], float)
returns setof record as '

# Passed in: 18x18 transitions matrix, epsilon
#   12 standard 
# PA evaluation terminates when PA has ended with
#   probability >= 1-epsilon

p <- arg1
epsilon <- arg2

# pitches seen

pitches <- array(0.0,30)

n <- 1
q <- p
pitches[1] <- q[1,13] + q[1,14] + q[1,15] + q[1,16] + q[1,17]
e_p <- pitches[1]
e_s <- q[1,13] + q[1,14]
e_w <- q[1,15]
e_h <- q[1,16]
e_i <- q[1,17]

while (q[1,18]<1-epsilon)
{

n <- n+1
q <- q%*%p
pitches[n] <- q[1,13] + q[1,14] + q[1,15] + q[1,16] + q[1,17]
e_p <- e_p + n*pitches[n]
e_s <- e_s + q[1,13] + q[1,14]
e_w <- e_w + q[1,15]
e_h <- e_h + q[1,16]
e_i <- e_i + q[1,17]

}

return(e_p,e_s,e_w,e_h,e_i)

' LANGUAGE 'plr';
