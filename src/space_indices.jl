#
#= = # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   This file contains functions to retrieve space indices for many models.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # = =#

export get_space_index, init_space_indices

# Interpolation types used in space indices.
_space_indices_itp_constant{T} =
    Interpolations.GriddedInterpolation{T,1,T,Gridded{Interpolations.Constant{Interpolations.Nearest}},Tuple{Array{Float64,1}}}

_space_indices_itp_linear{T} =
    Interpolations.GriddedInterpolation{T,1,T,Gridded{Linear},Tuple{Array{Float64,1}}}

include("./dtcfile.jl")
include("./fluxtable.jl")
include("./solfsmy.jl")
include("./wdcfiles.jl")
include("./dstfiles.jl")
include("./space_indices_helpers.jl")

################################################################################
#                                Private Macros
################################################################################

macro _check_data(itp, DT)
    quote
        if ($(esc(DT)) < $(esc(itp)).knots[1][1]) ||
           ($(esc(DT)) > $(esc(itp)).knots[1][end])
            error("The data for the requested Julian Day is not available!")
        end
    end
end

################################################################################
#                               Public Functions
################################################################################

"""
    get_space_index(T, DT::Number; ...)

Return the space index `T` at the day `DT` [Julian Day]. `T` can be:

## Daily 10.7-cm solar flux

The daily 10.7-cm solar flux can be obtained using:

* `F10()`: 10.7-cm adjusted solar flux \\[10⁻²² W/(M² Hz)].
* `F10adj()`: 10.7-cm adjusted solar flux \\[10⁻²² W/(M² Hz)].
* `F10obs()`: 10.7-cm observed solar flux \\[10⁻²² W/(M² Hz)].

These indices require `fluxtable` (see `init_space_indices`).

## Daily average 10.7-cm solar flux

The daily average 10.7-cm solar flux, centered at `DT`, can be obtained using:

* `F10M()`: 10.7-cm adjusted solar flux \\[10⁻²² W/(M² Hz)].
* `F10Madj()`: 10.7-cm adjusted solar flux \\[10⁻²² W/(M² Hz)].
* `F10Mobs()`: 10.7-cm observed solar flux \\[10⁻²² W/(M² Hz)].

In this case, the keyword `window::Int` can be passed to select the size of the
window. By default, it is selected as 81.

These indices require `fluxtable` (see `init_space_indices`).

# Daily Kp and Ap

* `Kp()`: Kp index (daily mean).
* `Kp_vect()`: A vector containing the Kp index for the following hours of the
               day: 0-3h, 3-6h, 6-9h, 9-12h, 12-15h, 15-18h, 18-20h, 20-23h.
* `Ap()`: Ap index (daily mean).
* `Ap_vect()`: A vector containing the Ap index for the following hours of the
               day: 0-3h, 3-6h, 6-9h, 9-12h, 12-15h, 15-18h, 18-20h, 20-23h.

These indices require `wdcfiles` (see `init_space_indices`).

# Daily S10, M10, and Y10

* `S10()`: EUV index (26-34 nm) scaled to F10.7.
* `M10()`: MG2 index scaled to F10.7.
* `Y10()`: Solar X-ray & Lya index scaled to F10.7.

These indices require `solfsmy` (see `init_space_indices`).

# 81-day centered average of S10, M10, and Y10.

* `S81a`: EUV 81-day averaged centered index.
* `M81a`: MG2 81-day averaged centered index.
* `Y81a`: Solar X-ray & Lya 81-day averaged centered index.

These indices require `solfsmy` (see `init_space_indices`).

# Exospheric temperature variation due to Dst

* `DstΔTc`: Exospheric temperature variation due to `Dst` [K].

This index requires `dtcfile` (see `init_space_indices`).

"""
@inline get_space_index(::SPI{:F10}, DT::Number) =
    get_space_index(Val(:F10adj), DT)

@inline function get_space_index(::SPI{:F10obs}, DT::Number)
    @_check_data(get(_fluxtable_data).F10obs, DT)
