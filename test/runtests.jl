using HTsi
using Test
using Dates
using GMT
using RemoteFiles
using Printf



gmtrdt(dt) = Dates.format(dt, "yyyy-mm-ddTHH:MM:SS")

function plot_data(dts, data, fn="test")
    uts = datetime2unix.(dts)
    region = (gmtrdt(dts[1]), gmtrdt(dts[end]),
                minimum(data), maximum(data),)
    plot(uts, data,
        region=region,
        frame=(axes = :WSen,),
        xaxis=(annot = :auto, ticks = :auto),
        yaxis=(annot = :auto, ticks = :auto),
        fmt=:png,
        savefig=fn,
    )

end

function test_flux(enabled_files, dts)
    @testset "HTsi.jl fluxtable" begin
        force_download = false
        the_path = nothing

        the_path = path(HTsi._fluxtable)
        fluxtable = (enabled_files == nothing) || (:fluxtable in enabled_files)
        fluxtable && HTsi._init_fluxtable(local_path=the_path,
                                force_download=force_download)
        
        jds = datetime2julian.(dts)
        data = get_space_index.(F10obs(), jds)

        plot_data(dts, data, "test_flux")
    end
end


function test_dtcfile(enabled_files, dts)
    @testset "HTsi.jl dtcfile" begin

        force_download = false
        the_path = nothing

        # the_path = path(HTsi._dtcfile)
        dtcfile   = (enabled_files == nothing) || (:dtcfile in enabled_files)
        dtcfile && HTsi._init_dtcfile(local_path=the_path,
                            force_download=force_download)

        jds = datetime2julian.(dts)
        data = get_DstΔTc.(jds)

        plot_data(dts, data, "test_dtc")
    end
end


function test_solfsmy(enabled_files, dts)
    @testset "HTsi.jl solfsmy" begin

        force_download = false
        the_path = nothing

        # the_path = path(HTsi._solfsmy)
        solfsmy   = (enabled_files == nothing) || (:solfsmy in enabled_files)
        solfsmy && HTsi._init_solfsmy(local_path=the_path,
                            force_download=force_download)

        jds = datetime2julian.(dts)
        data = get_space_index.(S10(), jds)

        plot_data(dts, data, "test_solf")
    end
end

function test_wdcfiles(enabled_files, dts)
    @testset "HTsi.jl wdcfiles Kp Ap" begin

        force_download = false

        wdcfiles_oldest_year = 2000
        wdcfiles_newest_year = year(now()) - 1

        wdcfiles_dir = nothing

        wdcfiles  = (enabled_files == nothing) || (:wdcfiles in enabled_files)
        wdcfiles && HTsi._init_wdcfiles( force_download=force_download,
                            wdcfiles_oldest_year=wdcfiles_oldest_year,
                            wdcfiles_newest_year=wdcfiles_newest_year)

        # jds = datetime2julian.(dts)
        data = get_Kp.(dts)
        plot_data(dts, data, "test_wdc_kp")

    end
end


function test_dstfiles(enabled_files, dts)
    @testset "HTsi.jl dstfiles" begin
        force_download = false

        dstfiles_oldest_year = 2000
        dstfiles_newest_year = year(now()) - 1
        # dstfiles_newest_year = 2010
        # dts = DateTime(2010, ):Hour(1):DateTime(2010, 12)

        dstfiles_dir = nothing

        dstfiles  = (enabled_files == nothing) || (:wdcfiles in enabled_files)
        dstfiles && HTsi._init_dstfiles( force_download=force_download,
                            dstfiles_oldest_year=dstfiles_oldest_year,
                            dstfiles_newest_year=dstfiles_newest_year)

        # jds = datetime2julian.(dts)
        # data = get_space_index.(Dst(), jds)

        data = get_Dst.(dts)
        plot_data(dts, data, "test_dst")
    end
end

function test()
    dts = DateTime(2005, ):Day(1):DateTime(2019, )
    # dts = [DateTime(2015, 4, 25, 6, 11, 25),]
    enabled_files = nothing

    test_flux(enabled_files, dts)
    test_dtcfile(enabled_files, dts)
    test_solfsmy(enabled_files, dts)
    test_wdcfiles(enabled_files, dts)
    test_dstfiles(enabled_files, dts)

end
test()