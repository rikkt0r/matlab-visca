v = visca('COM1')
v.openConnection
% v.setAddress
pause(2)

try 
    v.viscaPowerInq
catch exception
    disp('blad..')
    %rethrow(exception)
end

v.viscaHome
disp('POSITION')
v.viscaZoomPosition'

v.viscaZoomTele(1)
v.viscaZoomWide(0.5)
v.viscaZoomTele(0.5)
v.viscaZoomWide(1)

disp('POSITION')
v.viscaZoomPosition'
v.closeConnection