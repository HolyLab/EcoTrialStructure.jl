var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = EcoTrialStructure","category":"page"},{"location":"#EcoTrialStructure","page":"Home","title":"EcoTrialStructure","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"EcoTrialStructure provides low-level operations to analyze experiments in economic decision making. You can import both behavioral and physiological data and manipulate them naturally.","category":"page"},{"location":"#Matlab-file-import-(Padoa-Schioppa-lab-users)","page":"Home","title":"Matlab-file import (Padoa-Schioppa lab users)","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"When the data have already been saved as a .mat file, the first thing to do is import the data. This package's test/data folder contains a test file that serves as a useful demo:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using EcoTrialStructure\n\njulia> cts, trs, ets = parsemat(joinpath(pkgdir(EcoTrialStructure), \"test\", \"data\", \"testfile.mat\"));\n\njulia> cts\nOrderedCollections.OrderedDict{Int64, CellsTrial{Float64}} with 2 entries:\n  3   => 63 cells with 69 timepoints\n  201 => 63 cells with 39 timepoints\n\njulia> trs\nOrderedCollections.OrderedDict{Int64, TrialResult} with 2 entries:\n  3   => TrialResult(nA=0, nB=2, leftA=true, choseA=true)\n  201 => TrialResult(nA=2, nB=0, leftA=false, choseA=true)\n\njulia> ets\nOrderedCollections.OrderedDict{Int64, EventTiming} with 2 entries:\n  3   => EventTiming(trial_start=0.0 ms, offer_on=2003.0 ms, offer_off=4820.0 m…\n  201 => EventTiming(trial_start=0.0 ms, offer_on=2002.0 ms, offer_off=4812.0 m…","category":"page"},{"location":"","page":"Home","title":"Home","text":"This test data file was extracted from a much larger & more complete experiment with 237 trials, of which just 2 were used for testing purposes. cts has information about the cells (see CellsTrial), trs about the offers and behavioral decisions (see TrialResult), and ets about the timing of events during each trial (see EventTiming). Each is indexed with the trial index, i.e., ets[3] extracts the event timing for trial 3.","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can extract additional information from the .mat file; an example is given by positive_cells.","category":"page"},{"location":"#Manipulating-the-core-types","page":"Home","title":"Manipulating the core types","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Extracting data can be done by standard Julia methods, for example:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> trs[3].nB\n2","category":"page"},{"location":"","page":"Home","title":"Home","text":"There are also a number of convenience utilities, like isforced to detect whether a given trial presented a \"forced\" choice.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CellsTrial provides a number of convenience methods for extracting comparable data from different trials; see the examples in its documentation for a detailed explanation. But as an overall example, here is a demonstration extracting dFoF data in the 10 frames starting from offer_on across all trials, sorted by trial order:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> dFoF = reduce(hcat, [cts[trialindex][FrameSeq(et.offer_on, 10), :][2] for (trialindex, et) in ets])\n10×126 Matrix{Float64}:\n 0.158358    0.318992    0.679291  …  0.109446   0.0925348  0.14776\n 0.0949043   0.427107    0.792304     0.117057   0.0633849  0.135291\n 0.207441    0.387189    0.50655      0.117598   0.0921308  0.0395489\n 0.173742    0.240543    0.49942      0.0703209  0.136526   0.211277\n 0.0754508   0.292467    0.44907      0.0493834  0.103206   0.114697\n 0.115572    0.281595    0.356081  …  0.0892007  0.154582   0.0220522\n 0.119914    0.193427    0.418782     0.1063     0.206242   0.0993945\n 0.0501042   0.12239     0.416016     0.114474   0.136142   0.0712373\n 0.0703462   0.219104    0.488288     0.10033    0.20305    0.0719393\n 0.0634827  -0.00769133  0.348985     0.0748435  0.0291505  0.106942","category":"page"},{"location":"","page":"Home","title":"Home","text":"As explanation, in this demo there were only two trials, with 63 cells in each (hence the 126 columns). FrameSeq(et.offer_on, 10) indicates we want the 10 frames starting with the current trial's \"offer-on\" time (times are rounded to the closest frame time).  Because indexing a CellsTrial with a time or frame range returns both the time interval and the dFoF data, the final [2] selects just the dFoF data. Finally, the reduce(hcat, Xs) concatenates all matrices in Xs horizontally. If you find any of this confusing, try running individual pieces using the data in test/data/testdata.mat and seeing what each produces.","category":"page"},{"location":"#API-reference","page":"Home","title":"API reference","text":"","category":"section"},{"location":"#.mat-file-parsing","page":"Home","title":".mat-file parsing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"parsemat\npositive_cells","category":"page"},{"location":"#EcoTrialStructure.parsemat","page":"Home","title":"EcoTrialStructure.parsemat","text":"parsemat(filename)\nparsemat(readfunction, filename)\n\nParse the trial data in filename. Optionally pass a readfunction to extract additional elements; readfunction should have syntax\n\nfunction readfunction(data, args...)\n    moredata = data[\"matlab_variable_name\"]\n    # maybe do some processing/validation\n    return args..., moredata\nend\n\ndata is the result of MAT.matread(filename).\n\nSee also: positive_cells.\n\n\n\n\n\n","category":"function"},{"location":"#EcoTrialStructure.positive_cells","page":"Home","title":"EcoTrialStructure.positive_cells","text":"positive_cells(data, args...)\n\nExtract the vector of idx_positive_cells from the .mat file.\n\n\n\n\n\n","category":"function"},{"location":"#Core-types","page":"Home","title":"Core types","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CellsTrial\nFrameSeq\nTrialType\nTrialResult\nEventTiming","category":"page"},{"location":"#EcoTrialStructure.CellsTrial","page":"Home","title":"EcoTrialStructure.CellsTrial","text":"CellsTrial(t, dFoF)\n\nStore cellular responses for a single trial. t is the list of frame times (in units of time, see Unitful.jl) and dFoF is a matrix with one row for each time in t, and one column per cell.\n\nExamples\n\njulia> dFoF = [ 0.1 0.8;\n               -0.1 0.7;\n                0.2 0.6;\n                0.1 0.5;\n                0.0 0.4];\n\njulia> ct = CellsTrial((100:100:500) * ms, dFoF)\n2 cells with 5 timepoints\n\nIt's straightforward to extract the dFoF values over a particular time interval:\n\njulia> tframes, df = ct[175ms..310ms, :];  # frames range nearest to given start..stop times\n\njulia> tframes\n200.0f0 ms..300.0f0 ms\n\njulia> df\n2×2 Matrix{Float64}:\n -0.1  0.7\n  0.2  0.6\n\nThis extracted the dFoF values recorded between 200ms and 300ms, inclusive.\n\nIn other cases, you might want a specific number of frames, starting at a particular time:\n\njulia> tframes, df = ct[FrameSeq(175ms, 3), :];  # start nearest to 175ms, and grab 3 frames' worth\n\njulia> tframes\n200.0f0 ms..400.0f0 ms\n\njulia> df\n3×2 Matrix{Float64}:\n -0.1  0.7\n  0.2  0.6\n  0.1  0.5\n\n\n\n\n\n","category":"type"},{"location":"#EcoTrialStructure.FrameSeq","page":"Home","title":"EcoTrialStructure.FrameSeq","text":"FrameSeq(tstart, nframes)\nFrameSeq(eventfield::Symbol, nframes)\n\nA sequence of nframes frames starting at the nearest timepoint to tstart. See CellsTrial for an example using this in indexing.\n\nAlternatively, this can be constructed specifying a particular fieldname of EventTiming, in which case the concrete timing can be deferred until a later time based on a specific trial:\n\njulia> fs = FrameSeq(:go, 5)\nFrameSeq(:go, 5)\n\njulia> et = EventTiming(0ms, 100ms, 400ms, 450ms, 837ms, 1.2s)\nEventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)\n\njulia> fs(et)\nFrameSeq(450.0f0 ms, 5)\n\n\n\n\n\n","category":"type"},{"location":"#EcoTrialStructure.TrialType","page":"Home","title":"EcoTrialStructure.TrialType","text":"TrialType(nA, nB, leftA::Bool)\n\nEncode the offers (nA and nB are the number of drops of A and B, respectively), and whether A was on the left.\n\n\n\n\n\n","category":"type"},{"location":"#EcoTrialStructure.TrialResult","page":"Home","title":"EcoTrialStructure.TrialResult","text":"TrialResult(nA, nB, leftA::Bool, choseA::Union{Bool,Missing})\nTrialResult(tt::TrialType, choseA::Union{Bool,Missing})\n\nEncode the offer configuration (see TrialType), and whether the animal chose A, B, or failed to make a choice (choseA = true | false | missing, respectively).\n\n\n\n\n\n","category":"type"},{"location":"#EcoTrialStructure.EventTiming","page":"Home","title":"EcoTrialStructure.EventTiming","text":"EventTiming(trial_start, offer_on, offer_off, go, choice, trial_end)\n\nSpecify the timing of events during a trial. All times should be in physical units (s or ms).\n\nExamples\n\njulia> EventTiming(0ms, 100ms, 400ms, 450ms, 837ms, 1.2s)\nEventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)\n\n\n\n\n\n","category":"type"},{"location":"#Simple-utilities","page":"Home","title":"Simple utilities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"madechoice\nisforced\niswrong","category":"page"},{"location":"#EcoTrialStructure.madechoice","page":"Home","title":"EcoTrialStructure.madechoice","text":"madechoice(tr::TrialResult)\n\nReturns true if the animal made a choice in the trial.\n\n\n\n\n\n","category":"function"},{"location":"#EcoTrialStructure.isforced","page":"Home","title":"EcoTrialStructure.isforced","text":"isforced(tt::TrialType)\nisforced(tr::TrialResult)\n\nReturns true for a forced-choice trial, where either nA or nB is zero.\n\n\n\n\n\n","category":"function"},{"location":"#EcoTrialStructure.iswrong","page":"Home","title":"EcoTrialStructure.iswrong","text":"iswrong(tr::TrialResult)\n\nReturns true if tr is a forced-choice trial and the animal chose the wrong option.\n\n\n\n\n\n","category":"function"}]
}
