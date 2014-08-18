clear all

whos

folder = fullfile('..', 'data', 'series30greenOUT');
ds = DataStore(folder);


ds.getDots(20);

ds.getDots(20, 2);

ds.getDots(20, [1 3]);

ds.getDescriptors(20);

ds.getDescriptors(20, 3:4);

ds.getDescriptors(20, 3);

[d1, d2] = ds.get(20);

[d1, d2] = ds.get(20, 1:2);

[d1, d2] = ds.get(20, 3);
