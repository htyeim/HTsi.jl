
function get_si_root(k::String)
    file_to = joinpath(homedir(), ".juliaHTsetting.json")
    settings = Dict{String,Any}()
    if isfile(file_to)
        settings = JSON.parsefile(file_to)
    end
    if haskey(settings, k)
        p = settings[k]
    else
        p =  Sys.isapple() ?
                "/Users/t/Data/ROOT_FOLDER/space_indices/" :
                "/Users/t/Data/ROOT_FOLDER/RINEX_rmjl/"
        settings[k] = p
        open(file_to, "w") do f
            JSON.print(f, settings)
        end
    end
    if isdir(p) return p
    else throw(error("please modify $k in $file_to to your rinex_root path!"))
    end
end

const path_si_root = get_si_root("space_indices")