get(_fluxtable_data).F10obs(DT)
end

@inline function get_space_index(::SPI{:F10adj}, DT::Number)
    @_check_data(get(_fluxtable_data).F10adj, DT)
get(_fluxtable_data).F10adj(DT)
end

@inline get_space_index(::SPI{:F10M}, DT::Number; window::Int=81) =
    get_space_index(Val(:F10Madj), DT; window=window)

@inline function get_space_index(::SPI{:F10Mobs}, DT::Number; window::Int=81)
    Δ = floor(Int, (window - 1) / 2)
    @_check_data(get(_fluxtable_data).F10obs, DT - Δ)
    @_check_data(get(_fluxtable_data).F10obs, DT + Δ)
    mean(get(_fluxtable_data).F10obs(DT - Δ:1:DT + Δ))
end

@inline function get_space_index(::SPI{:F10Madj}, DT::Number; window::Int=81)
    Δ = floor(Int, (window - 1) / 2)
    @_check_data(get(_fluxtable_data).F10adj, DT - Δ)
    @_check_data(get(_fluxtable_data).F10adj, DT + Δ)
    mean(get(_fluxtable_data).F10adj(DT - Δ:1:DT + Δ))
end

@inline function get_space_index(::SPI{:Kp_vect}, DT::Number)
    @_check_data(get(_wdc_data).Kp, DT)
    get(_wdc_data).Kp(DT)
end

@inline function get_space_index(::SPI{:Ap_vect}, DT::Number)
    @_check_data(get(_wdc_data).Ap, DT)
    get(_wdc_data).Ap(DT)
end

@inline get_space_index(::SPI{:Kp}, DT::Number) =
    mean(get_space_index(Val(:Kp_vect), DT))

@inline get_space_index(::SPI{:Ap}, DT::Number) =
    mean(get_space_index(Val(:Ap_vect), DT))


@inline function get_space_index(::SPI{:Dst_vect}, DT::Number)
    @_check_data(get(_dst_data).Dst, DT)
    get(_dst_data).Dst(DT)
end

@inline get_space_index(::SPI{:Dst}, DT::Number) =
    mean(get_space_index(Val(:Dst_vect), DT))


@inline function get_space_index(::SPI{:S10}, DT::Number)
    @_check_data(get(_solfsmy_data).S10, DT)
    get(_solfsmy_data).S10(DT)
end

@inline function get_space_index(::SPI{:S81a}, DT::Number)
    @_check_data(get(_solfsmy_data).S81a, DT)
    get(_solfsmy_data).S81a(DT)
end

@inline function get_space_index(::SPI{:M10}, DT::Number)
    @_check_data(get(_solfsmy_data).M10, DT)
    get(_solfsmy_data).M10(DT)
end

@inline function get_space_index(::SPI{:M81a}, DT::Number)
    @_check_data(get(_solfsmy_data).M81a, DT)
    get(_solfsmy_data).M81a(DT)
end

@inline function get_space_index(::SPI{:Y10}, DT::Number)
    @_check_data(get(_solfsmy_data).Y10, DT)
    get(_solfsmy_data).Y10(DT)
end

@inline function get_space_index(::SPI{:Y81a}, DT::Number)
    @_check_data(get(_solfsmy_data).Y81a, DT)
    get(_solfsmy_data).Y81a(DT)
end

@inline function get_space_index(::SPI{:DstΔTc}, DT::Number)
    @_check_data(get(_dtcfile_data).DstΔTc, DT)
    get(_dtcfile_data).DstΔTc(DT)
end

