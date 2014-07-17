classdef DataStore
	% DataStore Store for dots and desciptors. Manage all possible access to the
	% data through this store
	% Usages:
	% 			DS = DataStore(folderPath)
	% 			DS.get(frameNumber, [cellIndices])
	% 			DS.getDots(frameNumber, [cellIndices])
	% 			DS.getDescriptors(frameNumber, [cellIndices])
	% For example usage see data_store_example.m

	properties(SetAccess = private, GetAccess = private)
		dataFolder  % Folder containing mat files with descriptors
		dotsCache
		descriptorsCache
		filePathsCache
		imPrefix = 'im';
		imDigets = 3;  % load from outside
		verbose = true;
 	end

	methods
		function obj = DataStore(dataFolder, verbose)
			obj.dataFolder = dataFolder;

			obj.dotsCache = containers.Map('KeyType','uint32','ValueType', 'any');
			obj.descriptorsCache = containers.Map('KeyType','uint32',...
				'ValueType', 'any');
			obj.filePathsCache = containers.Map('KeyType', 'uint32',...
				'ValueType', 'char');

			if nargin > 1
				obj.verbose = verbose;
			end
			% TODO Precompute file names because fullfile is too slow otherwise
		end

		function [dots, descriptors] = get(obj, frameNumber, cellIndices)
			% Returns the dots and descriptor of cells indicated by cellIndices in frame
			% frameNumber
			if nargin == 3
				dots = obj.getDots(frameNumber, cellIndices);
				descriptors = obj.getDescriptors(frameNumber, cellIndices);
			else
				dots = obj.getDots(frameNumber);
				descriptors = obj.getDescriptors(frameNumber);
			end
		end

		function p = frameFile(obj, frameNumber)
			% Return the name of the mat file of frameNumber
			if isKey(obj.filePathsCache, frameNumber)
				p = obj.filePathsCache(frameNumber);
			else
				fmt = ['im%0' num2str(obj.imDigets) 'd.mat'];
				imName = sprintf(fmt, frameNumber);
				p = fullfile(obj.dataFolder, imName);
				obj.filePathsCache(frameNumber) = p;
			end
		end

		function dots = getDots(obj, frameNumber, cellIndices)
			% Returns the dots of cells indicated by cellIndices in frame frameNumberd

			if isKey(obj.dotsCache, frameNumber)
				dots = obj.dotsCache(frameNumber);
			else
				if obj.verbose;
					fprintf('GETDOTS:       Accessing %s on disk\n', obj.frameFile(frameNumber));
				end
				data = load(obj.frameFile(frameNumber));
				dots = data.dots;
				obj.dotsCache(frameNumber) = dots;
			end

			if nargin == 3
				dots = dots(cellIndices, :);
			end
		end

		function descriptors = getDescriptors(obj, frameNumber, cellIndices)
			% Returns the descriptors of cells indicated by cellIndices in frame frameNumber
			if isKey(obj.descriptorsCache, frameNumber)
				descriptors = obj.descriptorsCache(frameNumber);
			else
				if obj.verbose;
					fprintf('GETDETECTIONS: Accessing %s on disk\n', obj.frameFile(frameNumber));
				end
				data = load(obj.frameFile(frameNumber));
				if isfield(data, 'descriptors')
					descriptors = data.descriptors;
					obj.descriptorsCache(frameNumber) = descriptors;
				else
					error('No key "descriptors" in %s', obj.frameFile(frameNumber));
				end
			end

			if nargin == 3
				descriptors = descriptors(cellIndices, :);
			end
		end

		function sizes = size(obj)
			sizes = struct(...
				'dots', size(obj.dotsCache),...
				'descriptors', size(obj.descriptorsCache),...
				'filepaths', size(obj.filePathsCache)...
			);
		end
	end
end