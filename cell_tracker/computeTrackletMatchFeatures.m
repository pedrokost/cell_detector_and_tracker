function features = computeTrackletMatchFeatures(trackletA, dotsA, desA, trackletB, dotsB, desB)

	desA = combineDescriptorsWithDots(desA, dotsA);
	desB = combineDescriptorsWithDots(desB, dotsB);
	features = euclideanDistance(desA, desB);
end