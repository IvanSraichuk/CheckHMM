begin
    using HiddenMarkovModelReaders
    using MindReader
    using DelimitedFiles
    using StatsBase
end;


function process(signal, penalty)
  
    hmm = setup(signal)
    hmmParams = HMMParams(
        penalty = penalty,
        distance = euclideanDistance,
        minimumFrequency = 20,
        verbosity = false,
    )
    # process
    for i ∈ 1:4
    _ = process!(hmm, signal, true; params = hmmParams, )
    end

    # final
    for i ∈ 1:2
    _ = process!(hmm, signal, false; params = hmmParams,)
    end
    return hmm.traceback
end

begin
    #         N    AF        N        AF      N        AF       N            
    #array([ 30,  102584,  119604,  121773,  122194,  133348,  166857,    1096245, 1098054, 1135296, 1139595, 1422436, 1423548, 1459277,    1460416]
    path1 = "scripts/04015ECG.txt"
    penalties = [5, 10, 20, 50, 100, 200, 500, 1000]
    #penalties = [20, 50]
    
    ar1 = readdlm(path1, Float64)
    labelVc = ones(Int, 250000)
    labelVc[102584:119604] .= 2
    labelVc[121773:122194] .= 2
    labelVc[133348:166857] .= 2
    labelVc[133348:166857] .= 2
    for penalty in penalties
        signal = ar1[1:250000, 1]
        signal1 = reshape(signal, length(signal), 1)
        traceback1 = process(signal1, penalty)    
        
        signal = ar1[1:250000, 2]
        signal1 = reshape(signal, length(signal), 1)
        traceback2 = process(signal1, penalty)
        println("Penalty = " * string(penalty))
        println(performance(traceback1, labelVc))
        println(performance(traceback2, labelVc))      
    end

    print(size(ar1))
end