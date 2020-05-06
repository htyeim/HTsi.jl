# Ap and Kp index


	bar3(cmd0::String="", arg1=nothing; kwargs...)


- **R** or *region* or *limits* : -- *limits=(xmin, xmax, ymin, ymax, zmin, zmax)* **|** *limits=(BB=(xmin, xmax, ymin, ymax, zmin, zmax),)*
   **|** ...more\
   Specify the region of interest. Default limits are computed from data extents. More at [limits](@ref)


## build time series

```julia
using GMT
gmtbegin()
plot(t,ap)
gmtend()
```