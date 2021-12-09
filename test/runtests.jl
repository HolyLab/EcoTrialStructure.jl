using EcoTrialStructure
using Test
using Documenter

@testset "EcoTrialStructure.jl" begin
    @test isempty(detect_ambiguities(EcoTrialStructure))
    doctest(EcoTrialStructure)

    @testset "CellsTrial" begin
        t = (100:100:500) * ms   # times at which frames were collected
        dFoF = [ 0.1 0.8;
                -0.1 0.7;
                0.2 0.6;
                0.1 0.5;
                0.0 0.4]
        ct = @inferred(CellsTrial(t, dFoF))
        ct2 = @inferred(CellsTrial([100,200,300,400,500] * ms, dFoF))
        @test_throws ArgumentError("frame times must be increasing") CellsTrial([100,300,200,400,500] * ms, dFoF)
        @test_throws DimensionMismatch CellsTrial((100:100:600) * ms, dFoF)
        @test_throws DimensionMismatch CellsTrial((100:100:400) * ms, dFoF)
        @test sprint(show, ct) == "2 cells with 5 timepoints"
        # equality and hashing
        @test ct == ct2
        d = Dict(ct => 1)
        d[ct2] = 2
        @test length(d) == 1 && d[ct] == 2
        # indexing
        @test ct[2:3,:] == (t[2:3], dFoF[2:3,:])
        @test ct[2:3,1] == (t[2:3], dFoF[2:3,1])
        @test ct[2:3,2] == (t[2:3], dFoF[2:3,2])
        @test ct[:,:]   == (t, dFoF)
        @test_throws BoundsError ct[2:3,3]
        @test_throws BoundsError ct[2:3,0]
        @test_throws BoundsError ct[4:6,:]
        @test ct[FrameSeq(100ms, 2),:] == ct[FrameSeq(120ms, 2),:] == (100ms..200ms, dFoF[1:2,:])
        @test ct[FrameSeq(200ms, 2),:] == ct[FrameSeq(220ms, 2),:] == ct[FrameSeq(180ms, 2),:] == (200ms..300ms, dFoF[2:3,:])
        @test_throws BoundsError ct[FrameSeq( 80ms, 2),:]   # times must be within the span
        @test_throws BoundsError ct[FrameSeq(470ms, 2),:]
        @test ct[FrameSeq(490ms, 1),:] == (500ms..500ms, dFoF[end:end,:])
    end

    @testset "TrialType" begin
        tt = TrialType(3, 1, false, true)
        @test sprint(show, tt) == "TrialType(nA=3, nB=1, leftA=false, choseA=true)"
        @test eval(Meta.parse("TrialType(nA=3, nB=1, leftA=false, choseA=true)")) == tt
        @test tt == TrialType(choseA=true, nB=1, nA=3, leftA=false)
        @test tt != TrialType(3, 1, false, false)
        @test tt != TrialType(3, 1, false, missing)
        @test TrialType(3, 1, false, missing) == TrialType(3, 1, false, missing)
        @test !isforced(tt)
        @test  madechoice(tt)
        @test !madechoice(TrialType(3, 1, false, missing))
        ttf = TrialType(3, 0, false, true)
        @test  isforced(ttf)
        @test !iswrong(ttf)
        ttf = TrialType(3, 0, false, false)
        @test  isforced(ttf)
        @test  iswrong(ttf)
        @test !isforced(TrialType(0, 0, false, true))
    end

    @testset "EventTiming" begin
        et = @inferred(EventTiming(0ms, 100ms, 400ms, 450ms, 837ms, 1.2s))
        @test sprint(show, et) == "EventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)"
        @test eval(Meta.parse("EventTiming(trial_start=0.0f0ms, offer_on=100.0f0ms, offer_off=400.0f0ms, go=450.0f0ms, choice=837.0f0ms, trial_end=1200.0f0ms)")) == et
        # Unitful doesn't yet support round-trip printing, see https://github.com/PainterQubits/Unitful.jl/pull/470
        @test_broken eval(Meta.parse("EventTiming(trial_start=0.0f0 ms, offer_on=100.0f0 ms, offer_off=400.0f0 ms, go=450.0f0 ms, choice=837.0f0 ms, trial_end=1200.0f0 ms)")) == et
        @test et.trial_end == 1200ms
    end

    @testset "Matlab import" begin
        # Check the "reverse-encoding" of the TrialType
        @test  EcoTrialStructure.mat_trialtype(1, 1, 1, 1).choseA
        @test !EcoTrialStructure.mat_trialtype(1, 1, 2, 1).choseA
        tt = EcoTrialStructure.mat_trialtype(0, 1, 0, 1)
        @test tt.choseA
        @test iswrong(tt)
        @test madechoice(tt)
        tt = EcoTrialStructure.mat_trialtype(1, 0, 0, 1)
        @test !tt.choseA
        @test iswrong(tt)
        @test madechoice(tt)
        @test_throws Exception EcoTrialStructure.mat_trialtype(1, 1, 0, 1)
        @test_throws Exception EcoTrialStructure.mat_trialtype(0, 0, 0, 1)
        tt = EcoTrialStructure.mat_trialtype(1, 1, 0, 0)
        @test !madechoice(tt)

        testfile = joinpath(@__DIR__, "data", "testfile.mat")  # snippet from data collected by Manning Zhang, Washington University in St. Louis
        cts, tts, ets = parsemat(testfile)
        tt3, tt201 = tts[3], tts[201]
        @test isforced(tt3)
        @test iswrong(tt3)
        @test tt3.nB == 2
        @test isforced(tt201)
        @test !iswrong(tt201)
        @test tt201.nA == 2
        @test sprint(show, cts[3])   == "63 cells with 69 timepoints"
        @test sprint(show, cts[201]) == "63 cells with 39 timepoints"
        @test length(ets) == 2
        et3 = ets[3]
        @test et3.trial_start == 0s
        @test et3.offer_on  == 2003ms
        @test et3.offer_off == et3.go == 4820ms
        @test et3.choice == 5111ms
        @test et3.trial_end == 11066ms

        cts, tts, ets, poscells = parsemat(positive_cells, testfile)
        @test sum(poscells) == 5 && length(poscells) == 63
    end
end