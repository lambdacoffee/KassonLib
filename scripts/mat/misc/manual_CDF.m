[filenames_arr, parpath] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');

for f=1:3
    colors = [0.6350,0.0780,0.1840; 0,0.4470,0.7410; ...
        0.8500,0.3250,0.0980; 0.4660,0.6740,0.1880; ...
        0.9290,0.6940,0.1250; 0,0,0; 1,0,1];
    for j=1:length(filenames_arr)
        if length(filenames_arr) > 1
            filename = filenames_arr{j};
        else
            filename = filenames_arr(1);
        end
        tag_split = strsplit(filename, "_");
        data_label = tag_split{1};
        mat_filepath = fullfile(parpath, filename);
        dat = load(mat_filepath);
        len = length(dat.DataToSave.CombinedAnalyzedTraceData);
        s = struct();
        numFused = 0;
        numFrames = length(dat.DataToSave.CombinedAnalyzedTraceData(1).Trace);
        for i=1:len
            curr_trace = dat.DataToSave.CombinedAnalyzedTraceData(i);
            s(i).TimeInterval = curr_trace.TimeInterval;
            s(i).pHDropFrameNum = curr_trace.PHdropFrameNum;
            if strcmp(curr_trace.Designation, 'Fuse')
                s(i).isFusion = 1;
                numFused = numFused + 1;
                s(i).fusionInterval = curr_trace.FusionData.FusionInterval;
                s(i).fusionEndFrameNum = curr_trace.FusionData.FuseFrameNumbers;
                s(i).fusionStartFrameNum = floor(s(i).fusionEndFrameNum - ...
                    (s(i).fusionInterval / s(i).TimeInterval));
                s(i).pHtoFusionTime = (s(i).fusionStartFrameNum - ...
                    s(i).pHDropFrameNum) * s(i).TimeInterval;
                s(i).fusionMedianTime = (median([s(i).fusionStartFrameNum, ...
                    s(i).fusionEndFrameNum]) - s(i).pHDropFrameNum) * s(i).TimeInterval;
                s(i).fusionEndTime = (s(i).fusionEndFrameNum - ...
                    s(i).pHDropFrameNum) * s(i).TimeInterval;
            elseif strcmp(curr_trace.Designation, '1 Fuse') || ...
                    strcmp(curr_trace.Designation, 'Slow')
                % handling Gio's stuff
                s(i).isFusion = 1;
                numFused = numFused + 1;
                s(i).fusionInterval = s(i).TimeInterval;
                s(i).fusionEndFrameNum = curr_trace.FusionData.FuseFrameNumbers;
                s(i).fusionStartFrameNum = s(i).fusionEndFrameNum;
                s(i).pHtoFusionTime = (s(i).fusionStartFrameNum - ...
                    s(i).pHDropFrameNum) * s(i).TimeInterval;
                s(i).fusionMedianTime = (s(i).fusionStartFrameNum - ...
                    s(i).pHDropFrameNum) * s(i).TimeInterval;
                s(i).fusionEndTime = (s(i).fusionEndFrameNum - ...
                    s(i).pHDropFrameNum) * s(i).TimeInterval;
            else
                s(i).isFusion = 0;
                s(i).fusionInterval = 0;
                s(i).fusionEndFrameNum = 0;
                s(i).fusionStartFrameNum = 0;
                s(i).pHtoFusionTime = 0;
                s(i).fusionMedianTime = 0;
                s(i).fusionEndTime = 0;
            end
        end

        hold on;
        figure(f);
        isFusionArray = [s(:).isFusion] == 1;
        if f == 1
            event_times = [s(isFusionArray).pHtoFusionTime];
            title('pHtoFusionTimes');
        elseif f == 2
            event_times = [s(isFusionArray).fusionInterval];
            title('fusionIntervals');
        elseif f == 3
            event_times = [s(isFusionArray).pHtoFusionTime];
            title('FusionEvents');
            event_times = sort(event_times);
            norm_events = event_times - event_times(1);
            histogram(norm_events, 25);
            plot_label = strcat(data_label, eff_str);
            legend(gca, plot_label);
            legend(gca, 'off');
            continue;
        end

        event_times = sort(event_times);
        % [CumX, CumY] = Generate_Prop_Cum(event_times);  % Useless????

        CumX = event_times;
        CumY = 1:length(event_times);
        eff_str = strcat(": n = ", num2str(length(CumX)), ", \eta = ", ...
            num2str(length(CumX) / len));
        plot_label = strcat(data_label, eff_str);
        %CumYNorm = CumY / max(CumY);
        CumYNorm = CumY;
%         CumYNorm = CumYNorm * (length(CumX) / len);
        plt = plot(CumX, CumYNorm, 'o');
        plt.MarkerFaceColor = colors(j, :);
        plt.MarkerEdgeColor = colors(j, :);
        legend(plt, plot_label);
        legend(gca, 'off');
        xlim([0, max(event_times)]);
        xlabel("Time (s)");
        ylabel("Normalized Percent Fused");
    end
    legend('Location', 'southeast', 'FontSize', 12);
    legend('show');
end

function [CumX, CumY] = Generate_Prop_Cum(SortedpHtoFList)
    % Changes SortedpHtoFList to proportion hemifused over time and makes cum
    % dist(Not normalized)

    Y = 1:length(SortedpHtoFList);
    New_Pt = 0;
    
    for i = 1:length(Y)
       if i == length(Y)
           New_Pt = New_Pt + 1;
           CumX(New_Pt) = SortedpHtoFList(i);
           CumY(New_Pt) = Y(i);
           continue
       end
       if SortedpHtoFList(i) == SortedpHtoFList(i+1)
           continue
       else
           New_Pt = New_Pt + 1;
           CumX(New_Pt) = SortedpHtoFList(i);
           CumY(New_Pt) = Y(i);
       end
    end
end

