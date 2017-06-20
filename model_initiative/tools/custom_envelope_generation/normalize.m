function out = normalize(signal,max_value)
if(exist('max_value'))
out=signal*(1/max(max(signal)))*max_value;
else
out=signal*(1/max(max(signal)));
end