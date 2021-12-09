```@meta
CurrentModule = EcoTrialStructure
```

# EcoTrialStructure

[EcoTrialStructure](https://github.com/HolyLab/EcoTrialStructure.jl) provides low-level operations to analyze experiments
in economic decision making. You can import both behavioral and physiological data and manipulate them naturally.

## Matlab-file import (Padoa-Schioppa lab users)

When the data have already been saved as a `.mat` file, the first thing to do is import the data.
This package's `test/data` folder contains a test file that serves as a useful demo:

```
julia> using EcoTrialStructure

julia> cts, tts, ets = parsemat(joinpath(pkgdir(EcoTrialStructure), "data", "testfile.mat"));

julia> cts
Dict{Int64, CellsTrial{Float64}} with 2 entries:
  201 => 63 cells with 39 timepoints
  3   => 63 cells with 69 timepoints

julia> tts
Dict{Int64, TrialType} with 2 entries:
  201 => TrialType(nA=2, nB=0, leftA=false, choseA=true)
  3   => TrialType(nA=0, nB=2, leftA=true, choseA=true)

julia> length(ets)
237

julia> ets[3]
EventTiming(trial_start=0.0f0 ms, offer_on=2003.0f0 ms, offer_off=4820.0f0 ms, go=4820.0f0 ms, choice=5111.0f0 ms, trial_end=11066.0f0 ms)
```

This test data file was extracted from a much larger & more complete experiment with 237 trials, of which just 2 were used for testing purposes.
`cts` has information about the cells (see [`CellsTrial`](@ref)), `tts` about the offers and behavioral decisions (see [`TrialType`](@ref)), and `ets` about the timing of events during each trial (see [`EventTiming`](@ref)).

You can extract additional information from the .mat file; an example is given by [`positive_cells`](@ref).

## Manipulating the core types

Extracting data can be done by standard Julia methods, for example:

```
julia> tts[3].nB
2
```

There are also a number of convenience utilities, like [`isforced`](@ref) to detect whether a given trial presented a "forced" choice.

[`CellsTrial`](@ref) provides a number of convenience methods for extracting comparable data from different trials; see the examples in its documentation for a detailed explanation. But as an overall example, here is a demonstration extracting `dFoF` data in the 10 frames starting from `offer_on` across all trials, sorted by trial order:

```
julia> dFoF = reduce(hcat, [cts[trialindex][FrameSeq(et.offer_on, 10), :][2] for (trialindex, et) in sort(collect(pairs(ets)); by=first)])
10×126 Matrix{Float64}:
 0.158358    0.318992    0.679291   0.0311764   0.608567  0.911684  …  0.12326    0.0338083  0.109446   0.0925348  0.14776
 0.0949043   0.427107    0.792304   0.137494    0.595443  0.987024     0.0464077  0.108676   0.117057   0.0633849  0.135291
 0.207441    0.387189    0.50655   -0.00198315  0.539023  0.798412     0.110981   0.0137426  0.117598   0.0921308  0.0395489
 0.173742    0.240543    0.49942   -0.074434    0.421607  0.717477     0.0771472  0.0669906  0.0703209  0.136526   0.211277
 0.0754508   0.292467    0.44907    0.00469107  0.421013  0.655816     0.0210046  0.0375375  0.0493834  0.103206   0.114697
 0.115572    0.281595    0.356081  -0.0233212   0.276522  0.59721   …  0.0808096  0.0671552  0.0892007  0.154582   0.0220522
 0.119914    0.193427    0.418782  -0.00684894  0.393146  0.586379     0.116008   0.0987773  0.1063     0.206242   0.0993945
 0.0501042   0.12239     0.416016  -0.016236    0.3026    0.550832     0.0673079  0.124986   0.114474   0.136142   0.0712373
 0.0703462   0.219104    0.488288  -0.0157291   0.347036  0.615563     0.148375   0.106524   0.10033    0.20305    0.0719393
 0.0634827  -0.00769133  0.348985  -0.164472    0.110123  0.2051       0.138114   0.0658132  0.0748435  0.0291505  0.106942
```

As explanation, in this demo there were only two trials, with 63 cells in each (hence the 126 columns).
`sort(collect(pairs(ets)); by=first)` returns a list of `trialindex => eventtiming` pairs, in order of `trialindex`.
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
EventTiming
```

### Simple utilities

```@docs
madechoice
isforced
iswrong
```