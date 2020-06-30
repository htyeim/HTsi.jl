#= = # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Dst Index
#
#   World Data Center for Geomagnetism
#
#   For more information, see:
#
#       http://dx.doi.org/10.17593/14515-74000
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # = =#

################################################################################
#                       Private Structures and Variables
################################################################################

"""
_Dst_Structure

Structure to store the interpolations of the data in Dst files.

# Fields

* `Dst`: Dst index.

"""
struct _Dst_Structure
    Dst::_space_indices_itp_constant{SVector{24,Float64}}
end

# Remote files: *.html (prefered) or for.request (some months are missed)
#
# This set will be configured in the function `init_space_indices()`.
_dstfiles = RemoteFileSet(".dst files",
                    Dict{Symbol,RemoteFile}(), 
                )

# Optional variable that will store the WDC data.
@OptionalData(_dst_data, _Dst_Structure,
          "Run `init_space_indices()` with `:dstfiles` in `enabled_files` array to initialize required data.")

################################################################################
#                               Public Functions
################################################################################

export get_Dst

#                                   Getters
# ==============================================================================

"""
get_Dst(DT::DateTime)

Return the Kp index at DateTime `DT`.

"""
function get_Dst(DT::DateTime)
    # @show DT
    Dst_day = get(_dst_data).Dst(datetime2julian(DT))
    # @show Kp_day
    # Get the hour of the day and return the appropriate Kp.
    # y, m, d, h, min, sec = JDtoDate(DT)
    # @show  floor(Int, h / 3)
    # @show Kp_day[ floor(Int, hour(DT) / 3) + 1 ]
    return Dst_day[  hour(DT) + 1 ]
end


################################################################################
#                              Private Functions
################################################################################

"""
_init_dstfiles(;force_download = false, local_dir = nothing, dstfiles_oldest_year = year(now())-3)

Initialize the data in the WDC files by creating `_dstfiles_data`. The
initialization process is composed of:

1. Download the files, if it is necessary;
2. Parse the files;
3. Create the interpolations and the structures.

If the keyword `force_download` is `true`, then the files will always be
downloaded.

The user can also specify a location for the directory with the WDC files using
the keyword `local_dir`. If it is `nothing`, which is the default, then the
file will be downloaded.

The user can select what is the oldest year in which the data will be downloaded
by the keyword `dstfiles_oldest_year`. By default, it will download the data
from 3 previous years.

The user can select what is the newest year in which the data will be downloaded
by the keyword `dstfiles_newest_year`. It it is `nothing`, which is the default,
then it is set to the current year.

"""
function _init_dstfiles(;force_download=false, local_dir=nothing,
                    dstfiles_oldest_year=year(now()) - 3,
                    dstfiles_newest_year=nothing)

    yms     = Int[]
    filepaths = String[]

    if local_dir == nothing
        local_dir = joinpath(path_si_root, "dst")
        isdir(local_dir) || mkpath(local_dir)
        (dstfiles_newest_year == nothing) && (dstfiles_newest_year = year(now()))
        _prepare_dst_remote_files(dstfiles_oldest_year, dstfiles_newest_year, local_dir)
        download(_dstfiles; force=force_download,)

        # Get the files available and sort them by the year.
        for (sym, dstfile) in _dstfiles.files
            #
            # The year must not be obtained by the data inside the file,
            # because it contains only 2 digits and will break in 2032.
            # We will obtain the year by the symbol of the remote file. The
            # symbol name is:
            #
            #       kpYYYY
            #
            # where `YYYY` is the year.
            push!(yms, parse(Int, String(sym)[4:9]))
            push!(filepaths, path(dstfile))
        end
    else
    # If the user provided a directory, check what files are available.
    # Notice that the name must be the same as the ones online.
        for (root, dirs, files) in walkdir(local_dir)
            for file in files
                if occursin(r"^dst[1-2][0-9][0-9][0-9].for.request$", file) ||
                    occursin(r"^dst[1-2][0-9][0-9][0-9].html$", file)
                    year = parse(Int, file[4:7])
                    # Check if the year is not older than the oldest year.
                    if year >= dstfiles_oldest_year
                        @info "Found Dst file `$file` related to the year `$year`."
                        push!(filepaths, joinpath(root, file))
                        push!(yms,     file[4:9])
                    end
                end
            end
        end
    end

    p = sortperm(yms)

    push!(_dst_data,       _parse_dstfiles(filepaths[p]))

    nothing
end

"""
_parse_dstfiles(filepaths::Vector{String}, years::Vector{Int})

Parse the Dst files with paths in `filepaths` related to the years in `years`.

**Notice that the files must be sorted by the year!**

"""
function _parse_dstfile_html_line(ln::SubString)
    Dst_k = zeros(Float64, 24)
    for i in 1:3
        for j in 1:8
            k = i * 8 - 8 + j
            Dst_k[k] = parse(Int, ln[ i - 1 + k * 4:i - 1 + 3 + k * 4])
        end
    end
    Dst_k
end

