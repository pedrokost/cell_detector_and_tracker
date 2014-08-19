function [val, pointsVals] = evaluateGaussianBroadeningModel(model, points)
	% EVALUATEGAUSSIANBROADENINGMODEL evaluate the provided gaussian-broadening model at the values provided by the points matrix. The matrix points should have the same dimensionality as the tracklet matrix used to generate the model (eg. for x-y columns should be 2)
	% Inputs:
	% 	model = a gaussian-broadening model generated by gaussianBroadeningModel(...)
	% 	points = a matrix of positions on which to evaluate the model (generally nObs x 2)
	% Outpts:
	% 	val = the sum of values of the evaluation at each point in points
	% 	pointsVals = a vector the same length as the number of rows in points containing the value of the evaluation

	extrudeLength = size(model.mus, 1);
	numObs = size(points, 1);
	pointsVals = zeros(numObs, 1);
	
	for i=1:extrudeLength
		% model.sigmas(:, :, i)
		% p = mvnpdf(points, model.mus(i, :), model.sigmas(:, :, i))

		% By not calling the function, but copying it here, I win 30% of time of
		% calling the evaluateGaussianBroadeningModel function
		% p = tracker.mvnpdffast(points, model.mus(i, :), model.sigmas(:, :, i));
		r = chol(model.sigmas(:, :, i)); 
		p = (2*pi)^(-size(points, 2)/2) * exp(-0.5 * sum(((points-repmat(model.mus(i, :), size(points, 1), 1))/r).^2,2)) / prod(diag(r)); 

		% size(points)
		% size(model.mus(i, :)')
		% size(model.sigmas(:, :, i))
		% p = mvnormpdf(points', model.mus(i, :)', [], model.sigmas(:, :, i))'
		% if any(isnan(p))
		% 	warning('A p value is NaN. Why dont you fix it?');
		% 	keyboard
		% end
		pointsVals = pointsVals + p;
	end

	if model.normalize
		pointsVals = pointsVals / extrudeLength;
	end
	val = sum(pointsVals);

	if isnan(val)
		warning('The evalutaion gaussian breadening is NaN. Why dont you fixed it?')
		keyboard
	end
end