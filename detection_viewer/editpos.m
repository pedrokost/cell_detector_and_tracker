function rect = editpos(handle)
% Enters plot edit mode, pauses to let user manipulate objects,
% then turns the mode off. It does not track what user does.
% User later needs to output a Position property, if changed.

if ~ishghandle(handle)
    disp(['=E= gbt_moveobj: Invalid handle: ' inputname(1)])
    return
end
plotedit(handle,'on')
disp('=== Select, move and resize object. Use mouse and arrow keys.')
disp('=== When you are finished, press Return to continue.')
pause
rect = get(handle,'Position');
inspect(handle)