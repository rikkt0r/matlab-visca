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
v.viscaTiltPosition'

v.viscaUp2(2.5)
v.viscaLeft2(1)
v.viscaDown2(1)
v.viscaRight2(2.5)
v.viscaDown2(1.5)
v.viscaLeft2(1.5)

disp('POSITION')
v.viscaTiltPosition'

v.viscaHome

v.closeConnection