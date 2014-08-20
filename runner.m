%                _                        _   _       
%     /\        | |                      | | (_)      
%    /  \  _   _| |_ ___  _ __ ___   __ _| |_ _  ___  
%   / /\ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ __| 
%  / ____ \ |_| | || (_) | | | | | | (_| | |_| | (__  
% /_/    \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___|   
%           _ _       _      _            _              
%          | | |     | |    | |          | |             
%   ___ ___| | |   __| | ___| |_ ___  ___| |_ ___  _ __  
%  / __/ _ \ | |  / _` |/ _ \ __/ _ \/ __| __/ _ \| '__| 
% | (_|  __/ | | | (_| |  __/ ||  __/ (__| || (_) | |    
%  \___\___|_|_|  \__,_|\___|\__\___|\___|\__\___/|_|    
%                  _   _                  _             
%                 | | | |                | |            
%   __ _ _ __   __| | | |_ _ __ __ _  ___| | _____ _ __ 
%  / _` | '_ \ / _` | | __| '__/ _` |/ __| |/ / _ \ '__|
% | (_| | | | | (_| | | |_| | | (_| | (__|   <  __/ |   
%  \__,_|_| |_|\__,_|  \__|_|  \__,_|\___|_|\_\___|_|    

% Author: Pedro Damian Kostelec
% Large parts of the detector were written by Arteta et al.
% Original development: May-August 2014
%============================================================================%
%                                                                Configuration
%============================================================================%

datasetIDs    = [6];     % Look into dataFolders.m

trainDetector = false;
trainTracker  = true;

testDetector  = false;
testTracker   = true;

showTracks    = true;

% If you are not satisfied with the results of the tracker, you can use the
% `tweak` tool to adjust the trajectories.

%============================================================================%
%                                                                 Train & Test
%============================================================================%
%                        NO NEED DO TOUCH THIS BELOW

% addpath('somelightspeed')
title = [...
'          ___  __             ___    __      __   ___             \n' ...
' /\\  |  |  |  /  \\  |\\/|  /\\   |  | /  `    /  ` |__  |    |      \n' ...
'/~~\\ \\__/  |  \\__/  |  | /~~\\  |  | \\__,    \\__, |___ |___ |___ \n' ...
' __   ___ ___  ___  __  ___  __   __                __ \n' ...
'|  \\ |__   |  |__  /  `  |  /  \\ |__)     /\\  |\\ | |  \\\n' ...
'|__/ |___  |  |___ \\__,  |  \\__/ |  \\    /~~\\ | \\| |__/\n' ...
'___  __        __        ___  __ \n' ...
' |  |__)  /\\  /  ` |__/ |__  |__)\n' ...
' |  |  \\ /~~\\ \\__, |  \\ |___ |  \\ v1.0 alpha\n\n' ...
];
fprintf(title);


if trainDetector
	for dataset=datasetIDs
		fsectionf('Training detector on dataset %d', dataset);
		detector.trainDetector(dataset);
	end
end

if testDetector
	for dataset=datasetIDs
		fsectionf('Detecting cells in dataset %d', dataset);
		detector.detectCells(dataset);
	end
end

if trainTracker
	for dataset=datasetIDs
		fsectionf('Training tracker on dataset %d', dataset);
		tracker.trainTracker(dataset);
	end
end

if testTracker
	for dataset=datasetIDs
		fsectionf('Tracking cells in dataset %d', dataset);
		tracker.trackCells(dataset);
	end
end

if showTracks
	for dataset=datasetIDs
		fsectionf('Plotting trajectories from dataset %d', dataset)
		tracker.plotTrajectories(dataset);
	end
end
