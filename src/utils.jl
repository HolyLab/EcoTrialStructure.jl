function idxof(list, x)
    r = searchsorted(list, x)
    r1, r2 = first(r), last(r)
    r1, r2 = min(r1, r2), max(r1, r2)
    return x - list[r1] < list[r2] - x ? r1 : r2
end

"""
    madechoice(tt::TrialType)

Returns `true` if the animal made a choice in the trial.
"""
madechoice(tt::TrialType) = tt.choseA !== missing

"""
    isforced(tt::TrialType)

Returns `true` for a forced-choice trial, where either `nA` or `nB` is zero.
"""
isforced(tt::TrialType) = iszero(tt.nA) ⊻ iszero(tt.nB)

"""
    iswrong(tt::TrialType)

Returns `true` if `tt` is a forced-choice trial and the animal chose the wrong option.
"""
iswrong(tt::TrialType) = isforced(tt) && ((iszero(tt.nA) & (tt.choseA===true)) | (iszero(tt.nB) & (tt.choseA===false)))
