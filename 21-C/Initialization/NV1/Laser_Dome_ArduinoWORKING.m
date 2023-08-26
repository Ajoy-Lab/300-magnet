classdef Laser_Dome_Arduino
    properties
        arduinoCom1
        arduinoCom2
        arduinoCom3
        port_name1
        port_name2
        port_name3
    end
    methods
        
        function obj=Laser_Dome_Arduino(port_name1,port_name2,port_name3)
            obj.arduinoCom1 = serial(port_name1,'BaudRate',9600);
            obj.arduinoCom2 = serial(port_name2,'BaudRate',9600);
            obj.arduinoCom3 = serial(port_name3,'BaudRate',9600);
            fopen(obj.arduinoCom1);
            fopen(obj.arduinoCom2);
            fopen(obj.arduinoCom3);
        end
        
        function all_lasers_off(obj)
            mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0];
            disp ('Turning off Lasers');
            obj.send_arduino(mastervectorboard1,mastervectorboard2,mastervectorboard3);
        end          
        
        function send_arduino(obj,x1,x2,x3)
            
            string_mastervectorboard1 = mat2str(x1);
            string_mastervectorboard1_nobracket = string_mastervectorboard1(2:end-1);
            sendData1_spaces = ['<' string_mastervectorboard1_nobracket '>'];
            sendData1 = sendData1_spaces(find(~isspace(sendData1_spaces)));
            sendData1 = sendData1(3:14);
            sendData1 = strcat('<', sendData1, '>');
            
            string_mastervectorboard2 = mat2str(x2);
            string_mastervectorboard2_nobracket = string_mastervectorboard2(2:end-1);
            sendData2_spaces = ['<' string_mastervectorboard2_nobracket '>'];
            sendData2 = sendData2_spaces(find(~isspace(sendData2_spaces)));
            sendData2 = sendData2(3:14);
            sendData2 = strcat('<', sendData2, '>');
            
            string_mastervectorboard3 = mat2str(x3);
            string_mastervectorboard3_nobracket = string_mastervectorboard3(2:end-1);
            sendData3_spaces = ['<' string_mastervectorboard3_nobracket '>'];
            sendData3 = sendData3_spaces(find(~isspace(sendData3_spaces)));
            sendData3 = sendData3(3:14);
            sendData3 = strcat('<', sendData3, '>');
            
            fprintf(obj.arduinoCom1,'%s',sendData1);
            las1=fscanf(obj.arduinoCom1);
            
            fprintf(obj.arduinoCom2,'%s',sendData2);
            las2=fscanf(obj.arduinoCom2);
            
            fprintf(obj.arduinoCom3,'%s',sendData3);
            las3=fscanf(obj.arduinoCom3);
        end
            
        function read_arduino(obj)
            las1=fscanf(obj.arduinoCom1);
            pause(1);
            las2=fscanf(obj.arduinoCom2);
            pause(1);
            las3=fscanf(obj.arduinoCom3);
            pause(1);
            disp(['Laser Board 1:' las1 '\n']);
            disp(['Laser Board 2:' las2 '\n']);
            disp(['Laser Board 3:' las3 '\n']);
        end
        
        
        function close_arduino(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
                fclose(serialObj(i));
            end
        end
        
        function read_laserdomegui(obj, laser_count)
            
            if laser_count < 43    
                mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0];
                mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0];
                mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0];
            
                msglaserdome = 'Reading Laser Dome GUI';
                disp(msglaserdome)
            
                load('boardconfig.mat');
                mastervectorboard1;
                mastervectorboard2;
                mastervectorboard3;
            end
            
            obj.send_arduino(mastervectorboard1,mastervectorboard2,mastervectorboard3);
            
        end

            
        
        function lasernumber(obj, laser_num)
            
            mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0];
            
            disp ('Turning ON Laser');
            
           if laser_num == 1
                mastervectorboard1(8) = 1;
            elseif laser_num == 2
                mastervectorboard1(3) = 1;
            elseif laser_num == 3
                mastervectorboard3(8) = 1;
            elseif laser_num == 4
                mastervectorboard3(9) = 1;
            elseif laser_num == 5
                mastervectorboard3(10) = 1;
            elseif laser_num == 6
                mastervectorboard1(9) = 1;
            elseif laser_num == 7
                mastervectorboard2(3) = 1;
            elseif laser_num == 8
                mastervectorboard1(4) = 1;
            elseif laser_num == 9
                mastervectorboard1(10) = 1;
            elseif laser_num == 10
                mastervectorboard3(12) = 1;
            elseif laser_num == 11
                mastervectorboard3(11) = 1;
            elseif laser_num == 12
                mastervectorboard2(8) = 1;
            elseif laser_num == 13
                mastervectorboard2(9) = 1;
            elseif laser_num == 14
                mastervectorboard2(10) = 1;
            elseif laser_num == 15
                mastervectorboard2(11) = 1;
            elseif laser_num == 16
                mastervectorboard2(4) = 1;
            elseif laser_num == 17
                mastervectorboard2(5) = 1;
            elseif laser_num == 18
                mastervectorboard1(5) = 1;
            elseif laser_num == 19
                mastervectorboard1(11) = 1;
            elseif laser_num == 20
                mastervectorboard2(6) = 1;
            elseif laser_num == 21
                mastervectorboard1(6) = 1;
            elseif laser_num == 22
                mastervectorboard3(13) = 1;
            elseif laser_num == 23
                mastervectorboard3(7) = 1;
            elseif laser_num == 24
                mastervectorboard2(12) = 1;
            elseif laser_num == 25
                mastervectorboard3(5) = 1;
            elseif laser_num == 26
                mastervectorboard2(7) = 1;
            elseif laser_num == 27
                mastervectorboard1(12) = 1;
            elseif laser_num == 28
                mastervectorboard1(13) = 1;
            elseif laser_num == 29
                mastervectorboard1(7) = 1;
            elseif laser_num == 30
                mastervectorboard2(13) = 1;
            elseif laser_num == 0
            end
            obj.send_arduino(mastervectorboard1,mastervectorboard2,mastervectorboard3);
        end
            
        
        function orderlasers(obj,laser_count)
            mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0];
            mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0];
            
                
            disp ('Turning ON Lasers');
            
                if laser_count == 1 %%%this is the ordering of turning on the lasers, from bottom to top, left to right
                    mastervectorboard3(12) = 1;
                elseif laser_count == 2
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                elseif laser_count == 3
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                elseif laser_count == 4
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
%                 elseif laser_count == 5 commented out because b3l5 is a
%                 laser with a broken thermocouple, currently not
%                 functioning, but might be repaired in the future
%                     mastervectorboard3(12) = 1;
%                     mastervectorboard1(6) = 1;
%                     mastervectorboard2(8) = 1;
%                     mastervectorboard3(11) = 1;
%                     mastervectorboard3(6) = 1;
                elseif laser_count == 5
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                elseif laser_count == 6
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                elseif laser_count == 7
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                elseif laser_count == 8
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                elseif laser_count == 9
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                elseif laser_count == 10
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                elseif laser_count == 11
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                elseif laser_count == 12
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                elseif laser_count == 13
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                elseif laser_count == 14
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                elseif laser_count == 15
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                elseif laser_count == 16
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                elseif laser_count == 17
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                elseif laser_count == 18
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                elseif laser_count == 19
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                elseif laser_count == 20
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                elseif laser_count == 21
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                elseif laser_count == 22
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                elseif laser_count == 23
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                elseif laser_count == 24
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                elseif laser_count == 25
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                elseif laser_count == 26
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                    mastervectorboard1(12) = 1;
                elseif laser_count == 27
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(13) = 1;
                elseif laser_count == 28
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(13) = 1;
                    mastervectorboard2(9) = 1;
                elseif laser_count == 29
                    mastervectorboard3(12) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard3(11) = 1;
                    %mastervectorboard3(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard1(8) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard2(13) = 1;
                    mastervectorboard2(9) = 1;
                    mastervectorboard3(5) = 1;
                elseif laser_count == 30
                    
                    mastervectorboard1(8) = 1;
                    mastervectorboard1(3) = 1;
                    mastervectorboard3(8) = 1;
                    mastervectorboard3(9) = 1;
                    mastervectorboard3(10) = 1;
                    mastervectorboard1(9) = 1;
                    mastervectorboard2(3) = 1;
                    mastervectorboard1(4) = 1;
                    mastervectorboard1(10) = 1;
                    mastervectorboard3(12) = 1;
                    mastervectorboard3(11) = 1;
                    mastervectorboard2(8) = 1;
                    mastervectorboard2(9) = 1;
                    mastervectorboard2(10) = 1;
                    mastervectorboard2(11) = 1;
                    mastervectorboard2(4) = 1;
                    mastervectorboard2(5) = 1;
                    mastervectorboard1(5) = 1;
                    mastervectorboard1(11) = 1;
                    mastervectorboard2(6) = 1;
                    mastervectorboard1(6) = 1;
                    mastervectorboard3(13) = 1;
                    mastervectorboard3(7) = 1;
                    mastervectorboard2(12) = 1;
                    mastervectorboard3(5) = 1;
                    mastervectorboard2(7) = 1;
                    mastervectorboard1(12) = 1;
                    mastervectorboard1(13) = 1;
                    mastervectorboard1(7) = 1;
                    mastervectorboard2(13) = 1;
                    
                elseif laser_count == 0
                end
            
%             if laser_count == 1 %%%this is the ordering of turning on the lasers, from bottom to top, left to right
%                 mastervectorboard1(8) = 1;
%             elseif laser_count == 2
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%             elseif laser_count == 3
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%             elseif laser_count == 4
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(8) = 1;
%             elseif laser_count == 5
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%             elseif laser_count == 6
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%             elseif laser_count == 7
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%             elseif laser_count == 8
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%             elseif laser_count == 9
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%             elseif laser_count == 10
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%             elseif laser_count == 11
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%             elseif laser_count == 12
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%             elseif laser_count == 13
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%             elseif laser_count == 14
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%             elseif laser_count == 15
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%             elseif laser_count == 16
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%             elseif laser_count == 17
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%             elseif laser_count == 18
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%             elseif laser_count == 19
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%             elseif laser_count == 20
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%             elseif laser_count == 21
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%             elseif laser_count == 22
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%             elseif laser_count == 23
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%             elseif laser_count == 24
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%             elseif laser_count == 25
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%             elseif laser_count == 26
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%             elseif laser_count == 27
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%                 mastervectorboard2(13) = 1;
%             elseif laser_count == 28
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%                 mastervectorboard2(13) = 1;
%                 mastervectorboard1(12) = 1;
%             elseif laser_count == 29
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%                 mastervectorboard2(13) = 1;
%                 mastervectorboard1(12) = 1;
%                 mastervectorboard1(13) = 1;
%             elseif laser_count == 30
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%                 mastervectorboard2(13) = 1;
%                 mastervectorboard1(12) = 1;
%                 mastervectorboard1(13) = 1;
%                 mastervectorboard2(7) = 1;
%             elseif laser_count == 31
%                 mastervectorboard1(8) = 1;
%                 mastervectorboard1(3) = 1;
%                 mastervectorboard3(8) = 1;
%                 mastervectorboard3(9) = 1;
%                 mastervectorboard3(10) = 1;
%                 mastervectorboard1(9) = 1;
%                 mastervectorboard2(3) = 1;
%                 mastervectorboard1(4) = 1;
%                 mastervectorboard1(10) = 1;
%                 mastervectorboard3(12) = 1;
%                 mastervectorboard3(11) = 1;
%                 mastervectorboard2(8) = 1;
%                 mastervectorboard2(9) = 1;
%                 mastervectorboard2(10) = 1;
%                 mastervectorboard2(11) = 1;
%                 mastervectorboard2(4) = 1;
%                 mastervectorboard2(5) = 1;
%                 mastervectorboard1(5) = 1;
%                 mastervectorboard1(11) = 1;
%                 mastervectorboard2(6) = 1;
%                 mastervectorboard1(6) = 1;
%                 mastervectorboard3(13) = 1;
%                 mastervectorboard3(6) = 1;
%                 mastervectorboard3(5) = 1;
%                 mastervectorboard2(12) = 1;
%                 mastervectorboard3(7) = 1;
%                 mastervectorboard2(13) = 1;
%                 mastervectorboard1(12) = 1;
%                 mastervectorboard1(13) = 1;
%                 mastervectorboard2(7) = 1;
%                 mastervectorboard1(7) = 1;
%             elseif laser_count == 0
%             end
            
            obj.send_arduino(mastervectorboard1,mastervectorboard2,mastervectorboard3);
%             obj.read_arduino()
        end
      
    end
end