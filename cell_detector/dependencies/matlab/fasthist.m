function [no] = fasthist(data, edges)
%HIST  Histogram for simple vectors
% This is a faster replacement for hist, that does not check all the variables and stuff

data = data(:);
binwidth = diff(edges);
edges = [-Inf, edges(1:end-1)+binwidth/2, Inf];
edgesc = edges + eps(edges); 
edgesc(1) = -Inf; 
edgesc(end) = Inf; 
nn = histc(data,edgesc,1);
nn(end-1,:) = nn(end-1,:)+nn(end,:); 
nn = nn(1:end-1,:);
no = nn';