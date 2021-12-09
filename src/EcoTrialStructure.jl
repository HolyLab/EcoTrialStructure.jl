module EcoTrialStructure

using Unitful
using Unitful: ms, s
using IntervalSets
using MAT

export CellsTrial, FrameSeq, TrialType, EventTiming
export isforced, iswrong, madechoice, .., ms, s
export parsemat, positive_cells

include("types.jl")
include("utils.jl")
include("matlab.jl")

end
