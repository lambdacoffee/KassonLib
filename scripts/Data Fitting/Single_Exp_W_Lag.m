function [AllResults,ResultsReport] = Single_Exp_W_Lag(CumX,CumYDecayNorm,FigureHandles,CurrentColor,FileNumber,ResultsReport,UsefulInfo,Options,AllResults)


NumberDataPoints = ResultsReport(FileNumber).NumVirus;
CumYNorm = max(CumYDecayNorm) - CumYDecayNorm;

    % Set up bounds and initial guesses. [Amplitude,Tau,Lag time]
    Low_Bounds = [.99,1e-6,0];
    Up_Bounds = [1.01,max(CumX),max(CumX)/2];
    Init_Guess = [1,ResultsReport(FileNumber).MeanpHtoFuse,10];
    
if strcmp(UsefulInfo.CurrentFitMethod,'Max Like')
    FitName = '---1 Exp W Lag MLE---';
    OptimizationOptions = optimset('TolX', 1e-6,'TolFun', 1e-9,'Algorithm', 'interior-point','Display','off');

    [FitValues,LogLike, ExitFlag] = fmincon(@Single_EXP_W_Lag_MLE_Model,Init_Guess,[],[],[],[],...
        Low_Bounds,Up_Bounds,[],OptimizationOptions,CumX,CumYDecayNorm,NumberDataPoints);
    LogLike = -LogLike;
    
elseif strcmp(UsefulInfo.CurrentFitMethod,'Least Squares')
    FitName = '----1 Exp W Lag LSQ----';
    OptimizationOptions = optimset('Display','off','TolFun',1e-9);

   [FitValues, ResNorm, Resid_sglwlag, ExFlag, Output, Lagrange, Jacob_sglwlag]...
       = lsqnonlin(@Single_Exp_W_Lag_LSQ_Model,Init_Guess,Low_Bounds,...
       Up_Bounds,...
       OptimizationOptions,CumX,CumYDecayNorm,NumberDataPoints); %this line is ex params
   LogLike = NaN;

%    Conf_Int_sglwlag = nlparci(FitValues,Resid_sglwlag,'Jacobian',Jacob_sglwlag,...
%        'alpha',Conf_Level);
else
    disp(' Error, wrong fit method chosen')
end


    %  Plot CDF and fit line
    if UsefulInfo.FitNumber == 1
        set(0,'CurrentFigure',FigureHandles.FitWindow)
        hold on
        plot(CumX,CumYNorm,CurrentColor.DataPoints);
    end
    
        FitLine = ones(size(CumX));
        IndextoUse = CumX >= FitValues(3);
        FitLine(IndextoUse) = FitValues(1)*exp(-(CumX(IndextoUse)-FitValues(3))./FitValues(2));
        FitLine = max(FitLine) - FitLine;
        set(0,'CurrentFigure',FigureHandles.FitWindow)
        hold on
        plot(CumX,FitLine,CurrentColor.FitLine,'LineWidth',2)

        %R squared calculation
        MeanData = mean(CumYNorm);
        SST = sum((CumYNorm-MeanData).^2);
        SSE = sum((CumYNorm-FitLine).^2);
        R2 = 1-SSE/SST;
        Residuals = CumYNorm-FitLine;

        %Plot residuals
        set(0,'CurrentFigure',FigureHandles.ResidualsWindow)
        hold on
        plot(CumX,Residuals,CurrentColor.ResidualPoints);
        
        %AIC calculation
            NumberofParameters = length(FitValues) - 1;
                %We don't include the amplitude in the number of
                %parameters, since we have fixed that at 1
            NumberPointsinFit = length(CumX);
            AIC = 2*NumberofParameters - 2*LogLike;
