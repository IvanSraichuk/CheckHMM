begin
    using HiddenMarkovModelReaders
    using DelimitedFiles
    using StatsBase
end;

function process(name, signal, penal)

    hmm = setup(signal)
    hmmParams = HMMParams(
        penalty = penal,
        distance = euclideanDistance,
        minimumFrequency = 20,
        verbosity = false,
    )
    # process
    for _ ∈ 1:4
        _ = process!(hmm, signal, true; params = hmmParams)
    end

    # final
    for _ ∈ 1:2
        _ = process!(hmm, signal, false; params = hmmParams)
    end
    hmmDc = Dict{String,HMM}()
    hmmDc[name*"50P_ECG"*string(1)] = hmm
    writeHMM("out/", hmmDc)
    return countmap(hmm.traceback)
end

begin
    path1 = "normal-peaks.txt"
    path2 = "normal-sinus-rhythm.txt"
    ar1 = readdlm(path1, Float64)
    print("File done")
    ar2 = readdlm(path2, Float64)

    signal = ar1[1:500, 1]
    signal1 = reshape(signal, length(signal), 1)
    map1 = process(path1, signal1, 800)
    println("Done")
    print(map1)
end


