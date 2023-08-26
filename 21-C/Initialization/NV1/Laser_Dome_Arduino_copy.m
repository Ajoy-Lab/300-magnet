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
            fopen(arduinoCom1);
            fopen(arduinoCom2);
            fopen(arduinoCom3);
        end
        
        function orderlasers(x)
            
            laser_count = x(2);
            mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0]
            mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0]
            mastervectorboard2 = [3 0 0 0 0 0 0 0 0 0 0 0 0]
            
            if laser_count == 1 %%%this is the ordering of turning on the lasers, from bottom to top, left to right
                mastervectorboard1(8) = 1;
            elseif laser_count == 2
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
            elseif laser_count == 3
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
            elseif laser_count == 4
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(8) = 1;
            elseif laser_count == 5
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(9) = 1;
                mastervectorboard3(10) = 1;
            elseif laser_count == 6
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(9) = 1;
                mastervectorboard3(10) = 1;
                mastervectorboard1(9) = 1;
            elseif laser_count == 7
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(9) = 1;
                mastervectorboard3(10) = 1;
                mastervectorboard1(9) = 1;
                mastervectorboard2(3) = 1;
            elseif laser_count == 8
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(9) = 1;
                mastervectorboard3(10) = 1;
                mastervectorboard1(9) = 1;
                mastervectorboard2(3) = 1;
                mastervectorboard1(4) = 1;
            elseif laser_count == 9
                mastervectorboard1(8) = 1;
                mastervectorboard1(3) = 1;
                mastervectorboard3(8) = 1;
                mastervectorboard3(9) = 1;
                mastervectorboard3(10) = 1;
                mastervectorboard1(9) = 1;
                mastervectorboard2(3) = 1;
                mastervectorboard1(4) = 1;
                mastervectorboard1(10) = 1;
            elseif laser_count == 10
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
            elseif laser_count == 11
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
            elseif laser_count == 12
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
            elseif laser_count == 13
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
            elseif laser_count == 14
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
            elseif laser_count == 15
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
            elseif laser_count == 16
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
            elseif laser_count == 17
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
            elseif laser_count == 18
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
            elseif laser_count == 19
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
            elseif laser_count == 20
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
            elseif laser_count == 21
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
            elseif laser_count == 22
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
            elseif laser_count == 23
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
                mastervectorboard3(6) = 1;
            elseif laser_count == 24
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
            elseif laser_count == 25
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
            elseif laser_count == 26
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
            elseif laser_count == 27
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
                mastervectorboard2(13) = 1;
            elseif laser_count == 28
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
                mastervectorboard2(13) = 1;
                mastervectorboard1(12) = 1;
            elseif laser_count == 29
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
                mastervectorboard2(13) = 1;
                mastervectorboard1(12) = 1;
                mastervectorboard1(13) = 1;
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
                mastervectorboard2(13) = 1;
                mastervectorboard1(12) = 1;
                mastervectorboard1(13) = 1;
                mastervectorboard2(7) = 1;
            elseif laser_count == 31
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
                mastervectorboard3(6) = 1;
                mastervectorboard3(5) = 1;
                mastervectorboard2(12) = 1;
                mastervectorboard3(7) = 1;
                mastervectorboard2(13) = 1;
                mastervectorboard1(12) = 1;
                mastervectorboard1(13) = 1;
                mastervectorboard2(7) = 1;
                mastervectorboard1(7) = 1;
            end
            
            save('mastervectorboard.mat', 'mastervectorboard1', 'mastervectorboard2', 'mastervectorboard3')
            
        end
        
        function alllasersoff(obj)
            mastervectorboard1 = [1 0 0 0 0 0 0 0 0 0 0 0 0]
            mastervectorboard2 = [2 0 0 0 0 0 0 0 0 0 0 0 0]
            mastervectorboard3 = [3 0 0 0 0 0 0 0 0 0 0 0 0]
        end          
        
        
        function send_arduino(sendData1,sendData2,sendData3)
            fprintf(obj.arduinoCom1,'%s',sendData1);
            fscanf(obj.arduinoCom1)
            
            fprintf(obj.arduinoCom2,'%s',sendData2);
            fscanf(obj.arduinoCom2)
            
            fprintf(obj.arduinoCom3,'%s',sendData3);
            fscanf(obj.arduinoCom3)
        end
            
        function open_arduino(x)
            arduinoCom1 = serial('COM13','BaudRate',9600);
            fopen(arduinoCom1);
        end
        
        function sendarduino1(x)
            arduinoCom1 = serial('COM13','BaudRate',9600);
            fprintf(arduinoCom1,'%s',sendData);
            fscanf(arduinoCom1)
        end
        
        function closearduino1(x)
            arduinoCom1 = serial('COM13','BaudRate',9600);
            fclose(arduinoCom1)
        end
        
        function openarduino2(x)
            arduinoCom2 = serial('COM14','BaudRate',9600);
            fopen(arduinoCom2);
        end
        
        function sendarduino2(x)
            arduinoCom2 = serial('COM14','BaudRate',9600);
            fprintf(arduinoCom2,'%s',sendData);
            fscanf(arduinoCom2)
        end
        
        function closearduino2(x)
            arduinoCom2 = serial('COM14','BaudRate',9600);
            fclose(arduinoCom2)
        end
            
        function openarduino3(x)
            arduinoCom3 = serial('COM15','BaudRate',9600);
            fopen(arduinoCom3);
        end
        
        function sendarduino3(x)
            arduinoCom3 = serial('COM15','BaudRate',9600);
            fprintf(arduinoCom3,'%s',sendData);
            fscanf(arduinoCom3)
        end
        
        function closearduino3(x)
            arduinoCom3 = serial('COM15','BaudRate',9600);
            fclose(arduinoCom3);
        end
        
        function close_arduino(obj)
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
                fclose(serialObj(i));
            end
        end
 
            x = char(x);
                
            sendData = x(4:15);
            sendData = strcat('<', sendData, '>');
           
                
            end
            function VoltRead=PS_VoltRead(obj)
                fprintf(obj.gpib_obj,'VOLT?');
                VoltStr=fscanf(obj.gpib_obj);
                VoltRead=str2num(VoltStr);
            end
            function PS_VoltSet(obj,Volt_Set)
                VoltSetStr=sprintf('VOLT %d V',Volt_Set);
                fprintf(obj.gpib_obj,VoltSetStr);
            end
            function CurrRead=PS_CurrRead(obj)
                fprintf(obj.gpib_obj,'CURR?');
                CurrStr=fscanf(obj.gpib_obj);
                CurrRead=str2num(CurrStr);
            end
            function PS_CurrSet(obj,Curr_Set)
                CurrSetStr=sprintf('CURR %d A',Curr_Set);
                fprintf(obj.gpib_obj,CurrSetStr);
            end
            
            function PS_OUTOn(obj)
                fprintf(obj.gpib_obj,'OUTP ON');
            end
            function PS_OUTOff(obj)
                fprintf(obj.gpib_obj,'OUTP OFF');
            end
            
        end
    end