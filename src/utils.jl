function idxof(list, x)
    r = searchsorted(list, x)
    r1, r2 = first(r), last(r)
    r1, r2 = min(r1, r2), max(r1, r2)
    return x - list[r1] < list[r2] - x ? r1 : r2
end

"""
    madechoice(tr::TrialResult)

Returns `true` if the animal made a choice in the trial.
"""
madechoice(tr::TrialResult) = tr.choseA !== missing

"""
    isforced(tt::TrialType)
    isforced(tr::TrialResult)

Returns `true` for a forced-choice trial, where either `nA` or `nB` is zero.
"""
isforced(tt::TrialType) = iszero(tt.nA) ⊻ iszero(tt.nB)
isforced(tr::TrialResult) = isforced(tr.tt)

"""
    iswrong(tr::TrialResult)

Returns `true` if `tr` is a forced-choice trial and the animal chose the wrong option.
"""
iswrong(tr::TrialResult) = isforced(tr) && ((iszero(tr.nA) & (tr.choseA===true)) | (iszero(tr.nB) & (tr.choseA===false)))
