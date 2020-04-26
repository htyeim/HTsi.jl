using HTsi
using Test
using Dates


function DatetoJD(Y::Int, M::Int, D::Int, h::Int, m::Int, s::Number)
    # Check the input.
    ( (M < 1) || (M > 12) ) && throw(ArgumentError("Invalid month. It must be an integer between 1 and 12."))
    ( (D < 1) || (D > 31) ) && throw(ArgumentError("Invalid day. It must be an integer between 1 and 31."))
    ( (h < 0) || (h > 23) ) && throw(ArgumentError("Invalid hour. It must be an integer between 0 and 23."))
    ( (m < 0) || (m > 59) ) && throw(ArgumentError("Invalid minute. It must be an integer between 0 and 59."))
    ( (s < 0) || (s > 60) ) && throw(ArgumentError("Invalid second. It must be an integer between 0 and 60."))

    # Check if the date is valid in terms of number of days in a month.
    if M == 2
        if is_leap_year(Y)
            (D > 29) && throw(ArgumentError("Wrong day number given the year and the month."))
        else
            (D > 28) && throw(ArgumentError("Wrong day number given the year and the month."))
        end
    elseif M in [4, 6, 9, 11]
        (D > 30) && throw(ArgumentError("Wrong day number given the year and the month."))
    end

    # If the month is January / February, then consider it as the 13rd / 14th
    # month of the last year.
    if (M == 1) || (M == 2)
        Y -= 1
        M += 12
    end

    a = div(Y, 100)
    b = div(a, 4)
    c = 2 - a + b
    e = floor(Int, 365.25 * (Y + 4716))
    f = floor(Int, 30.6001 * (M + 1))

    # Compute the Julian Day considering the time of day.
    #
    # Notice that the algorithm in [2] always return the Julian day at 00:00
    # GMT.
    c + D + e + f - 1524.5 + ((h * 60 + m) * 60 + s) / 86400
end


@testset "HTsi.jl" begin
    # Write your own tests here.
    enabled_files = nothing

    fluxtable_force_download = false
    dtcfile_force_download = false
    solfsmy_force_download = false
    wdcfiles_force_download = false
    wdcfiles_oldest_year = 2010
    wdcfiles_newest_year = year(now()) - 1

    fluxtable_path = nothing
    dtcfile_path = nothing
    solfsmy_path = nothing
    wdcfiles_dir = nothing
    
    dtcfile   = (enabled_files == nothing) || (:dtcfile in enabled_files)
    fluxtable = (enabled_files == nothing) || (:fluxtable in enabled_files)
    solfsmy   = (enabled_files == nothing) || (:solfsmy in enabled_files)
    wdcfiles  = (enabled_files == nothing) || (:wdcfiles in enabled_files)

    dtcfile && HTsi._init_dtcfile(local_path = dtcfile_path,
                             force_download = dtcfile_force_download)

    fluxtable && HTsi._init_fluxtable(local_path = fluxtable_path,
                                 force_download = fluxtable_force_download)

    solfsmy && HTsi._init_solfsmy(local_path = solfsmy_path,
                             force_download = solfsmy_force_download)

    wdcfiles && HTsi._init_wdcfiles( force_download = wdcfiles_force_download,
                               wdcfiles_oldest_year = wdcfiles_oldest_year,
                               wdcfiles_newest_year = wdcfiles_newest_year)


    JD       = datetime2julian(DateTime(2017, 10, 19, 6, 30, 0))
    JD1       = DatetoJD(2017, 10, 19, 6, 30, 0)

    @show JD
    @show JD1
    @show JD - JD1
    vF10adj  = get_space_index(F10(), JD)
    vF10obs  = get_space_index(F10obs(), JD)
    vF10Madj = get_space_index(F10M(), JD; window = 90)
    vF10Mobs = get_space_index(F10Mobs(), JD)
    vS10     = get_space_index(S10(), JD)
    vS81a    = get_space_index(S81a(), JD)
    vM10     = get_space_index(M10(), JD)
    vM81a    = get_space_index(M81a(), JD)
    vY10     = get_space_index(Y10(), JD)
    vY81a    = get_space_index(Y81a(), JD)
    vDstΔTc  = get_space_index(DstΔTc(), JD)

    # Test.
    @test vF10obs  ≈ 73.4 atol = 1e-2
    @test vF10adj  ≈ 72.8 atol = 1e-2
    @test vF10Mobs ≈ 76.5 atol = 1e-2
    # TODO: The adjusted mean is not exatcly what the online NRLMSISE00 is
    # computing.
    # @test vF10Madj ≈ 77.8 atol = 5e-1
    # @test vS10     ≈ 63.6 atol = 1e-2
    # @test vS81a    ≈ 64.9 atol = 1e-2
    # @test vM10     ≈ 72.7 atol = 1e-2
    # @test vM81a    ≈ 78.4 atol = 1e-2
    # @test vY10     ≈ 82.4 atol = 1e-2
    # @test vY81a    ≈ 83.6 atol = 1e-2
end
