begin
    using HiddenMarkovModelReaders
    using MindReader
    using DelimitedFiles
    using StatsBase
    using DataFrames
end;




begin
    #         N    AF        N        AF      N        AF       N            
    #array([ 30,  102584,  119604,  121773,  122194,  133348,  166857,    1096245, 1098054, 1135296, 1139595, 1422436, 1423548, 1459277,    1460416]
    # 'sample': array([      7, 1381607, 1383575, 1387965, 1389204, 1399238, 1856046,        1864114, 3789346, 3793222, 6274349], dtype=int64)
    path1 = "scripts/06995ECG.txt"
    penalties = [5, 10, 20, 50, 100, 200, 500, 1000]
    #penalties = [20, 50]
    
    ar1 = readdlm(path1, Float64)[1:250000, ]
    df = DataFrame(ar1, :auto)
    freqDc = extractFFT(df, binSize = 16, binOverlap = 2)

    hmmDc = Dict{String, HMM}()

    for (κ, υ) in freqDc
  
      # add channel patch
      if κ == "-" continue end
      freqAr = shifter(υ)
      print()
      @info κ
    ###########################################################################################
  
      begin
        # TODO: add hmm iteration settings
        @info "Creating Hidden Markov Model..."
        hmmParams = HMMParams(
            penalty = 20,
            distance = euclideanDistance,
            minimumFrequency = 20,
            verbosity = false,
        )
        # setup
        aErr = hcat(freqAr...)
        print(size(aErr))
        hmm = setup(aErr)
  
        # process
        for _ ∈ 1:4
          _ = process!(
              hmm,
              aErr,
            true;
            params = hmmParams,
          )
        end
  
        # final
        for _ ∈ 1:2
          _ = process!(hmm, aErr, false; params = hmmParams,)
        end
  
        # record hidden Markov model
        hmmDc[κ] = hmm
      end
  
      ####################################################################################################
  
    end
  
    print()

  for (κ, u) ∈ hmmDc
        print(size(u.traceback))
        labelVc = ones(Int, size(u.traceback)[1])
        for q in 0:1:size(u.traceback)[1]
          i = q * 8 
          if i > 102584 && i < 119604
            labelVc[q] = 2
          end
          if i > 121773 && i < 122194
            labelVc[q] = 2
          end
          if i > 133348 && i < 166857
            labelVc[q] = 2
          end
          if i > 133348 && i < 166857
            labelVc[q] = 2
          end
        end 
        print(performance(u.traceback, labelVc))      
    end

    print(size(ar1))
end