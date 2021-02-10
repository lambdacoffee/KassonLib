function [FitValues,R2] = Single_Exp_Plus_Constant(SortedpHtoFList,CumX,CumYDecayNorm,FitWindow,CurrentColor,ResidualsWindow)

NumberDataPoints = length(SortedpHtoFList);

        Options = optimset('TolX', 1e-6,'TolFun', 1e-6,'Algorithm', 'interior-point');
        Low_Bounds = [1e-6,1e-6,-1];
        Up_Bounds = [2,max(CumX),1];
        Init_Guess = [1,mean(SortedpHtoFList),0];

        [FitValues,LikeValue, ExitFlag] = fmincon(@Single_Exp_Plus_MLE,Init_Guess,[],[],[],[],...
            Low_Bounds,Up_Bounds,[],Options,CumX,CumYDecayNorm,NumberDataPoints);

            p1=FitValues;
            Fit = p1(1)*exp(-CumX./p1(2))-p1(3);
            plot(CumX,Fit,'k-','LineWidth',2)
            %Comparison to mean
                MeanExp = exp(-CumX./mean(SortedpHtoFList));
                plot(CumX,MeanExp,'r-','LineWidth',2)

                %R squared calculation
                MeanData = mean(CumYDecayNorm);
                SST = sum((CumYDecayNorm-MeanData).^2);
                SSE = sum((CumYDecayNorm-Fit).^2);
                R2 = 1-SSE/SST;
                Residuals = CumYDecayNorm-Fit;

        FitValues_Fit = p1;
        R2_Fit = R2;
end


function LogLike = Single_Exp_Plus_MLE(p,CumX,CumY,NumberDataPoints)
    x=CumX;
    n=NumberDataPoints;
    y=n*CumY;
    
    %Model
    Prob = p(1)*exp(-x./p(2))-p(3);
        %Prob = Prob + (Prob == 0).*1e-5 - (Prob==1).*1e-5; %Ensure 0<Prob<1
    
    %Log Likelihood
    LogLike = (-1)*(y.*log(Prob)+(n-y).*log(1-Prob));
    LogLike = sum(LogLike);
end
