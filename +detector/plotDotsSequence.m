function plotDotsSequence( directory )
%PLOTDOTSSEQUENCE Given a cell of dots arrays, it plots them in a spatial
%view

    % read the dots sequences
    files = dir(fullfile(directory, 'im*.mat'));

    dotsSequence = cell(numel(files), 1);

    % store them in a cell array
    i = 1;
    for f=files'
        fullname = fullfile(directory, f.name);
        data = load(fullname);
        if isfield(data, 'dots')
            dotsSequence{i} = data.dots;
        else
            dotsSequence{i} = data.gl;
        end
        i = i + 1;
    end

    % calle the plotDotsSequence function
    doPlotSequences(dotsSequence)
    % savefig(fullfile(directory, 'timeplot.fig'));
    % saveas(gcf,fullfile(directory, 'timeplot.png'))

    % close(gcf)
end

function doPlotSequences( dotsSequence )
    i = 1;
    for dots=dotsSequence'

        dotties = dots{1};
        numEls = size(dotties, 1);
        plot3(dotties(:, 1), ...
                 dotties(:, 2), ...
                 ones(numEls, 1) * i,...
                 'r.');
        xlabel('Image width [px]')
        ylabel('Image height [px]')
        zlabel('Frame number')
        % title('Time plot of detected cell locations on dataset')

        hold on;
        i = i + 1;
    end
    view(30, 45);
    grid on;
end

