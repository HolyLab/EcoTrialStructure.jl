function idxof(list, x)
    r1, r2 = _idxof(list, x)
    return _idxof(list, x, r1, r2)
end
function _idxof(list, x)
    r = searchsorted(list, x)
    r1, r2 = first(r), last(r)
    return min(r1, r2), max(r1, r2)
end
_idxof(list, x, r1, r2) =  x - list[r1] < list[r2] - x ? r1 : r2

function idxsof(list, ti::FrameSeq)
    istart = idxof(list, ti.start)
    return istart .+ ti.idx
end

"""
    ncells(ct::CellsTrial)

Return the number of cells stored in the `dFoF` field of `ct`.
"""
ncells(ct::CellsTrial) = size(ct.dFoF, 2)

"""
    isdeferred(fs::FrameSeq)

Return `true` if the start time in `fs` is a field name of `EventTiming`, and hence
requires concrete instantiation as `fs(et)` for a specific trial.
"""
isdeferred(fs::FrameSeq) = isa(fs.start, Symbol)

"""
    madechoice(tr::TrialResult)

Return `true` if the animal made a choice in the trial.
"""
madechoice(tr::TrialResult) = tr.choseA !== missing

"""
    isforced(tt::TrialType)
    isforced(tr::TrialResult)

Return `true` for a forced-choice trial, where either `nA` or `nB` is zero.
"""
isforced(tt::TrialType) = iszero(tt.nA) ⊻ iszero(tt.nB)
isforced(tr::TrialResult) = isforced(tr.tt)

"""
    iswrong(tr::TrialResult)

Return `true` if `tr` is a forced-choice trial and the animal chose the wrong option.
"""
iswrong(tr::TrialResult) = isforced(tr) && ((iszero(tr.nA) & (tr.choseA===true)) | (iszero(tr.nB) & (tr.choseA===false)))
