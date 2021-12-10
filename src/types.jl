const Tms = typeof(1.0f0*ms)

"""
    CellsTrial(t, dFoF)

Store cellular responses for a single trial. `t` is the list of frame times (in units of time, see Unitful.jl) and
`dFoF` is a matrix with one row for each time in `t`, and one column per cell.

# Examples

```jldoctest demo; setup=:(using EcoTrialStructure)
julia> dFoF = [ 0.1 0.8;
               -0.1 0.7;
                0.2 0.6;
                0.1 0.5;
                0.0 0.4];

julia> ct = CellsTrial((100:100:500) * ms, dFoF)
2 cells with 5 timepoints
```

It's straightforward to extract the dFoF values over a particular time interval:

```jldoctest demo
julia> tframes, df = ct[175ms..310ms, :];  # frames range nearest to given start..stop times

julia> tframes
200.0f0 ms..300.0f0 ms

julia> df
2×2 Matrix{Float64}:
 -0.1  0.7
  0.2  0.6
```
This extracted the `dFoF` values recorded between 200ms and 300ms, inclusive.

In other cases, you might want a specific number of frames, starting at a particular time:

```jldoctest demo
julia> tframes, df = ct[FrameSeq(175ms, 3), :];  # start nearest to 175ms, and grab 3 frames' worth

julia> tframes
200.0f0 ms..400.0f0 ms

julia> df
3×2 Matrix{Float64}:
 -0.1  0.7
  0.2  0.6
  0.1  0.5
```
"""
struct CellsTrial{T<:AbstractFloat}
    t::Vector{Tms}
    dFoF::Matrix{T}

    function CellsTrial{T}(t, dFoF) where T
        issorted(t) || throw(ArgumentError("frame times must be increasing"))
        axes(dFoF, 1) == axes(t, 1) || throw(DimensionMismatch("frame times and dFoF must match, got sizes $(length(t)) and $(size(dFoF))"))
        return new{T}(t, dFoF)
    end
end
CellsTrial(t, dFoF::AbstractMatrix{T}) where T<:AbstractFloat = CellsTrial{T}(t, dFoF)
CellsTrial(t, dFoF::AbstractMatrix) = CellsTrial{Float64}(t, dFoF)

Base.:(==)(a::CellsTrial, b::CellsTrial) = a.t == b.t && a.dFoF == b.dFoF
Base.isequal(a::CellsTrial, b::CellsTrial) = isequal(a.t, b.t) && isequal(a.dFoF, b.dFoF)

const hash_seed_CellsTrial = Int === Int64 ? 0x80450cff5158f34c : 0xbcdbf5e0
Base.hash(ct::CellsTrial, h::UInt) = hash(hash_seed_CellsTrial, hash(ct.t, hash(ct.dFoF, h)))

Base.show(io::IO, ct::CellsTrial) = print(io, size(ct.dFoF, 2), " cells with ", length(ct.t), " timepoints")

# indexing (primarily, selecting frames based on time)

Base.getindex(ct::CellsTrial, ti::Union{Colon,AbstractVector{<:Integer}}, ci) = (ct.t[ti], ct.dFoF[ti, ci])

function Base.getindex(ct::CellsTrial, ti::AbstractInterval, ci)
    ibegin, iend = idxof(ct.t, minimum(ti)), idxof(ct.t, maximum(ti))
    return ct.t[ibegin] .. ct.t[iend], ct.dFoF[ibegin:iend, ci]
end

"""
    FrameSeq(tstart, nframes)
    FrameSeq(eventfield::Symbol, nframes)

A sequence of `nframes` frames starting at the nearest timepoint to `tstart`.
See [`CellsTrial`](@ref) for an example using this in indexing.

Alternatively, this can be constructed specifying a particular fieldname of [`EventTiming`](@ref),
in which case the concrete timing can be deferred until a later time based on a specific
trial:

```jldoctest; setup=:(using EcoTrialStructure)
julia> fs = FrameSeq(:go, 5)
FrameSeq(:go, 5)

julia> et = EventTiming(0ms, 100ms, 400ms, 450ms, 837ms, 1.2s)
EventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)

julia> fs(et)
FrameSeq(450.0f0 ms, 5)
```
"""
struct FrameSeq
    start::Union{Tms,Symbol}
    len::Int
