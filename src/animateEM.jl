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
        (x,y)->Distributions.pdf(simple_binorm,[x,y]), # anynmous function to provide density for contour
        c = :plasma, # some colour
        fill = true # and fill
        )


# Suppose I generate another mvnorm with μ = [3,3], cov the same

μ_2 = [3.0,3.0];
simple_binorm_2 = MvNormal(μ_2, Σ)

contour(x_grid,y_grid, # place grids
        (x,y)->Distributions.pdf(simple_binorm_2,[x,y]), # anynmous function to provide density for contour
        c = :plasma, # some colour
        fill = true # and fill
        )



# Lets create a structure that incorporates a mixture of gaussians


mutable struct MixG
        τ::Array{Float64,1}
        dists
end

function MixG(τ,dists)
        if(τ |> sum != 1.0)
                error("not convex\n")
        end
end

# Create mixture of gaussian structure
mix_gs = MixG([0.5,0.5],[simple_binorm,simple_binorm_2])


# define a pdf function for it
function pdf(d_s::MixG,x,y)
        rez = 0.0;
        count = 1;
        for dist in d_s.dists
                rez += (Distributions.pdf(dist,[x,y]))*d_s.τ[count]
                count+=1
        end
        return rez
end


# now plot and see that this function works
contour(x_grid,y_grid, (x,y) -> pdf(mix_gs,x,y), c = :inferno)


# Lets practice animating this
Σ = [1.0 0.0;
     0.0 1.0];
anim = @animate for i = -10:0.05:10

        μ = [i,i].*1.0;
        μ_2 = [i,-i]*1.0;


        simple_binorm_2 = MvNormal(μ_2, Σ)
        simple_binorm = MvNormal(μ, Σ)
        # Create mixture of gaussian structure
        mix_gs = MixG([0.5,0.5],[simple_binorm,simple_binorm_2])

        # now plot and see that this function works
        contour(x_grid,y_grid, (x,y) -> pdf(mix_gs,x,y), c = :inferno,
        background_color_outside= :black,background_color_inside= :black)

end every 1

# save the animation
gif(anim, "/Users/nik/anim_fps15.gif", fps = 45)
