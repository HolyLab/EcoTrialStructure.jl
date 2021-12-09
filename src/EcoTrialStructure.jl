module EcoTrialStructure

using Unitful
using Unitful: ms, s
using IntervalSets

export CellsTrial, FrameSeq, TrialType, EventTiming
export isforced, iswrong, madechoice, .., ms, s

include("types.jl")
include("utils.jl")

end
