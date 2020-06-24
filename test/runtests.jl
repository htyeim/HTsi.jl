using HTsi
using Test
using Dates
using Plots
using RemoteFiles
gr()
Plots.GRBackend()


@testset "HTsi.jl" begin
    # Write your own tests here.
    enabled_files = nothing

    fluxtable_force_download = false
    dtcfile_force_download = false
    solfsmy_force_download = false
    wdcfiles_force_download = false
    wdcfiles_oldest_year = 2000
    wdcfiles_newest_year = year(now()) - 1

    fluxtable_path = nothing
    dtcfile_path = nothing
    solfsmy_path = nothing
    wdcfiles_dir = nothing
    
    fluxtable_path = path(HTsi._fluxtable)
    dtcfile_path = path(HTsi._dtcfile)
    solfsmy_path = path(HTsi._solfsmy)
    wdcfiles_dir = nothing
    
    dtcfile   = (enabled_files == nothing) || (:dtcfile in enabled_files)
    fluxtable = (enabled_files == nothing) || (:fluxtable in enabled_files)
    solfsmy   = (enabled_files == nothing) || (:solfsmy in enabled_files)
    wdcfiles  = (enabled_files == nothing) || (:wdcfiles in enabled_files)

    dtcfile && HTsi._init_dtcfile(local_path=dtcfile_path,
                             force_download=dtcfile_force_download)

    fluxtable && HTsi._init_fluxtable(local_path=fluxtable_path,
                                 force_download=fluxtable_force_download)

    solfsmy && HTsi._init_solfsmy(local_path=solfsmy_path,
                             force_download=solfsmy_force_download)

    wdcfiles && HTsi._init_wdcfiles( force_download=wdcfiles_force_download,
                               wdcfiles_oldest_year=wdcfiles_oldest_year,
                               wdcfiles_newest_year=wdcfiles_newest_year)

    dts = DateTime(2015, ):Day(1):DateTime(2005, 1, 2, )
    dts = [DateTime(2015, 4, 25, 6, 11, 25),]
    data = get_Ap.(dts)
    @show data
    # plot(dts, data, label = "Kp")
    println(data)
    data = get_space_index.(F10(), datetime2julian.(dts))
    @show data
    data = get_space_index.(F10M(), datetime2julian.(dts))
    @show data
    
    #= 
    data = get_space_index.(F10(), datetime2julian.(dts))
    plot(dts, data, label = "F10")
    # vF10obs  = get_space_index(F10obs(), JD)
    # vF10Madj = get_space_index(F10M(), JD; window = 90)
    # vF10Mobs = get_space_index(F10Mobs(), JD)
   
    data = get_space_index.(F10obs(), datetime2julian.(dts))
    plot!(dts, data, label = "F10obs")

    data = get_space_index.(F10M(), datetime2julian.(dts))
    plot!(dts, data, label = "F10M")

    data = get_space_index.(F10Mobs(), datetime2julian.(dts))
    plot!(dts, data, label = "F10Mobs") =#
    
end
