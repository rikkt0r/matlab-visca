% Visca to matlab mapper

classdef visca < handle
    
   properties (SetAccess = protected, GetAccess = protected)
       connection = 0;
       s; % serial
       
   end
   
   properties (Constant, GetAccess = public)
       address = '81';
       
       VISCA_COMMAND             = '01';
       VISCA_INQUIRY             = '09';
       VISCA_TERMINATOR          = 'FF';
       
       VISCA_SUCCESS             = '00';
       VISCA_FAILURE             = 'FF';
       
       VISCA_ERROR_MESSAGE_LENGTH      = '01';
       VISCA_ERROR_SYNTAX              = '02';
       VISCA_ERROR_CMD_BUFFER_FULL     = '03';
       VISCA_ERROR_CMD_CANCELLED       = '04';
       VISCA_ERROR_NO_SOCKET           = '05';
       VISCA_ERROR_CMD_NOT_EXECUTABLE  = '41';

       VISCA_RESPONSE_CLEAR            = '40';
       VISCA_RESPONSE_ADDRESS          = '30';
       VISCA_RESPONSE_ACK              = '40';
       VISCA_RESPONSE_COMPLETED        = '50';
       VISCA_RESPONSE_ERROR            = '60';
       
       % VISCA_ACK z0 4y FF -> z(address), y(socket number)
       
	   % MISC
	   
       CAM_AddrSet    = {'88', '30', '01'};

	   % INQUIRIES
	   
       CAM_ZoomPosInq  = {'81', '09', '04', '47', 'FF'};
	   CAM_FocusPosInq = {'81', '09', '04', '38', 'FF'};
	   CAM_WBModeInq   = {'81', '09', '04', '35', 'FF'};
       CAM_PowerInq    = {'81', '09', '04', '00', 'FF'};
       CAM_TiltPosInq = {'81', '09', '06', '12', 'FF'};
	   
	   % COMMANDS
	   
	   % camera tilt -> gora/dol
	   % camera pan  -> lewo/prawo
	   
	   CAM_Up2     = {'81', '01', '06', '01', '02', '02', '03', '01', 'FF'};
	   CAM_Up4     = {'81', '01', '06', '01', '04', '04', '03', '01', 'FF'};
	   CAM_Up14    = {'81', '01', '06', '01', '14', '14', '03', '01', 'FF'};
	   
	   CAM_Down2   = {'81', '01', '06', '01', '02', '02', '03', '02', 'FF'};
	   CAM_Down4   = {'81', '01', '06', '01', '04', '04', '03', '02', 'FF'};
	   CAM_Down14  = {'81', '01', '06', '01', '14', '14', '03', '02', 'FF'};
	   
	   CAM_Left2   = {'81', '01', '06', '01', '02', '02', '01', '03', 'FF'};
	   CAM_Left4   = {'81', '01', '06', '01', '04', '04', '01', '03', 'FF'};
	   CAM_Left14  = {'81', '01', '06', '01', '14', '14', '01', '03', 'FF'};
	   
	   CAM_Right2  = {'81', '01', '06', '01', '02', '02', '02', '03', 'FF'};
	   CAM_Right4  = {'81', '01', '06', '01', '04', '04', '02', '03', 'FF'};
	   CAM_Right14 = {'81', '01', '06', '01', '14', '14', '02', '03', 'FF'};
	   
	   CAM_Stop2   = {'81', '01', '06', '01', '02', '02', '03', '03', 'FF'};
	   CAM_Stop4   = {'81', '01', '06', '01', '04', '04', '03', '03', 'FF'};
	   CAM_Stop14  = {'81', '01', '06', '01', '14', '14', '03', '01', 'FF'};
	   
	   CAM_PanTiltHome  = {'81', '01', '06', '04', 'FF'};
	   CAM_PanTiltReset = {'81', '01', '06', '05', 'FF'};
       
       CAM_ZoomStop = {'81', '01', '04', '07', '00', 'FF'};
       CAM_ZoomTele = {'81', '01', '04', '07', '02', 'FF'};
       CAM_ZoomWide = {'81', '01', '04', '07', '03', 'FF'};
	   
   end
   
   methods
       
       function this = visca(interface)
           if(nargin == 1 && isa(interface,'char'))
               this.s = serial(interface);
               this.s.BaudRate = 9600;
               this.s.Parity = 'none';
               this.s.DataBits = 8;
               this.s.StopBits = 1;
               this.s.Terminator = 10; % newline @ ascii
               this.s.Name = 'Visca-Handler';
               this.s.ReadAsyncMode = 'continuous';
               this.s.InputBufferSize = 1024;
               this.s.RecordMode = 'index';
               this.s.RecordDetail = 'verbose';
               this.s.RecordName = 'SERIAL_LOG.txt';
               
               get(this.s)
           else
               error('bad argument count or interface is NOT a string');
           end
       end
       
       function res = openConnection(this)
           try
               fopen(this.s);
               if (this.s.Status == 'open')
                   record(this.s, 'on')

                   this.connection = 1;
                   res = 1;
                   disp('[OK] opened');
               else
                   error('[ERROR] could not connect');
               end
               
           catch exception
