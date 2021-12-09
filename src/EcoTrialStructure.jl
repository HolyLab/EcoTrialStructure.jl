"""
EcoTrialStructure is a package for representing behavioral/physiological data from economic choice experiments.

You can learn more about each of the following from its own docstring, e.g., `?CellsTrial`:

- `CellsTrial`: Store cellular responses for a single trial.
- `EventTiming`: Specify the timing of events during a trial.
- `FrameSeq`: A sequence of `nframes` frames starting at the nearest timepoint to `tstart`.
- `TrialType`: Encode the offers (`nA` and `nB` are the number of drops of A and B, respectively), whether A was on the left, and whether the animal chose A, B, or failed to make a choice (`choseA = true | false | missing`, respectively).
- `isforced`: Returns `true` for a forced-choice trial, where either `nA` or `nB` is zero.
- `iswrong`: Returns `true` if `tt` is a forced-choice trial and the animal chose the wrong option.
- `madechoice`: Returns `true` if the animal made a choice in the trial.
- `parsemat`: Parse the trial data in `filename`.
- `positive_cells`: Extract the vector of `idx_positive_cells` from the .mat file.
"""
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
