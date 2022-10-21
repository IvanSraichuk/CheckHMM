begin
    using HiddenMarkovModelReaders
    using DelimitedFiles
end;

begin
    path = "04015ECG.txt"
    ar = readdlm(path, Float64)
    hmmDc = Dict{String, HMM}()
    for j ∈ 1:2
        signal = ar[:, j]
        signal = reshape(signal, length(signal), 1)
        hmm = setup(signal)
        print("setup")
        hmmParams = HMMParams(
            penalty = 50,
            distance = euclideanDistance,
            minimumFrequency = 20,
            verbosity = false,
        )
        # process
        for i ∈ 1:4
            print(i)
        _ = process!(
            hmm,
            signal,
            true;
            params = hmmParams,
        )
        end

        # final
        for _ ∈ 1:2
            print("final")
        _ = process!(hmm, signal, false; params = hmmParams,)
        end

        hmmDc["ECG" * string(j)] = hmm
    end
    writeHMM("out", hmmDc)
  end

 