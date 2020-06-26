#= = # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   This file contains helpers related to space indices.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # = =#
# struct SPI{T} end # TODO 
const SPI = Val
# import Base.length
for sym in [:F10, :F10obs, :F10adj, :F10M, :F10Mobs, :F10Madj,
            :Kp, :Ap, :Kp_vect, :Ap_vect,
            :Dst, :Dst_vect,
            :S10, :S81a, :M10, :M81a, :Y10, :Y81a, :DstΔTc]

    qsym = Meta.quot(sym)

    @eval begin
        export $sym
        $sym() = SPI{$qsym}()
        # MethodError: no method matching length(::HTsi.SPI
        # length(x::SPI{$qsym}) = 1
        # MethodError: no method matching iterate(::HTsi.SPI{:F10obs})
        # iterate(x::SPI{$qsym}) = x
    end
end
