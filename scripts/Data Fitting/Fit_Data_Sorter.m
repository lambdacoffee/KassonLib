function [AllResults,ResultsReport,FigureHandles] = ...
    Fit_Data_Sorter(CumX,CumYDecayNorm,CumYNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults)

% Limit the data points that we will try to fit to
% IndexToUse = CumX > 10;
% CumX = CumX(IndexToUse);
% CumYNorm = CumYNorm(IndexToUse);
% CumYDecayNorm = CumYDecayNorm(IndexToUse);

FitTypes = UsefulInfo.FitTypes;
FitMethods = UsefulInfo.FitMethods;
NumberFitsToPerform = UsefulInfo.NumberFitsToPerform;

% Compile results independent of fits
ResultsReport(FileNumber).Name=UsefulInfo.Name;
ResultsReport(FileNumber).MeanpHtoFuse= UsefulInfo.MeanFusion1Time;
ResultsReport(FileNumber).PercentFuse1 = UsefulInfo.PercentFuse1;
ResultsReport(FileNumber).PercentAnyFusion = UsefulInfo.PercentAnyFusion;
ResultsReport(FileNumber).NumVirus=UsefulInfo.NumberDataPoints;


for FitNumber = 1:NumberFitsToPerform
    if iscell(FitTypes)
        CurrentFitType= FitTypes{1,FitNumber};
    else
        CurrentFitType= FitTypes;
    end
    
    if iscell(FitMethods)
        CurrentFitMethod = FitMethods{1,FitNumber};
    else 
        CurrentFitMethod = FitMethods;
    end
    
    % Change color as we go along
        UsefulInfo.FitNumber = FitNumber;
        UsefulInfo.CurrentFitMethod = CurrentFitMethod;
        [CurrentColor]=Choose_Color(UsefulInfo);
        
    if strcmp(CurrentFitType, '1 Exp')
%         [ResultsReport] = Single_Exp(SortedpHtoFList,CumX,CumYDecayNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo);

    elseif strcmp(CurrentFitType, '1 Exp W Lag')
        [AllResults,ResultsReport] = Single_Exp_W_Lag(CumX,CumYDecayNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults);

    elseif strcmp(CurrentFitType, 'Gamma')
        [AllResults,ResultsReport] = Gamma(CumX,CumYNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults);
    elseif strcmp(CurrentFitType, 'Gamma W Lag')
        [AllResults,ResultsReport] = Gamma_W_Lag(CumX,CumYNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults);
    elseif strcmp(CurrentFitType, '2 Gamma')
        [AllResults,ResultsReport] = Double_Gamma(CumX,CumYNorm,FigureHandles,CurrentColor,...
            FileNumber,ResultsReport,UsefulInfo,Options,AllResults);
    elseif strcmp(CurrentFitType, '2 Exp')
        [AllResults,ResultsReport] = Double_Exp(CumX,CumYDecayNorm,FigureHandles,...
            CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults);
    elseif strcmp(CurrentFitType, '1 Exp + Constant')
%         [ResultsReport] = Single_Exp_Plus_Constant(SortedpHtoFList,CumX,CumYDecayNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo);
    end

end
        
if strcmp(Options.RunBootstrap,'y') && strcmp(AllResults(FileNumber).TypeOfInputData,'Normal CDF-Improved Analysis')
    WaitingTimeList = AllResults(FileNumber).CDFData.SortedpHtoFList;
    
    [AllResults] = Calculate_Bootstrap_Confidence_Intervals(CumX,CumYNorm,FigureHandles,CurrentColor,...
        AllResults,WaitingTimeList,Options);
end
end
