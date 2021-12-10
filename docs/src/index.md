```@meta
CurrentModule = EcoTrialStructure
```

# EcoTrialStructure

[EcoTrialStructure](https://github.com/HolyLab/EcoTrialStructure.jl) provides low-level operations to analyze experiments
in economic decision making. You can import both behavioral and physiological data and manipulate them naturally.

## Matlab-file import (Padoa-Schioppa lab users)

When the data have already been saved as a `.mat` file, the first thing to do is import the data.
This package's `test/data` folder contains a test file that serves as a useful demo:

```jldoctest matdemo
julia> using EcoTrialStructure

julia> cts, tts, ets = parsemat(joinpath(pkgdir(EcoTrialStructure), "test", "data", "testfile.mat"));

julia> cts
OrderedCollections.OrderedDict{Int64, CellsTrial{Float64}} with 2 entries:
  3   => 63 cells with 69 timepoints
  201 => 63 cells with 39 timepoints

julia> tts
OrderedCollections.OrderedDict{Int64, TrialResult} with 2 entries:
  3   => TrialResult(nA=0, nB=2, leftA=true, choseA=true)
  201 => TrialResult(nA=2, nB=0, leftA=false, choseA=true)

julia> ets
OrderedCollections.OrderedDict{Int64, EventTiming} with 2 entries:
  3   => EventTiming(trial_start=0.0 ms, offer_on=2003.0 ms, offer_off=4820.0 m…
  201 => EventTiming(trial_start=0.0 ms, offer_on=2002.0 ms, offer_off=4812.0 m…
```

This test data file was extracted from a much larger & more complete experiment with 237 trials, of which just 2 were used for testing purposes.
`cts` has information about the cells (see [`CellsTrial`](@ref)), `tts` about the offers and behavioral decisions (see [`TrialResult`](@ref)), and `ets` about the timing of events during each trial (see [`EventTiming`](@ref)).
Each is indexed with the trial index, i.e., `ets[3]` extracts the event timing for trial 3.

You can extract additional information from the .mat file; an example is given by [`positive_cells`](@ref).

## Manipulating the core types

Extracting data can be done by standard Julia methods, for example:

```jldoctest matdemo
julia> tts[3].nB
2
```

There are also a number of convenience utilities, like [`isforced`](@ref) to detect whether a given trial presented a "forced" choice.

[`CellsTrial`](@ref) provides a number of convenience methods for extracting comparable data from different trials; see the examples in its documentation for a detailed explanation. But as an overall example, here is a demonstration extracting `dFoF` data in the 10 frames starting from `offer_on` across all trials, sorted by trial order:

```jldoctest matdemo
julia> dFoF = reduce(hcat, [cts[trialindex][FrameSeq(et.offer_on, 10), :][2] for (trialindex, et) in ets])
10×126 Matrix{Float64}:
 0.158358    0.318992    0.679291  …  0.109446   0.0925348  0.14776
 0.0949043   0.427107    0.792304     0.117057   0.0633849  0.135291
 0.207441    0.387189    0.50655      0.117598   0.0921308  0.0395489
 0.173742    0.240543    0.49942      0.0703209  0.136526   0.211277
 0.0754508   0.292467    0.44907      0.0493834  0.103206   0.114697
 0.115572    0.281595    0.356081  …  0.0892007  0.154582   0.0220522
 0.119914    0.193427    0.418782     0.1063     0.206242   0.0993945
 0.0501042   0.12239     0.416016     0.114474   0.136142   0.0712373
 0.0703462   0.219104    0.488288     0.10033    0.20305    0.0719393
 0.0634827  -0.00769133  0.348985     0.0748435  0.0291505  0.106942
```

As explanation, in this demo there were only two trials, with 63 cells in each (hence the 126 columns).
`FrameSeq(et.offer_on, 10)` indicates we want the 10 frames starting with the current trial's "offer-on" time (times are
rounded to the closest frame time).  Because indexing a `CellsTrial` with a time or frame range returns both the time interval and the `dFoF` data, the final `[2]` selects just the `dFoF` data. Finally, the `reduce(hcat, Xs)` concatenates all matrices
in `Xs` horizontally. If you find any of this confusing, try running individual pieces using the data in `test/data/testdata.mat` and seeing what each produces.

## API reference

### .mat-file parsing

```@docs
parsemat
positive_cells
```

### Core types

```@docs
CellsTrial
FrameSeq
TrialType
TrialResult
EventTiming
```

### Simple utilities

```@docs
madechoice
isforced
iswrong
```
