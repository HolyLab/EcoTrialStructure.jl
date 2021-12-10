# In the .mat file, the following code is used:
#  [chosen_juice, licking_result] = [1,1]   # animal chose A
#                                 = [2,1]   # animal chose B
#                                 = [0,1]   # animal made wrong choice during forced choice trial
#                                 = [0,0]   # animal made no licking responses
function mat_trialresult(nA, nB, choice, licked)
    leftA = nA < 0 || nB > 0
    nA, nB = abs(nA), abs(nB)
    licked == 0 && return TrialResult(nA, nB, leftA, missing)
    if choice == 0
        nA == 0 && nB == 0 && error("double-forced unexpected")
        nA == 0 || nB == 0 || error("expected this to be a forced-choice")
        choiceA = nA == 0
    else
        choiceA = choice == 1
    end
    return TrialResult(nA, nB, leftA, choiceA)
end

"""
    parsemat(filename)
    parsemat(readfunction, filename)

Parse the trial data in `filename`. Optionally pass a `readfunction` to extract additional elements;
`readfunction` should have syntax

```julia
function readfunction(data, args...)
    moredata = data["matlab_variable_name"]
    # maybe do some processing/validation
    return args..., moredata
end
```

`data` is the result of `MAT.matread(filename)`.

See also: [`positive_cells`](@ref).
"""
parsemat(filename::AbstractString) = parsemat(returntail, filename)

function parsemat(f, filename::AbstractString)
    data = matread(filename)
    celldata = data["celldata"]
    goodtrials = data["goodTrials"]
    psyphydata = data["psyphydata"]

    # parse celldata
    cts = OrderedDict{Int,CellsTrial{Float64}}()   # not all trial indexes are guaranteed to be present
    i0 = i = 1
    idx = Int(celldata[i,2])
    while i <= size(celldata, 1)
        i += 1
        idxnew = i <= size(celldata, 1) ? Int(celldata[i,2]) : idx+1
        if idxnew != idx
            rng = i0:i-1
            cts[idx] = CellsTrial{Float64}(celldata[rng,1]*ms, celldata[rng,3:end])
            i0 = i
            idx = idxnew
        end
    end

    # parse goodtrials (here we assume all trials are listed)
    tts = OrderedDict{Int,TrialResult}()
    for r in eachrow(goodtrials)
        tts[Int(r[1])] = mat_trialresult(r[2:end]...)
    end

    # parse psyphydata
    ets = OrderedDict{Int,EventTiming}()
    j = 0
    while j < size(psyphydata,1)
        trial_start = offer_on = offer_off = go = choice = trial_end = Tms(NaN)
        i = Int(psyphydata[j+1,2])
        while j < size(psyphydata,1) && psyphydata[j+1,2] == i
            j += 1
            t, code = psyphydata[j,1]*ms, psyphydata[j,3]
            if code == 21
                trial_start = t
            elseif code == 30
                offer_on = t
            elseif code == 31
                offer_off = t
            elseif code == 35
                go = t
            elseif code == 39
                choice = t
            elseif code == 43 || code == 44
                @assert t == choice
            elseif code == 60
                trial_end = t
            else
                error("code $code not recognized")
            end
        end
        ets[i] = EventTiming(trial_start, offer_on, offer_off, go, choice, trial_end)
    end

    keys(cts) == keys(tts) == keys(ets) || throw(DimensionMismatch("trial indices must agree"))

    return f(data, cts, tts, ets)
end

returntail(data, args...) = args

"""
    positive_cells(data, args...)

Extract the vector of `idx_positive_cells` from the .mat file.
"""
function positive_cells(data, args...)
    celldata = data["celldata"]
    poscells = data["idx_positive_cells"]
    size(poscells, 2) == 1 || throw(DimensionMismatch("expected idx_positive_cells to be a column vector"))
    poscells = vec(poscells)
    size(celldata, 2) == length(poscells) + 2 ||
        throw(DimensionMismatch("$filename: idx_positive_cells must match columns in celldata"))

    poscells = convert(AbstractVector{Bool}, poscells)

    return args..., poscells
end
