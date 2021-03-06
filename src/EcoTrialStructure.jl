"""
EcoTrialStructure is a package for representing behavioral/physiological data from economic choice experiments.

You can learn more about each of the following from its own docstring, e.g., `?CellsTrial`:

- `CellsTrial`: Store cellular responses for a single trial.
- `EventTiming`: Specify the timing of events during a trial.
- `FrameSeq`: A sequence of `nframes` frames starting nearest to a specified time.
- `OfferType`: Encode the offer quantities and side (left/right).
- `TrialResult`: Encode the `OfferType` and the animal's choice.
- `isforced`: Return `true` for a forced-choice trial.
- `iswrong`: Return `true` if the animal chose incorrectly on a forced-choice trial.
- `madechoice`: Return `true` if the animal made a choice in the trial.
- `ncells`: Return the number of cells in a `CellsTrial`
- `parsemat`: Parse the trial data in `filename`.
- `positive_cells`: Extract the vector of `idx_positive_cells` from the .mat file.
"""
module EcoTrialStructure

using Unitful
using Unitful: ms, s
using IntervalSets
using OffsetArrays
using OrderedCollections
using MAT

export CellsTrial, FrameSeq, OfferType, TrialResult, EventTiming
export isdeferred, isforced, iswrong, madechoice, ncells, .., ms, s
export parsemat, positive_cells

include("types.jl")
include("utils.jl")
include("matlab.jl")

Base.@deprecate_binding TrialType OfferType

end
