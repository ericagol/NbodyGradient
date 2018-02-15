include("/Users/ericagol/Computer/Julia/regress.jl")

n = 8
include("ttv.jl")
t0 = 7257.93115525
#h  = 0.12
h  = 0.075
tmax = 600.0
#tmax = 80.0

# Read in initial conditions:
elements = readdlm("../test/elements.txt",',')

# Make an array, tt,  to hold transit times:
# First, though, make sure it is large enough:
ntt = zeros(Int64,n)
for i=2:n
  ntt[i] = ceil(Int64,tmax/elements[i,2])+3
end
println("ntt: ",ntt)
tt  = zeros(n,maximum(ntt))
tt1 = zeros(n,maximum(ntt))
tt2 = zeros(n,maximum(ntt))
tt3 = zeros(n,maximum(ntt))
# Save a counter for the actual number of transit times of each planet:
count = zeros(Int64,n)
count1 = zeros(Int64,n)
# Call the ttv function:
rstar = 1e12
dq = ttv_elements!(n,t0,h,tmax,elements,tt1,count1,0.0,0,0,rstar)
@time dq = ttv_elements!(n,t0,h,tmax,elements,tt1,count1,0.0,0,0,rstar)
# Now, try calling with kicks between planets rather than -drift+Kepler:
pair_input = zeros(Bool,n,n)
# We want Keplerian between star & planets, and impulses between
# planets.  Impulse is indicated with 'true', -drift+Kepler with 'false':
#for i=2:n
#  pair_input[1,i] = false
#  # We don't need to define this, but let's anyways:
#  pair_input[i,1] = false
#end
# Now, only include Kepler solver for adjacent planets:
#for i=2:n-1
#  pair_input[i,i+1] = false
#  pair_input[i+1,i] = false
#end

# Now call with smaller timestep:
count2 = zeros(Int64,n)
count3 = zeros(Int64,n)
dq = ttv_elements!(n,t0,h/10.,tmax,elements,tt2,count2,0.0,0,0,rstar)
println("Timing error -drift+Kepler: ",maximum(abs.(tt2-tt1))*24.*3600.)
@time dq = ttv_elements!(n,t0,h,tmax,elements,tt1,count1,0.0,0,0,rstar;pair=pair_input)
dq = ttv_elements!(n,t0,h/10.,tmax,elements,tt2,count2,0.0,0,0,rstar;pair=pair_input)
println("Timing error kickfast:      ",maximum(abs.(tt2-tt1))*24.*3600.)

# Now, compute derivatives (with respect to initial cartesian positions/masses):
dtdq0 = zeros(n,maximum(ntt),7,n)
dtdelements0 = zeros(n,maximum(ntt),7,n)

dtdelements0 = ttv_elements!(n,t0,h,tmax,elements,tt,count,dtdq0,rstar;pair=pair_input)
@time dtdelements0 = ttv_elements!(n,t0,h,tmax,elements,tt,count,dtdq0,rstar)

Profile.clear()
Profile.init(10^7,0.01)
#@profile dtdelements0 = ttv_elements!(n,t0,h,tmax,elements,tt,count,dtdq0,rstar);
#Profile.print()
