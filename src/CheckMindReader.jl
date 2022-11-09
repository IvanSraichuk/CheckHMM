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
        _ = process!(hmm, signal, true; params = hmmParams)
    end

    # final
    for i ∈ 1:2
        _ = process!(hmm, signal, false; params = hmmParams)
    end
    return hmm.traceback
end

function calculateAccuracy(result, expectedResult)
    sum = 0
    count = size(result)[1]
    for i = 1:1:count
        if result[i] == expectedResult[i]
            sum = sum + 1
        end
    end
    return sum / count
end

function calculateAFEvents(result, expectedResult)
    sum = 0
    count = size(result)[1]
    if count != size(expectedResult)[1]
      return NaN
    end
    for i = 1:1:count
        if result[i] == expectedResult[i] && expectedResult[i] == 1
            sum = sum + 1
        end
    end
    return sum / count
  end

begin
    recordName = ARGS[1]
    AFevent_start = parse(Int64, ARGS[2])
    AFevent_end = parse(Int64, ARGS[3])
    start_position = parse(Int64, ARGS[4])
    end_position = parse(Int64, ARGS[5])
end

begin
    AF_interval = AFevent_end - AFevent_start
    Interval = end_position - start_position
    path1 = "scripts/" * recordName * "ECG.txt"
    penalties = [5, 10, 20, 50, 100, 200, 500, 1000]
    ar1 = readdlm(path1, Float64)
    labelVc = zeros(Int, Interval + 1)
    AF_start = AFevent_start - start_position
    labelVc[AF_start:AF_start+AF_interval] .= 1
end

begin
    for (ι, penalty) in enumerate(penalties)
        signal = ar1[start_position:end_position, 1]
        signal1 = reshape(signal, length(signal), 1)
        traceback1 = process(signal1, penalty)

        signal = ar1[start_position:end_position, 2]
        signal1 = reshape(signal, length(signal), 1)
        traceback2 = process(signal1, penalty)
        traceback1[traceback1.>1] .= 2
        # TODO: Fix MindReader
        traceback1 .= traceback1 .- 1
        traceback2[traceback2.>1] .= 2
        traceback2 .= traceback2 .- 1
        try
            labels = [0, 1]
            #println(MindReader.adjustFq(traceback1, labelVc, labels))
            #println(calculateAccuracy(traceback1, labelVc))
            #println(calculateAccuracy(traceback2, labelVc))
            result1 = performance(traceback1, labelVc)
            result1["Penalty"] = penalty
            result1["AF_Accuracy"] = calculateAFEvents(traceback1, labelVc)
            result2 = performance(traceback2, labelVc)
            result2["Penalty"] = penalty
            result2["AF_Accuracy"] = calculateAFEvents(traceback2, labelVc)
            println(result1)
            println(result2)
        catch e
            println("Error!")
            #println(e)
        end
    end

    print(size(ar1))
end