function _parse_dstfile_html(filepath::String,
                            DT::Vector{DateTime},
                            Dst::Vector{SVector{24,Float64}})

    bn = basename(filepath)
    y = parse(Int, bn[4:7])
    m = parse(Int, bn[8:9])

    open(filepath, "r") do file
        text = read(file, String)
        a = r"""<pre class="data">\n((.|\n)+?)\n</pre>"""
        b = match(a, text)
        if b == nothing
            @warn "no match " * filepath
            return
        end

        alllines = split(b.captures[1], "\n")
        # utline = alllines[6]
        lines = alllines[8:end - 1]
        filter!(!isempty, lines)


        for ln in lines
            d   = parse(Int, ln[1:2])
            DT_k  = DateTime(y, m, d, 12, 0, 0)

            # Get the vector of Dst
            Dst_k = _parse_dstfile_html_line(ln)
            # Add data to the vector.
            push!(DT, DT_k)
            push!(Dst, Dst_k)
        end
    end

end

function _parse_dstfile_forrequest(filepath::String,
                                DT::Vector{DateTime},
                                Dst::Vector{SVector{24,Float64}})

    bn = basename(filepath)
    y  = parse(Int, bn[4:7])
    m  = parse(Int, bn[8:9])

    open(filepath, "r") do file

        for ln in eachline(file)
            # Get the Julian Day.
            d   = parse(Int, ln[9:10])

            # The DT of the data will be computed at noon. Hence, we will be
            # able to use the nearest-neighbor algorithm in the
            # interpolations.
            DT_k  = DateTime(y, m, d, 12, 0, 0)

            # Get the vector of Kps and Aps.
            Dst_k = zeros(Float64, 24)

            for i = 1:24
                Dst_k[i] = parse(Int, ln[17 + i * 4:20 + i * 4])
            end

            # Add data to the vector.
            push!(DT, DT_k)
            push!(Dst, Dst_k)
        end
    end
end

function _parse_dstfiles(filepaths::Vector{String}, )
    # Allocate the raw data.    
    DT = DateTime[]
    Dst = SVector{24,Float64}[]

    for filepath in filepaths
        if endswith(filepath, "html")
            
            _parse_dstfile_html(filepath, DT, Dst)
        elseif endswith(filepath, "for.request")
            _parse_dstfile_forrequest(filepath, DT, Dst)
        else
            @warn "can't recognise filetype " * filepath
        end
    end

    # Create the interpolations for each parameter.
    knots    = (datetime2julian.(DT),)
    # Create the interpolations.
    itp_Dst = interpolate(knots, Dst, Gridded(Constant()))
    _Dst_Structure(itp_Dst)
end


"""
_prepare_dst_remote_files(oldest_year::Number, newest_year::Number)

Configure all the WDC remote files between `newest_year` and `oldest_year`.
Notice that previous years will never be updated whereas the current year will
be updated daily.

If `oldest_year` is greater than current year, then only the files from the
current year will be downloaded.

If `newest_year` is smaller than `oldest_year`, then only the files from the
`oldest_year` will be downloaded.

This function modifies the global variable `_wdcfiles`.

"""

function _prepare_dst_remote_files(oldest_year::Number, newest_year::Number, local_dir::String)
    # Get the current year.
    current_year = year(now())

    # If `oldest_year` is greater than current year, then consider only the
    # current year.
    (oldest_year > current_year) && (oldest_year = current_year)
    (newest_year < oldest_year)  && (newest_year = oldest_year)
    (newest_year > current_year) && (newest_year = current_year)

    # For the current year, we must update the remote file every day. Otherwise,
    # we do not need to update at all.

    # http://wdc.kugi.kyoto-u.ac.jp/dst_final/199412/index.html
    baseurl = "http://wdc.kugi.kyoto-u.ac.jp/"
    # end_time => dst type
    url_prefix = [
            DateTime(2014, 12, 31, 23, 59, 59) => "dst_final",
            DateTime(2016, 12, 31, 23, 59, 59) => "dst_provisional",
            now() => "dst_realtime",
        ]

    yms = Date(oldest_year):Month(1):Date(newest_year + 1) - Day(1)
    start_index = 1
    for ym in yms
        ymstr = @sprintf("%04d%02d",year(ym),month(ym))
        forrequest = string("dst", 
                        @sprintf("%02d%02d",
                                    year(ym) % 100,
                                    month(ym)),
                        ".for.request",
                )
        httpindex = "index.html"
        # use html (for.request files are missed in some months)
        fileremote = httpindex 
        
        filename = string("dst", ymstr, ".html")
        sym = Symbol(filename)
        for (idt, isp) in url_prefix[start_index:end]
            if ym > idt
                start_index += 1
                continue
            end
            file_y = @RemoteFile(
                    string(baseurl, isp, "/", ymstr, "/", fileremote),
                    file = filename, dir = joinpath(local_dir, isp),
                    updates = (isp == "dst_final") ? :never : :yearly,
                )
            merge!(_dstfiles.files, Dict(sym => file_y))
            break
        end
    end
    nothing
end
