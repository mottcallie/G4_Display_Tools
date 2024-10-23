% coherent_pathgenerator.m
% Generates coherent (smooth) 2D noise for presenting an object with
% pseudorandomized motion on display arenas.
%
% INPUTS:
%   n - Length of the generated path.
%   amp - Amplitude of the noise.
%   funcFreq - Frequency to interpolate the path to.
%
% OUTPUT:
%   path - Generated object path for pattern function.
%
% Created: 08/05/2022 - MC
%
function  path = coherent_pathgenerator(n,amp,funcFreq)
%% important variables
% can adjust these variables to adjust path smoothing

smoothNoise = 1.9; %increase to increase gaussian smoothing

%% generate random white noise
b = 50;
buff = zeros(1,b);
nb = n+b*2; %add buffer to start/end

% random integers within specified interval
%whitenoise = randi([amp*-1 amp],1,nb); %opt1: rand int
whitenoise = randn(1,n)*amp; %opt2: rand normal distribution
whitenoise = [buff whitenoise buff];

%% smooth white noise
smoothnoise=smoothdata(whitenoise,'gaussian',smoothNoise);

%% interpolate smoothed noise
x = 1:1:nb;
xi = 1/funcFreq:1/funcFreq:nb;

intnoise = interp1(x,smoothnoise,xi,'spline');
% interpolating often generates artifacts at start/end
intnoise(1:b*funcFreq) = []; %remove buffer at start
intnoise(end-b*funcFreq+1:end) = []; %remove buffer at end

%% store final path
path = intnoise;

end

