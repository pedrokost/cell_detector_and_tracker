function setupPlot(active, total, mutliPlot)

	if mutliPlot
		if total < 4
			subplot(1, total, active);
		else
			subplot(2, ceil(total / 2), active);
		end
	else
		figure(active);  clf;
	end
end