%                 [AIC, BIC] = aicbic(LogLike,NumberofParameters,NumberPointsinFit);
%                 AICC = AIC - (2*NumberofParameters*(NumberofParameters+1)/(NumberPointsinFit-NumberofParameters-1));


                ParameterMatrix = cell(2,length(FitValues));
                    ParameterMatrix{1,1} ='LagTime';
                    ParameterMatrix{1,2} ='Tau';
                    ParameterMatrix{1,3} ='R2';
                    
                    ParameterMatrix{2,1} =FitValues(3);
                    ParameterMatrix{2,2} =FitValues(2);
                    ParameterMatrix{2,3} =R2;
                    
                FitStatsMatrix = cell(1,3);
                    FitStatsMatrix{1,1} =AIC;
                    FitStatsMatrix{1,2} =LogLike;
                    FitStatsMatrix{1,3} =R2;
                    
                FitNumber = UsefulInfo.FitNumber;
                    AllResults(FileNumber).FitResults(FitNumber).ParameterMatrix = ParameterMatrix;
                    AllResults(FileNumber).FitResults(FitNumber).FitStatsMatrix = FitStatsMatrix;
                    AllResults(FileNumber).FitResults(FitNumber).FitType=FitName;
                    AllResults(FileNumber).FitResults(FitNumber).Lagtime=FitValues(3);
                    AllResults(FileNumber).FitResults(FitNumber).Tau=FitValues(2);
                    AllResults(FileNumber).FitResults(FitNumber).LogLike= LogLike;
                    AllResults(FileNumber).FitResults(FitNumber).AIC= AIC;
                    AllResults(FileNumber).FitResults(FitNumber).R2=R2;
%                     
%         if UsefulInfo.FitNumber == 1
%             ResultsReport(FileNumber).FitType= FitName;
%             ResultsReport(FileNumber).Lagtime=FitValues(3);
%             ResultsReport(FileNumber).Tau=FitValues(2);
%             ResultsReport(FileNumber).LogLike1 = LogLike;
%             ResultsReport(FileNumber).AIC1 = AIC;
%             ResultsReport(FileNumber).R2=R2;
%         elseif UsefulInfo.FitNumber == 2
%             ResultsReport(FileNumber).FitType2=FitName;
%             ResultsReport(FileNumber).Lagtime2=FitValues(3);
%             ResultsReport(FileNumber).Tau2=FitValues(2);
%             ResultsReport(FileNumber).LogLike2= LogLike;
%             ResultsReport(FileNumber).AIC2 = AIC;
%             ResultsReport(FileNumber).R2_2=R2;
%         elseif UsefulInfo.FitNumber == 3
%             ResultsReport(FileNumber).FitType3=FitName;
%             ResultsReport(FileNumber).Lagtime3=FitValues(3);
%             ResultsReport(FileNumber).Tau3=FitValues(2);
%             ResultsReport(FileNumber).LogLike3= LogLike;
%             ResultsReport(FileNumber).AIC3 = AIC;
%             ResultsReport(FileNumber).R2_3=R2;
%         elseif UsefulInfo.FitNumber == 4
%             ResultsReport(FileNumber).FitType4=FitName;
%             ResultsReport(FileNumber).Lagtime4=FitValues(3);
%             ResultsReport(FileNumber).Tau4=FitValues(2);
%             ResultsReport(FileNumber).LogLike4= LogLike;
%             ResultsReport(FileNumber).AIC4 = AIC;
%             ResultsReport(FileNumber).R2_4=R2;
%         else
%             disp(' Error: you chose too many fits to compare')
%         end
%         
        AllResults(FileNumber).ResultsReport = ResultsReport(FileNumber);
end

function LogLike = Single_EXP_W_Lag_MLE_Model(p,CumX,CumY,NumberDataPoints)
    x=CumX;
    n=NumberDataPoints;
    y=n*CumY;
    lagtime =p(3);
     
    %Model
    Prob = ones(size(x));
    IndextoUse = x >= lagtime;
    
    Prob(IndextoUse) = p(1)*exp(-(x(IndextoUse)-lagtime)./p(2));
        Prob = Prob + (Prob == 0).*1e-5 - (Prob==1).*1e-5; %Ensure 0<Prob<1
    
    %Log Likelihood
    LogLike = (-1)*(y.*log(Prob)+(n-y).*log(1-Prob));
    LogLike = sum(LogLike);
end

function [Error] = Single_Exp_W_Lag_LSQ_Model(p,x,Data,lSpHtoF)

%     Fit = Single_Exp_w_lagnew(p,x,lSpHtoF);
    lagtime =p(3);
    Fit = ones(size(x))*lSpHtoF;
    IndextoUse = x >= lagtime;
    Fit(IndextoUse) = p(1)*exp(-(x(IndextoUse)-lagtime)./p(2));
    
    Error = (Data - Fit);

end