analysis_dir = uigetdir();
dir_struct = dir(analysis_dir);
dir_struct = dir_struct(3:end);
len = length(dir_struct);
for i=1:len
    filename = dir_struct(i).name;
    filepath = fullfile(analysis_dir, filename);
    load(filepath);
    sz = size(DataToSave.CombinedAnalyzedTraceData);
    for j=1:sz(2)
        if strcmp(DataToSave.CombinedAnalyzedTraceData(j).Designation, 'Fuse')
            fuseFrame = DataToSave.CombinedAnalyzedTraceData(j).FusionData.FuseFrameNumbers;
            tInterval = DataToSave.CombinedAnalyzedTraceData(j).FusionData.TimeInterval;
            DataToSave.CombinedAnalyzedTraceData(j).FusionData.pHtoFusionTime = ...
                tInterval * (fuseFrame - DataToSave.CombinedAnalyzedTraceData(j).FusionData.pHDropFrameNumber);
        end
    end
    save(filepath, 'DataToSave');
end
