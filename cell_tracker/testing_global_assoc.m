P = [
0.7
0.8
0.8
0.8
0.9
0.5
0.6
0.6
0.7
0.8
0.8
0.2
0.8
0.3
0.15
0.2
0.1
0.1
];

C = zeros(18, 14);

I = [
1 8;
2 1;
2 9;
3 1;
3 10;
4 3;
5 11;
6 4;
6 12;
7 4;
7 13;
8 4;
8 12;
8 13;
9 5;
9 14;
10 6;
11 7;
12 1;
13 2;
12 8;
14 3;
13 9;
15 4;
14 10;
16 5;
15 11;
16 12;
17 6;
17 13;
18 7;
18 14;
];
for i=1:size(I, 1)
	C(I(i, 1), I(i, 2)) = 1;
end

iters = 1;

t = cputime;
tic
options = optimoptions('intlinprog', 'Display', 'off');
numCols = size(P, 1);
numVars = size(C, 2);
xsol = intlinprog(-P, 1:numVars, [],[], C', ones(numVars,1), zeros(numCols,1), ones(numCols, 1), options);
cputime - t
toc