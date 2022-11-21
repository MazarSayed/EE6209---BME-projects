clear;
clc;
close all;

[y,Fs] = audioread('wave.wav');

 %sound(y,Fs);

%% filter 
[bb1,aa1]=butter(6,[1284,300]/(Fs/2),'bandpass'); % Bandpass filter
[bb2,aa2]=butter(6,[6099.5,1845.5]/(Fs/2),'bandpass'); % Bandpass filter
%plot filter1
figure(1);
freqz(bb1,aa1);
subplot(2,1,1);
ylim([-100 20]);
%plot filter2
figure(2);
freqz(bb2,aa2);
subplot(2,1,1);
ylim([-100 20]);

%% filtering
fsignal1 = filter(bb1,aa1,y);
fsignal2 = filter(bb2,aa2,y);
fsignal = horzcat(fsignal1,fsignal2);
%% Full wave rectification
rec_signal = zeros(length(fsignal),2);
for i=1:2
    rec_signal(:,i)=abs(fsignal(:,i));
end

%% envelop detection
envelope = zeros(length(fsignal1),2);
Fs = 1/(t(2)-t(1));
 t  = fsignal(:,1)./Fs;
window=20;

for i = 1:2
    envelope(:,i)= sqrt(movmean((rec_signal(:,i).^2),window));

    subplot(2,1,i)
    plot(t,rec_signal(:,i));
    hold on
    
    plot(t,envelope(:,i),'r','linewidth',2);
    xlim([5 20]);
    xlabel('Time(s)');
    ylabel('voltage(v)');
    grid
    hold off
end

%% Channel_quantizer
bit=4;
for i=1:2
    quantized_data = zeros(length(envelope),2);
    div = 2 ^ bit;
    if length(envelope) == 0
        return 
    else 
        Max = max(envelope);
        Min = min(envelope);
        diff = (Max - Min)/div;
        for j = 1: length(envelope)
             n =round((envelope(j) - Min)/diff);
             quantized_value = Min + diff*n;
             quantized_data = [quantized_data,quantized_value];
        end
         subplot(2,1,i)
         plot(t,quantized_data(:,i));
%          xlim([5 20]);
         xlabel('Time(s)');
         ylabel('voltage(v)');
    end
end   
    