%                    fclose(this.s);
%                    delete(this.s);
                   % clear this.s;
               this.connection = 0;
               rethrow(exception)
           end
       end
       
       function res = closeConnection(this)
           try
              % record(this.s, 'off');
             %  if exists(this.s)
                   fclose(this.s);
                   delete(this.s);
                  %  clear(this.s);
              % end
               this.connection = 0;
               res = 1;
               disp('[OK] closed');
           catch exception
               % error('nie could not connect')
               rethrow(exception)
           end
       end
       
       function res = sendPacket(this,msg)
           try
               % msg = [this.address msg];
               msg
               fwrite(this.s, hex2dec(msg), 'uint8');
               this.s.BytesAvailable
               pause(0.1)
               res = fread(this.s,this.s.BytesAvailable);
               res = dec2hex(res);
               %out = fscanf(this.s);

               % disp(strcat('sent ', this.s.ValuesSent))
               
               % Matrix dimensions must agree
%               if (res(2,1) == this.VISCA_RESPONSE_ERROR(1) && res(2,2) == this.VISCA_RESPONSE_ERROR(2))
%                   switch(res(5:6))
%                       case this.VISCA_ERROR_MESSAGE_LENGTH
%                           fprintf('[ERROR] MESSAGE_LENGTH');
%                       case  this.VISCA_ERROR_SYNTAX
%                           fprintf('[ERROR] SYNTAX');
%                       case  this.VISCA_ERROR_CMD_BUFFER_FULL
%                           fprintf('[ERROR] CMD_BUFFER_FULL');
%                       case  this.VISCA_ERROR_CMD_CANCELLED
%                           fprintf('[ERROR] CMD_CANCELLED');
%                       case  this.VISCA_ERROR_NO_SOCKET
%                           fprintf('[ERROR] NO_SOCKET');
%                       case  this.VISCA_ERROR_CMD_NOT_EXECUTABLE
%                           fprintf('[ERROR] CMD_NOT_EXECUTABLE');
%                   end
%                   
%                   res = this.VISCA_FAILURE;
%               else
%                   disp('[ok]');
%               end
               
           catch ex
               rethrow(ex)
           end
       end
       
       function res = setAddress(this)
          % tmp = this.CAM_AddrSet,this.VISCA_TERMINATOR
          disp('adres:')
          res = this.sendPacket( this.CAM_AddrSet )
          
          % odczytac ADRES!!!
          
          % data = hex2dec( reshape( tmp ,[],2) );
       end
       
       function res = viscaPowerStatus(this)
           % data = '8' + this.address + this.VISCA_INQUIRY + this.VISCA_CATEGORY_CAMERA1 + this.CAM_PowerInq + this.VISCA_TERMINATOR;
           % data = hex2dec( reshape(    strcat('8',this.address,this.CAM_PowerInq,this.VISCA_TERMINATOR)    ,[],2) );
           
           res = this.sendPacket(this.CAM_PowerInq)
           
%            if (out ~= this.VISCA_FAILURE)
%                disp('YAY!!!');
%            end
          
       end
       
       function res = viscaPosition(this)
          res =  this.sendPacket(this.CAM_FocusPosInq)
       end
       
       function res = viscaUp2(this,time)
            % data = [this.address this.CAM_Up2];
            out = this.sendPacket(this.CAM_Up2)
            
            pause(time)
            
            % data = [this.address this.CAM_Stop2];
            out = this.sendPacket(this.CAM_Stop2)
       end
       
       function res = viscaDown2(this,time)
            % data = [this.address this.CAM_Up2];
            out = this.sendPacket(this.CAM_Down2)
            
            pause(time)
            
            % data = [this.address this.CAM_Stop2];
            out = this.sendPacket(this.CAM_Stop2)
       end
       
       function res = viscaLeft2(this,time)
            % data = [this.address this.CAM_Up2];
            out = this.sendPacket(this.CAM_Left2)
            
            pause(time)
            
            % data = [this.address this.CAM_Stop2];
            out = this.sendPacket(this.CAM_Stop2)
       end

       function res = viscaRight2(this,time)
            % data = [this.address this.CAM_Up2];
            out = this.sendPacket(this.CAM_Right2)
            
            pause(time)
            
            out = this.sendPacket(this.CAM_Stop2)
       end
       
       function res = viscaHome(this)
           res = this.sendPacket(this.CAM_PanTiltHome)
           pause(0.3)
       end
       
       function res = viscaTiltPosition(this)
           res = this.sendPacket(this.CAM_TiltPosInq)
       end
       
       function res = viscaZoomTele(this,time)
            res = this.sendPacket(this.CAM_ZoomTele)
            
            pause(time)
            
            res = this.sendPacket(this.CAM_ZoomStop)
       end
       
       function res = viscaZoomWide(this,time)
            res = this.sendPacket(this.CAM_ZoomWide)
            
            pause(time)
            
            res = this.sendPacket(this.CAM_ZoomStop)
       end
       
       function res = viscaZoomPosition(this)
           res = this.sendPacket(this.CAM_ZoomPosInq)
       end
       
   end
end

% instrhwinfo('serial')