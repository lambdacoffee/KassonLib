function [IsParticleGood, ReasonParticleFailed] = ApplyNegScreen(...
    ParticleProperties, BinaryCurrImage, NegImage, ImageWidth, ImageHeight,...
    IsParticleGood, ReasonParticleFailed, Options)
% Apply Negative Screen
% This code is templated on Simplified_Test_Goodness
% Currently eliminates a particle if the intersection over union (IoU)
% of the main channel versus the negative-screen channel is greater than
% a static threshold, currently 40%.
% Code by Peter Kasson, 2019.

thresh = 0.1;

CurrParticleCentroid = (ParticleProperties.Centroid);
CurrParticleXCenter = CurrParticleCentroid(1); 
CurrParticleYCenter = CurrParticleCentroid(2);
AreaForROI = max([ParticleProperties.Area, (Options.MinROISize)^2]);
if ~isnan(Options.MaxROISize)
   if AreaForROI > (Options.MaxROISize)^2
       AreaForROI = (Options.MaxROISize)^2;
   end
end
SizeOfSquareAroundCurrParticle = (sqrt(AreaForROI)*2);
    
CurrParticleBox.Left = max([round(CurrParticleXCenter) - round(SizeOfSquareAroundCurrParticle/2),...
        1]);
CurrParticleBox.Right = min([round(CurrParticleXCenter) + round(SizeOfSquareAroundCurrParticle/2),...
        ImageWidth]);
CurrParticleBox.Top = max([round(CurrParticleYCenter) - round(SizeOfSquareAroundCurrParticle/2),...
        1]);
CurrParticleBox.Bottom = min([round(CurrParticleYCenter) + round(SizeOfSquareAroundCurrParticle/2),...
        ImageHeight]);

BinaryCroppedImage = BinaryCurrImage(CurrParticleBox.Top:CurrParticleBox.Bottom,...
        CurrParticleBox.Left:CurrParticleBox.Right);
NegCroppedImage = NegImage(CurrParticleBox.Top:CurrParticleBox.Bottom,...
        CurrParticleBox.Left:CurrParticleBox.Right);

if (sum(sum(bitand(BinaryCroppedImage, NegCroppedImage))) ...
        / sum(sum(bitor(BinaryCroppedImage, NegCroppedImage))) > thresh)
    IsParticleGood = 's';
    ReasonParticleFailed = 'negative screen';
else
    fprintf(1, '%f ', sum(sum(bitand(BinaryCroppedImage, NegCroppedImage))) ...
        / sum(sum(bitor(BinaryCroppedImage, NegCroppedImage))));
end