"""
    init_space_indices(...)

Initialize all space indices. The files that will be initialized must be
indicated by the array of symbols passed to the keyword argument
`enabled_files`. If this is `nothing`, which is the default, then all files will
be initialized. The symbol related to each file is described next.

Notice that the initialization process can be changed by a set of keywords as
described next.

## DTCFILE

**Symbol**: `:dtcfile`

This file contains the exospheric temperature variation caused by the Dst index.
This is used for the JB2008 atmospheric model.

### Keywords

* `dtcfile_path`: Path for the file `DTCFILE.TXT`. If `nothing`, then it will be
                  downloaded. (**Default** = `nothing`)
* `dtcfile_force_download`: If `true`, then the file will always be downloaded
                            if the path is not specified. (**Default** =
                            `false`).

## fluxtable

**Symbol**: `:fluxtable`

This file contains the F10.7 flux data in different formats.

### Keywords

* `fluxtable_path`: Path for the file `fluxtable.txt`. If `nothing`, then it
                    will be downloaded. (**Default** = `nothing`)
* `fluxtable_force_download`: If `true`, then the file will always be downloaded
                              if the path is not specified.
                              (**Default** = `false`).

## SOLFSMY

**Symbol**: `:solfsmy`

This files contains the indices necessary for the JB2008 atmospheric model.

### Keywords

* `solfsmy_path`: Path for the file `SOLFSMY.TXT`. If `nothing`, then it will be
                  downloaded. (**Default** = `nothing`)
* `solfsmy_force_download`: If `true`, then the file will always be downloaded
                            if the path is not specified. (**Default** =
                            `false`).

## WDC Files

**Symbol**: `:wdcfiles`

This set of files contain the Kp and Ap indices.

### Keywords

* `wdcfiles_path`: Path for the directory with the WDC files. If `nothing`, then
                   they will be downloaded. (**Default** = `nothing`)
* `wdcfiles_force_download`: If `true`, then the files will always be downloaded
                            if the path is not specified. (**Default** =
                            `false`).
* `wdcfiles_oldest_year`: Oldest year in which the WDC file will be obtained.
                          (**Default** = past 3 years).
* `wdcfiles_newest_year`: Newest year in which the WDC file will be obtained. If
                          it is `nothing`, then it defaults to the current year.
                          (**Default** = `nothing`).

"""
function init_space_indices(;
            enabled_files=nothing,
            dtcfile_path=nothing,
            dtcfile_force_download=false,

            fluxtable_path=nothing,
            fluxtable_force_download=false,

            solfsmy_path=nothing,
            solfsmy_force_download=false,

            wdcfiles_dir=nothing,
            wdcfiles_force_download=false,
            wdcfiles_oldest_year=year(now()) - 3,
            wdcfiles_newest_year=nothing,

            dstfiles_dir=nothing,
            dstfiles_force_download=false,
            dstfiles_oldest_year=year(now()) - 3,
            dstfiles_newest_year=nothing
        )
    dtcfile   = (enabled_files == nothing) || (:dtcfile in enabled_files)
    fluxtable = (enabled_files == nothing) || (:fluxtable in enabled_files)
    solfsmy   = (enabled_files == nothing) || (:solfsmy in enabled_files)
    wdcfiles  = (enabled_files == nothing) || (:wdcfiles in enabled_files)
    dstfiles  = (enabled_files == nothing) || (:dstfiles in enabled_files)

    dtcfile && _init_dtcfile(local_path=dtcfile_path,
                            force_download=dtcfile_force_download)

    fluxtable && _init_fluxtable(local_path=fluxtable_path,
                                force_download=fluxtable_force_download)

    solfsmy && _init_solfsmy(local_path=solfsmy_path,
                            force_download=solfsmy_force_download)

    wdcfiles && _init_wdcfiles(local_dir=wdcfiles_dir,
                            force_download=wdcfiles_force_download,
                            wdcfiles_oldest_year=wdcfiles_oldest_year,
                            wdcfiles_newest_year=wdcfiles_newest_year)

    dstfiles && _init_dstfiles(local_dir=dstfiles_dir,
                            force_download=dstfiles_force_download,
                            dstfiles_oldest_year=dstfiles_oldest_year,
                            dstfiles_newest_year=dstfiles_newest_year)

    nothing
end