end
FrameSeq(start::Unitful.Quantity, len::Integer) = FrameSeq(Tms(start), len)

function Base.getindex(ct::CellsTrial, ti::FrameSeq, ci)
    isdeferred(ti) && throw(ArgumentError("indexing requires a concrete `FrameSeq`, use `fs(et::EventTiming)`"))
    ibegin = idxof(ct.t, ti.start)
    iend = ibegin + ti.len - 1
    return ct.t[ibegin] .. ct.t[iend], ct.dFoF[ibegin:iend, ci]
end


"""
    TrialType(nA, nB, leftA::Bool)

Encode the offers (`nA` and `nB` are the number of drops of A and B, respectively),
and whether A was on the left.
"""
struct TrialType
    nA::Int8
    nB::Int8
    leftA::Bool
end

# This constructor makes it possible to copy/paste the output of the `show` method below
TrialType(; nA, nB, leftA) = TrialType(nA, nB, leftA)

Base.show(io::IO, tt::TrialType) = print(io, "TrialType(nA=", tt.nA, ", nB=", tt.nB, ", leftA=", tt.leftA, ")")

function Base.isless(a::TrialType, b::TrialType)
    ratio(tt::TrialType) = tt.nB/tt.nA

    # Ordering puts high-A trials before high-B trials
    rA, rB = ratio(a), ratio(b)
    isless(rA, rB) && return true
    isless(rB, rA) && return false
    a.nA > b.nA && return true
    a.nA < b.nA && return false
    a.nB > b.nB && return false
    a.nB < b.nB && return true
    return a.leftA > b.leftA   # if all else are equal, put left before right
end

"""
    TrialResult(nA, nB, leftA::Bool, choseA::Union{Bool,Missing})
    TrialResult(tt::TrialType, choseA::Union{Bool,Missing})

Encode the offer configuration (see [`TrialType`](@ref)), and whether the animal chose A, B, or failed to make a choice
(`choseA = true | false | missing`, respectively).
"""
struct TrialResult
    tt::TrialType
    choseA::Union{Bool,Missing}   # missing if the animal didn't lick
end
TrialResult(nA, nB, leftA, choseA) = TrialResult(TrialType(nA, nB, leftA), choseA)
TrialResult(; nA, nB, leftA, choseA) = TrialResult(nA, nB, leftA, choseA)

function Base.getproperty(tr::TrialResult, name::Symbol)
    name === :nA && return getfield(tr, :tt).nA
    name === :nB && return getfield(tr, :tt).nB
    name === :leftA && return getfield(tr, :tt).leftA
    name === :tt && return getfield(tr, :tt)
    return getfield(tr, name)
end

Base.show(io::IO, tr::TrialResult) = print(io, "TrialResult(nA=", tr.nA, ", nB=", tr.nB, ", leftA=", tr.leftA, ", choseA=", tr.choseA, ")")

TrialType(tr::TrialResult) = tr.tt


"""
    EventTiming(trial_start, offer_on, offer_off, go, choice, trial_end)

Specify the timing of events during a trial. All times should be in physical units (`s` or `ms`).

# Examples

```jldoctest; setup=:(using EcoTrialStructure)
julia> EventTiming(0ms, 100ms, 400ms, 450ms, 837ms, 1.2s)
EventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)
```
"""
struct EventTiming
    trial_start::Tms
    offer_on::Tms
    offer_off::Tms
    go::Tms
    choice::Tms
    trial_end::Tms
end
EventTiming(; trial_start, offer_on, offer_off, go, choice, trial_end) =
    EventTiming(trial_start, offer_on, offer_off, go, choice, trial_end)

Base.show(io::IO, et::EventTiming) = print(io, "EventTiming(trial_start=", et.trial_start, ", offer_on=", et.offer_on, ", offer_off=", et.offer_off, ", go=", et.go, ", choice=", et.choice, ", trial_end=", et.trial_end, ")")

function (fs::FrameSeq)(et::EventTiming)
    start = fs.start
    return isa(start, Symbol) ? FrameSeq(getfield(et, fs.start), fs.len) : fs
end
