clear;
clc;
close all;

[y,Fs] = audioread('rec.mp3');
sound(y);
time  = 1:1:length(y);
figure(1)
plot(time,y);

% slope = 6; %-6dB/octave
% Fc    = 1200./(Fs/2);
% [B,A] = designVarSlopeFilter(slope,Fc,'lo','Orientation','column');  
% fvt = fvtool([B,A],Fs,"log");
% legend(fvt,"Fc = 1200 kHz","southwest");
% fsignal = filter(B,A,y);

[bb1,aa1]=butter(6,1200/(Fs/2),'low'); % lowpass filter
freqz(bb1,aa1);
[bb2,aa2]=butter(2,160/(Fs/2),'low'); % lowpass filter
freqz(bb2,aa1);
fsignal = filter(bb1,aa1,y);
figure(2)
plot(time,fsignal);


center_frequency = [366,526,757,1089,1566,2252,3241,4662];
bandwidth = [131,189,272,391,563,810,1165,1676];
channeled_signal = zeros(length(fsignal),1);

figure(3);
 for i = 1:length(center_frequency)
    [bb,aa]=butter(6,[(center_frequency(i) - bandwidth(i)),(center_frequency(i) + bandwidth(i))]/(Fs/2),'bandpass'); % Bandpass filter
    filter_signal = filter(bb,aa,fsignal);
    channeled_signal = [channeled_signal,filter_signal];
    subplot(8,1,i)  
    plot(time,channeled_signal)
    xlim([7.38*10^4 7.43*10^4]);
    
end
eightband_signal = channeled_signal(:,2:9);

%% Half wave rectification
rect_signal = zeros(length(fsignal),1);
figure(4);
for i= 1:8
    rect = eightband_signal(:,i).*(eightband_signal(:,i)>= 0);
    fil_rect = filter(bb2,aa2,rect);
    rect_signal = [rect_signal,fil_rect];
    subplot(8,1,i)  
    plot(time,fil_rect)
end
r_signal = rect_signal(:,2:9);
%% envelope
envelope = zeros(length(r_signal),1);
window=10;
figure(5)
for i = 1:8
    envelope(:,i)= sqrt(movmean((r_signal(:,i).^2),window));

    subplot(8,1,i)
    plot(time,r_signal(:,i));
    xlim([7.38*10^4 7.43*10^4]);
    hold on
    
    plot(time,envelope(:,i),'r','linewidth',2);
    xlim([7.38*10^4 7.43*10^4]);
    xlabel('Time(s)');
    ylabel('voltage(v)');
    grid
    hold off
end
    

%% combining
signal = sum(envelope,2);
[b,a] = ellip(6,10,50,5000/(Fs/2));
freqz(b,a);
Output = filter(b,a,signal);
sound(Output);


