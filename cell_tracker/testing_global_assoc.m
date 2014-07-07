Q = [
	'init 1  ' ;...
	'1 -> 2  ' ;...
	'1 -> 3  ' ;...
	'term 3  ' ;...
	'init 4  ' ;...
	'4 -> 5  ' ;...
	'4 -> 6  ' ;...
	'4 -> 5,6' ;...
	'5 -> 7  ' ;...
	'term 6  ' ;...
	'term 7  ' ;...
	'fp 1    ' ;...
	'fp 2    ' ;...
	'fp 3    ' ;...
	'fp 4    ' ;...
	'fp 5    ' ;...
	'fp 6    ' ;...
	'fp 7    ' ;...
	'init 2  ' ;...
	'init 3  ' ;...
	'init 5  ' ;...
	'init 6  ' ;...
	'init 7  ' ;...
	'term 1  ' ;...
	'term 2  ' ;...
	'term 4  ' ;...
	'term 5  ' ;...
	'4 -> 2  ' ;...
	'4 -> 7  ' ;...
	'4 -> 3  ' ;...
	'1 -> 7  ' ;...
	'2 -> 7  ' ;...
];

P = [
0.7
0.9
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
0.4
0.3
0.2
0.15
0.3
0.1
0.4
0.05
0.4
0.01
0.15
0.02
0.1
0.08
];


C = zeros(size(P, 1), 14);

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
19 9;
20 10;
21 12;
22 13;
23 14;
24 1;
25 2;
26 4;
27 5;
28 4;
28 2+7;
29 4;
29 7+7;
30 4;
30 3+7
31 1; 
31 7+7;
32 2;
32 7+7;
];

assert(numel(unique(I(:, 1))) == size(C, 1))


for i=1:size(I, 1)
	C(I(i, 1), I(i, 2)) = 1;
end


numRows = size(P, 1);
numVars = size(C, 2);

% Observa what happens if there are many empty rows... do they affect the speed
% of the linear program solver?

nDummy = 20000;
P = [P; zeros(nDummy, 1)];
C = [C; zeros(nDummy, numVars)];
size(C)
size(P)
bar = ones(numRows, 1) * ' | ';

numVars = size(C, 2);
numRows = size(C, 1);


iters = 50;
C = sparse(C);
t = cputime;
tic
options = optimoptions('intlinprog', 'Display', 'off');
for i=1:iters
	xsol = intlinprog(-P, 1:numVars, [],[], C', ones(numVars, 1), zeros(numRows,1), ones(numRows, 1), options);
end
cputime - t
toc


% [xsol * 62 num2str(P) bar Q bar C(:, 1:7)*49 bar C(:, 8:end)*49 bar]
% Q(find(xsol), :)