begin
    using MindReader
    using DelimitedFiles
end

begin 
    actualLabels = [0, 0, 0, 1, 1]
    predictions = [0, 0, 0, 0, 1]
    writedlm(stdout, MindReader.adjustFq(predictions, actualLabels, [0, 1]))
end

begin
    print("================\n")
    actualLabels = [0, 0, 0, 0, 1]
    predictions = [0, 0, 0, 1, 1]
    writedlm(stdout, MindReader.adjustFq(predictions, actualLabels, [0, 1]))
end 