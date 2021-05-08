%% amp mod
Fs = 22400;
t=0:1/Fs:0.96;

frqHz = 400;
ampcarrier = 1;
messagesignal = sin(2*pi*5*t);
signofcarrier = sin(2*pi*frqHz*t);

x=2*(ampcarrier+messagesignal).*signofcarrier;
plot(x)
sound(x,Fs);

audiowrite('AmpMod.wav',x,Fs)
