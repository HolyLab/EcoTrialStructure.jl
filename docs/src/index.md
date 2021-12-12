```@meta
CurrentModule = EcoTrialStructure
```

# EcoTrialStructure

[EcoTrialStructure](https://github.com/HolyLab/EcoTrialStructure.jl) provides simple and natural operations to
analyze experiments in economic decision making. You can import both behavioral and physiological data.

## [Matlab-file import (Padoa-Schioppa lab users)](@id mat)

When the data have already been saved as a `.mat` file, the first thing to do is import the data.
This package's `test/data` folder contains a test file that serves as a useful demo:

```jldoctest matdemo
julia> using EcoTrialStructure

julia> cts, trs, ets = parsemat(joinpath(pkgdir(EcoTrialStructure), "test", "data", "testfile.mat"));

julia> cts
OrderedCollections.OrderedDict{Int64, CellsTrial{Float64}} with 2 entries:
  3   => 63 cells with 69 timepoints
  201 => 63 cells with 39 timepoints

julia> trs
OrderedCollections.OrderedDict{Int64, TrialResult} with 2 entries:
  3   => TrialResult(nA=0, nB=2, leftA=true, choseA=true)
  201 => TrialResult(nA=2, nB=0, leftA=false, choseA=true)

julia> ets
OrderedCollections.OrderedDict{Int64, EventTiming} with 2 entries:
  3   => EventTiming(trial_start=0.0 ms, offer_on=2003.0 ms, offer_off=4820.0 m…
  201 => EventTiming(trial_start=0.0 ms, offer_on=2002.0 ms, offer_off=4812.0 m…
```

This test data file was extracted from a much larger & more complete experiment with 237 trials, of which just 2 were used for testing purposes.
`cts` has information about the cells (see [`CellsTrial`](@ref)), `trs` about the offers and behavioral decisions (see [`TrialResult`](@ref)), and `ets` about the timing of events during each trial (see [`EventTiming`](@ref)).
Each is indexed with the trial index, i.e., `ets[3]` extracts the event timing for trial 3.

You can extract additional information from the .mat file; an example is given by [`positive_cells`](@ref).

## Manipulating the core types

Extracting data can be done by standard Julia methods, for example:

```jldoctest matdemo
julia> trs[3].nB
2
```

There are also a number of convenience utilities, like [`isforced`](@ref) to detect whether a given trial presented a "forced" choice. See more examples in [Simple utilities](@ref).

[`CellsTrial`](@ref) provides a number of convenience methods for extracting comparable data from different trials; see the examples in its documentation for a detailed explanation. But as an overall example, here is a demonstration based on the data above in [Matlab-file import](@ref mat). Here, we extract `dFoF` data triggered at `offer_on` across all (two) trials, extracting 2 pre-frames and 8 post-frames:

```jldoctest matdemo
julia> fs = FrameSeq(:offer_on, -2:7)  # 0 corresponds to offer_on
FrameSeq(:offer_on, -2:7)

julia> dFoFs = [cts[trialindex][fs(et), :][2] for (trialindex, et) in ets];

julia> dFoFs[1]   # trial 3
10×63 OffsetArray(::Matrix{Float64}, -2:7, 1:63) with eltype Float64 with indices -2:7×1:63:
 0.146783   0.479383  0.598108  …  0.0408331   0.0357164   0.0741511
 0.177113   0.481758  0.579934     0.0181103   0.029064    0.0962147
 0.158358   0.318992  0.679291     0.0356008  -0.0285638   0.242723
 0.0949043  0.427107  0.792304     0.105977   -0.0537317   0.26273
 0.207441   0.387189  0.50655      0.0597971  -0.0613983   0.135856
 0.173742   0.240543  0.49942   …  0.0809025  -0.0496011   0.129161
 0.0754508  0.292467  0.44907      0.156167    0.00943657  0.143208
 0.115572   0.281595  0.356081     0.0406873   0.0155088   0.122557
 0.119914   0.193427  0.418782     0.100677    0.288955    0.19112
 0.0501042  0.12239   0.416016     0.0648454   0.622751    0.0572375
```

and where `dFoFs[2]` returns the data for trial 201.

As explanation, `fs(et)` "concretizes" the abstract notion of `offer_on` to the specific time for the trial corresponding
to the events recorded in `et`. Frame sampling may not be precisely syncronized with behavioral events, so the
frame nearest to the event time is chosen as the basepoint. Because indexing a `CellsTrial` with a time interval or `FrameSeq` returns both the time interval and the `dFoF` data, the final `[2]` selects just the `dFoF` data.

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
isdeferred
ncells
```
