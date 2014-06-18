function ind = private_correctIndex(index, numImages, nDisplays)
    % PRIVATE _correctIndex set the index such that it can be used for rendering 
    % images when the index is close to numImages or close to zero

    ind = index;
    if ind < ceil(nDisplays / 2)
        ind = ceil(nDisplays / 2); 
    elseif ind > numImages - floor(nDisplays / 2)
        ind = numImages - floor(nDisplays / 2);
    end
end