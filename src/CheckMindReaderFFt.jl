begin
    using HiddenMarkovModelReaders
    using MindReader
    using DelimitedFiles
    using StatsBase
    using DataFrames
end;

function calculateAccuracy(result, expectedResult)
  sum = 0
  count = size(result)[1]
  if count != size(expectedResult)[1]
    return NaN
  end
  for i = 1:1:count
      if result[i] == expectedResult[i]
          sum = sum + 1
      end
      #        if result[i] > 0 
      #            println(result[i], i)
      #        end
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
    path1 = "scripts/" * recordName * "ECG.txt"
    penalties = [5, 10, 20, 50, 100, 200, 500, 1000]
    #penalties = [20, 50]
    #   ['(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N', '(AFIB', '(N']
    #[    104 2162708 2163556 4057942 4062020 4387405 4400369 5497141 5500961 5586022 5587002 5593100 5596162 5707701 5712201 5764404 5766060 6484710 6567195 6598300 6602555 7405319 7406544]
    #penalties = [20, 50]

    ar1 = readdlm(path1, Float64)[start_position:end_position, :]
    df = DataFrame(ar1, :auto)
    freqDc = extractFFT(df, binSize = 16, binOverlap = 2)

    lower = AFevent_start - start_position
    upper = AFevent_end - start_position
    hmmDc = Dict{String,HMM}()
end
# julia .\src\CheckMindReaderFFt.jl 05261 2162708 2163556 2158708 2166556
begin
    for penalty in penalties
        for (κ, υ) in freqDc

            # add channel patch
            if κ == "-"
                continue
            end
            freqAr = shifter(υ)
            ###########################################################################################

            begin
                # TODO: add hmm iteration settings
                hmmParams = HMMParams(
                    penalty = penalty,
                    distance = euclideanDistance,
                    minimumFrequency = 20,
                    verbosity = false,
                )
                # setup
                aErr = permutedims(hcat(freqAr...))
                hmm = setup(aErr)

                # process
                for _ ∈ 1:4
                    _ = process!(hmm, aErr, true; params = hmmParams)
                end

                # final
                for _ ∈ 1:2
                    _ = process!(hmm, aErr, false; params = hmmParams)
                end

                # record hidden Markov model
                hmmDc[κ * " " * string(penalty)] = hmm
            end

            ####################################################################################################

        end
    end

    for (κ, u) ∈ hmmDc
      #  print("SIZE OF ")
      #  println(size(u.traceback))
        labelVc = zeros(Int, size(u.traceback)[1])

        for q = 0:1:size(u.traceback)[1]
            i = q * 8
            if i > lower && i < upper
                labelVc[q] = 1
            end
        end
        traceback1 = u.traceback
        traceback1[traceback1.>1] .= 2
        # TODO: Fix MindReader
        traceback1 .= traceback1 .- 1

        result = performance(traceback1, labelVc)
        result["Penalty"] = parse(Int64, split(κ, " ")[2])
        result["Accuracy2"] = calculateAccuracy(traceback1, labelVc)
        result["AF_Accuracy"] = calculateAFEvents(traceback1, labelVc)
        
        println(result)
    end

end
