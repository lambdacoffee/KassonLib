function fixFusionData()
    [filenames_arr, parpath] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');
    for j=1:length(filenames_arr)
            if length(filenames_arr) > 1
                filename = filenames_arr{j};
            else
                filename = filenames_arr(1);
            end
        mat_filepath = fullfile(parpath, filename);
        dat = load(mat_filepath);
        DataToSave = dat.DataToSave;
        len = length(DataToSave.CombinedAnalyzedTraceData);
        for i=1:len
            curr_trace = DataToSave.CombinedAnalyzedTraceData(i);
            curr_trace.TimeInterval = curr_trace.FusionData.TimeInterval;
            fd = curr_trace.FusionData;
            DataToSave.CombinedAnalyzedTraceData(i).TimeInterval = fd.TimeInterval;
            if strcmp(curr_trace.Designation, 'Fuse')
                DataToSave.CombinedAnalyzedTraceData(i).isFusion = 1;                
                fusionEndFrameNum = fd.FuseFrameNumbers;
                fusionStartFrameNum = floor(fusionEndFrameNum - ...
                    (fd.FusionInterval / fd.TimeInterval));
                fd.pHtoFusionTime = (fusionStartFrameNum - ...
                    fd.pHDropFrameNumber) * fd.TimeInterval;
            else
                DataToSave.CombinedAnalyzedTraceData(i).isFusion = 0;
            end
        end
        dst_filepath = fullfile(parpath, strcat("fixed_", filename));
        save(dst_filepath, 'DataToSave');
    end
end
