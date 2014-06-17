function match_width(hObject, ~) 
   u = findobj(gcbo, 'Type','uipanel','Tag','StatusBar'); 
   fig = gcbo;     
   panelunits = get(u,'Units');
   set(u,'Units','pixels');
   % derive the new position for the panel
   hpos = get(hObject,'Position'); 
   figpos = get(fig,'Position'); 
   upos = [hpos(1), hpos(2), figpos(3) - 2*hpos(1), hpos(4)];
   set(u,'Position',upos); 
   % restore units for the panel
   set(u,'Units',panelunits);
 end 
