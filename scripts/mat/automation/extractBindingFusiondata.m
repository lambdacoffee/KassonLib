function [BFtimes,CumX,CumY,UsefulInfo] = extractBindingFusiondata(InputData, UsefulInfo)
    AnalyzedTraceData = InputData.DataToSave.CombinedAnalyzedTraceData;
    nTraces = length(AnalyzedTraceData);
    numFuse = 0;
    numFuseplot = 0;
    numNoFuse = 0;
    bindingToFusionList = [];
    
    for n = 1:nTraces
        CurrentFusionData = AnalyzedTraceData(n).FusionData;
        if strcmp(AnalyzedTraceData(n).ChangedByUser,'Incorrect Designation-Not Changed')
            % The designation is wrong, but has not been corrected, so we will skip it.
            disp('Some designations have been previously flagged as incorrect, but have not yet been changed, and so have been skipped.')
        else
            if strcmp(CurrentFusionData.Designation,'No Fusion')
                numNoFuse = numNoFuse + 1;
            elseif strcmp(CurrentFusionData.Designation,'1 Fuse')
                if strcmp(AnalyzedTraceData(n).ChangedByUser,'Reviewed By User') ||...
                        strcmp(AnalyzedTraceData(n).ChangedByUser,'Not analyzed') ||...
                        strcmp(AnalyzedTraceData(n).ChangedByUser,'Analyzed')
                    numFuse = numFuse + 1;
                    numFuseplot = numFuseplot + 1;
                    bindingToFusionList(numFuseplot) = ...
                        CurrentFusionData.bindingToFusionTime;
                else
                    % We Can't Necessarily Trust The Wait Time
                    numFuse = numFuse + 1;
                end
            end
        end
    end

    BFtimes = sort(bindingToFusionList);

    auto_dir = cd;
    cd ..
    mat_scripts_subdir = cd;
    data_fitting_subdir = fullfile(mat_scripts_subdir, 'Data_Fitting');
    cd(data_fitting_subdir);

    %Change to real cumulative distribution function (not multiple
    %data points at repeated time points)
    if ~isempty(BFtimes)
        [CumX, CumY] = Generate_Prop_Cum(BFtimes);
    else
        CumX = 0; 
        CumY = 0;
    end
    
    NumberTotalAnalyzed = numFuse + numNoFuse;
        
    UsefulInfo.NumberTotalAnalyzed = NumberTotalAnalyzed;
    UsefulInfo.NumberDataPoints = length(BFtimes);
    UsefulInfo.MeanFusion1Time = mean(BFtimes);
    UsefulInfo.PercentFuse = numFuse/NumberTotalAnalyzed;
end
