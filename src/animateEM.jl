# Load Packages
using Plots, Distributions

# All of the following is made to be run through the julia REPL.


# Once we have loaded Distributions, lets use a bivariate normal, lets use
# Bivariate Normal of dimension 2 as an example animation.


μ = [0.0,0.0];
Σ = [1.0 0.0;
     0.0 1.0];

simple_binorm = MvNormal(μ, Σ)

# Lets plot the contour of this Bivariate normal

x_grid = -10:0.05:10;
y_grid = copy(x_grid);

contour(x_grid,y_grid, # place grids
        (x,y)->Distributions.pdf(simple_binorm,[x,y]), # anon function to provide density calc for contour
        c = :plasma, # some colour
        fill = true # and fill
        )


# Suppose I generate another mvnorm with μ = [3,3], cov the same

μ_2 = [3.0,3.0];
simple_binorm_2 = MvNormal(μ_2, Σ)

contour(x_grid,y_grid, # place grids
        (x,y)->Distributions.pdf(simple_binorm_2,[x,y]), # anon function to provide density for contour
        c = :plasma, # some colour
        fill = true # and fill
        )


# ===========================================================================
# Writing Julia Code for custom structures                                  #
# ===========================================================================

# Lets create a structure that represents a mixture of distributions

mutable struct MixG
        τ::Array{Float64,1} # tau is an array of mixing proportions
        dists #is an array of distributions, I have left this untyped
end

# Once you have defined the struct, it would be best
# to write your own custom constructor.

# For example, all of mixing proportions should add to 1,
# if they do not when intialize you should get an error.

function MixG(τ,dists) # note that this function name is the same as the constructor

        # Check for convexity, the only constraint on a mix gaussian
        if(τ |> sum != 1.0)
                error("not convex\n")
        end
end

# Create mixture of gaussian structure
mix_gs = MixG([0.5,0.5],[simple_binorm,simple_binorm_2])


# Note that the package Distributions has a pdf function already.
# first you need to import this function before you extend it.
# import Distributions.pdf
# now you can extend the pdf function to your mixture of Gaussians.
function pdf(d_s::MixG,x,y)
        rez = 0.0;
        count = 1;
        for dist in d_s.dists
                rez += (Distributions.pdf(dist,[x,y]))*d_s.τ[count]
                count+=1
        end
        return rez
end

# now plot and see that this new function works.
contour(x_grid,y_grid, (x,y) -> pdf(mix_gs,x,y), c = :inferno)

#indeed it does


# ===========================================================================
# Creating Animated Gifs using Julia                                        #
# ===========================================================================

# Lets practice animating this
Σ = [1.0 0.0;
     0.0 1.0];

# animate through the grid
# note that this animation takes a while
anim = @animate for i = -10:0.05:10

        μ = [i,i].*1.0;
        μ_2 = [i,-i]*1.0;

        simple_binorm_2 = MvNormal(μ_2, Σ)
        simple_binorm = MvNormal(μ, Σ)

        # Create mixture of gaussian structure
        mix_gs = MixG([0.5,0.5],[simple_binorm,simple_binorm_2])

        # now plot and see that this function works
        contour(x_grid,y_grid,
                (x,y) -> pdf(mix_gs,x,y),
                c = :inferno,
                background_color_outside= :black,
                background_color_inside= :black)

end every 1 # every 1 or 2 or ... k steps you can save picture instead of all of them
# note that this animation takes a while

# save the animation put it anywhere you would like and name it accordingly
name = "anim_fps15.gif"
loc = "/Users/nik/$name"

# save gif of animation.
gif(anim, loc, fps = 45)
