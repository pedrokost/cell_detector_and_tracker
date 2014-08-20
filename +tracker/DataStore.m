classdef DataStore < handle
	% DataStore Store for dots and desciptors. Manage all possible access to the
	% data through this store
	% Usages:
	% 			DS = DataStore(folderPath)
	% 			DS.get(frameNumber, [cellIndices])
	% 			DS.getDots(frameNumber, [cellIndices])
	% 			DS.getDescriptors(frameNumber, [cellIndices])
	% For example usage see data_store_example.m

	properties(SetAccess = private, GetAccess = private)
		descriptorsCache
		dotsCache  % a 2D matrix containing rows with all dots
		dotsPos  % a 2D matrix containing indices to dotsCaches for start and end of the part containing the dots of a given frame number
		descriptorsPos
		annotationIndices
		filePathsCache
		dataFolder  % Folder containing mat files with descriptors
		imPrefix = 'im';
		imDigets = 3;  % load from outside
		verbose = true;
 	end

	methods
		function obj = DataStore(dataFolder, verbose)
			initCacheSize = 100;
			obj.dotsCache = zeros(initCacheSize, 2, 'uint16');
			obj.filePathsCache = containers.Map('KeyType', 'uint32',...
				'ValueType', 'char');
			obj.dataFolder = dataFolder;

			obj.annotationIndices = computeMatfileIndices();
			
			% FIXME: Haha lol, I must be careful when indexing into annotationIndices if the are missing images... I would request the wrong image :D
			obj.dotsPos = zeros(numel(obj.annotationIndices), 2, 'uint16');


			obj.descriptorsPos = zeros(numel(obj.annotationIndices), 2, 'uint16');
			% TODO: Precomputes file names because fullfile is too slow otherwise

			% Check the size of the descriptors
			data = load(obj.frameFile(obj.annotationIndices(1)));
			if isfield(data, 'descriptors')
				obj.descriptorsCache = zeros(initCacheSize, size(data.descriptors, 2), 'single');
			end
			if nargin > 1
				obj.verbose = verbose;
			end

			function idx = computeMatfileIndices()
				% Checks the available mat files on disk and returns their frame numbers

				matfiles = dir(fullfile(dataFolder, [obj.imPrefix '*.mat']));
				idx = zeros(numel(matfiles), 1);

				name2frame = @(name) str2num(name(length(obj.imPrefix)+1:end-4));
				idx = cellfun(name2frame, {matfiles.name});
			end
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
				fmt = ['im%0' int2str(obj.imDigets) 'd.mat'];
				imName = sprintf(fmt, frameNumber);
				p = fullfile(obj.dataFolder, imName);
				obj.filePathsCache(frameNumber) = p;
			end
		end

		function dots = getDots(obj, frameNumber, cellIndices)
			% Returns the dots of cells indicated by cellIndices in frame frameNumberd
			q = obj.dotsPos(frameNumber, :);
			if q
				dots = obj.dotsCache(q(1):q(2), :);
			else
				if obj.verbose;
					fprintf('GETDOTS:       Accessing %s on disk\n', obj.frameFile(frameNumber));
				end
				data = load(obj.frameFile(frameNumber));

				dots = data.dots;
				n = size(dots, 1);
				nextIdx = max(obj.dotsPos(:, 2));
				obj.dotsPos(frameNumber, :) = [nextIdx+1, nextIdx+n];

				if nextIdx + n >= size(obj.dotsCache, 1)
					% Allocate more space. Duplicate values don't matter since
					% I will overwrite them
					if obj.verbose
						fprintf('GETDOTS:       Dots cache size has been increased to %d.\n', size(obj.dotsCache, 1))
					end
					obj.dotsCache = repmat(obj.dotsCache, 2, 1);
				end

				obj.dotsCache((nextIdx+1):(nextIdx+n), :) = dots;
			end
			if nargin == 3
				dots = dots(cellIndices, :);
			end
		end

		function descriptors = getDescriptors(obj, frameNumber, cellIndices)
			% Returns the descriptors of cells indicated by cellIndices in frame frameNumber

			q = obj.descriptorsPos(frameNumber, :);
			if q
				descriptors = obj.descriptorsCache(q(1):q(2), :);
			else
				if obj.verbose;
					fprintf('GETDETECTIONS: Accessing %s on disk\n', obj.frameFile(frameNumber));
				end
				data = load(obj.frameFile(frameNumber));

				if isfield(data, 'descriptors')
					descriptors = data.descriptors;
					n = size(descriptors, 1);
					nextIdx = max(obj.descriptorsPos(:, 2));
					q = [nextIdx+1, nextIdx+n];
					obj.descriptorsPos(frameNumber, :) = q;

					if nextIdx + n >= size(obj.descriptorsCache, 1)
						% Allocate more space. Duplicate values don't matter since
						% I will overwrite them
						if obj.verbose
							fprintf('GETDETECTIONS: Descriptors cache size has been increased to %d.\n', size(obj.descriptorsCache, 1))
						end
						obj.descriptorsCache = repmat(obj.descriptorsCache, 2, 1);
					end
					obj.descriptorsCache(q(1):q(2), :) = descriptors;
				else
					error('No key "descriptors" in %s', obj.frameFile(frameNumber));
				end
			end
			if nargin == 3
				descriptors = descriptors(cellIndices, :);
			end
		end

		function [dots, links] = getDotsAndLinks(obj, frameNumber, cellIndices)
			% I don't bother caching the links, because I don't access them often, only when creating the tracklets

			if obj.verbose;
				fprintf('GETDOTSANDLINKS: Accessing %s on disk\n', obj.frameFile(frameNumber));
			end
			data = load(obj.frameFile(frameNumber));
			dots = data.dots;
			links = data.links;
			n = size(dots, 1);

			q = obj.dotsPos(frameNumber, :);
			if ~q
				nextIdx = max(obj.dotsPos(:, 2));
				q =[nextIdx+1, nextIdx+n];
				obj.dotsPos(frameNumber, :) = q;
				if nextIdx + n >= size(obj.dotsCache, 1)
					% Allocate more space. Duplicate values don't matter since
					% I will overwrite them
					if obj.verbose
						fprintf('GETDOTS:       Dots cache size has been increased to %d.\n', size(obj.dotsCache, 1))
					end
					obj.dotsCache = repmat(obj.dotsCache, 2, 1);
				end
			end
			

			obj.dotsCache(q(1):q(2), :) = dots;

			if nargin == 3
				dots = dots(cellIndices, :);
				links = links(cellIndices, :);
			end
		end

		function sizes = size(obj)
			sizes = struct(...
				'dots', length(obj.dotsCache),...
				'descriptors', length(obj.descriptorsCache),...
				'filepaths', length(obj.filePathsCache)...
			);
		end

		function idx = getMatfileIndices(obj)
			% Checks the available mat files on disk and returns their frame numbers
			idx = obj.annotationIndices;
		end
	end
end