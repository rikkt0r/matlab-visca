%% Using Manual Trigger Mode
% There is a way to avoid the overhead of GETSNAPSHOT described in the
% previous section.  You can to put the video input object in manual
% triggering mode.  Manual triggering mode allows the toolbox to connect to
% and configure the device a single time without logging data to memory.
% This means that frames can be returned to MATLAB(R) much quicker.

close all
clear all

    imaqhwinfo
    info = imaqhwinfo('winvideo')
        %vid = videoinput('winvideo',2,'RGB24_320x240')  % dla kamery web Logitech
        % vid = videoinput('winvideo',1,'YUY2_320x240')  % dla kamery wbudowanej ASUS
        % vid = videoinput('winvideo',1,'YUY2_720x576');  % dla kamery po³¹czonej 
        % przez tuner Avermedia - komp hp-elite pok. 104 (nie ma innych
        % formatów obrazu...)
        vid = videoinput('winvideo',1, 'RGB24_736x576');  % dla kamery po³¹czonej 
            % przez USB DELOCK Conexant Polaris
        
    sources = vid.Source
    src = sources(1);
    %{
    get(src,'Brightness')  
    get(src,'Contrast')
    set(src,'Brightness',2800)  % bylo 2825 KORYTARZ, 5000 to wartosc srodkowa
    set(src,'Contrast',4400)   % bylo 4400
    get(src,'Brightness')  
    get(src,'Contrast')
    %}
    %    vidRes = get(vid, 'VideoResolution'); % vidRes(1)=szerokosc, vidRes(2)=wysokosc
    %set(vid,'FramesPerTrigger',1);
  % set(vid, 'ReturnedColorSpace', 'grayscale')
    % Configure the object for manual trigger mode.
        triggerconfig(vid, 'Manual');


% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
a = figure;
start(vid)
ile = 25;
% Measure the time to acquire 'ile' frames.
elapsedTime = zeros(1, ile);
for i = 1:ile
    tic
    data = getsnapshot(vid); %%% zmienic po odkomentowaniu skalowania
    % data = imresize(data1, [240 320]);
    imwrite(data,strcat('mjpeg_p_', num2str(i),'.png'),'png');
    figure(a); imshow(data);
    elapsedTime(1, i) = toc;
end



% Compute the time per frame and effective frame rate.
timePerFrame = sum(elapsedTime(1, :))/ile
effectiveFrameRate = 1/timePerFrame

% Call the STOP function to stop the device.
stop(vid)

%%
% You can see that the elapsed time using manual triggering is much smaller
% than the previous example.

%% Cleanup
% Once the video input object is no longer needed, delete the associated
% variable.
delete(vid)
