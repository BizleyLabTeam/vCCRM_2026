function y = rms(s)
% this version works for aribitrary number of channels,
% but assumes waves go down the columns
y = norm(s(:,1))/sqrt(length(s(:,1)));

%% Is it stereo? -- if so, calculate rms for other channel
n=size(s);
for k=2:n(2)
    y = [y norm(s(:,k))/sqrt(length(s(:,k)))];
end
