function CPdynamizescrollbar(scrollbar)

% $Revision: 5790 $

if usejava('awt'),
    callback = get(scrollbar, 'Callback');
    parent = get(scrollbar, 'Parent');
    sliderlistener = handle.listener(scrollbar, 'ActionEvent', callback);
    setappdata(parent, 'sliderListeners', [getappdata(parent, 'sliderListeners'), sliderlistener]);
end

