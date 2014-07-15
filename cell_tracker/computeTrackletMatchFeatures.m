function features = computeTrackletMatchFeatures(dotsA, desA, dotsB, desB)

	desA = combineDescriptorsWithDots(desA, dotsA);
	desB = combineDescriptorsWithDots(desB, dotsB);
	features = euclideanDistance(desA, desB);
end