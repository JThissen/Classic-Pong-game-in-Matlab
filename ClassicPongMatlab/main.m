%Made by Joost Thissen s1767089 for PiE

%Welcome to PONG reloaded!
%This is a two-dimensional, two player game that is very similar to table
%tennis. Players control an in-game peddle by moving it vertically
%across the left side of the screen. Players use the paddle to hit a ball
%back and forth. The aim is for each player to reach three points before the
%opponent; points are earned when a player makes a goal.

%Controls
%Player 1: arrow key Up, arrow key Down
%Player 2: W, S
%The game may be restarted at any time by pressing the R key.

%Features
%800 x 500 px game window
%two controllable peddles, a moving ball, two goals and a scoreboard
%the ball accelerates as the game progresses in order to increase the
%difficulty.

%note that the game balance is not completely optimized. The speed/size of
%of both the peddles and the ball may be increased/decreased to your
%liking by adjusting the code below. This holds true for the acceleration of
%the ball and its maximum speed as well.

%Have fun!

function [] = main()
start_game = 0;
game_width = 800;
game_height = 500;
axis_width = 100;
axis_height = 100;
ball = [];
ball_xpos = [axis_width/2];
ball_ypos = [axis_height/2];
draw_element_1 = [];
draw_element_2 = [];
from_goal = 7;
element_height = 15;
element_width = 2;
element = [0, element_width,element_width,0,0;element_height,element_height,0,0,element_height];
element_1 = [element(1,:) + from_goal; element(2,:)+((axis_height-element_height)/2)];
element_2 = [element(1,:) + axis_width-from_goal-element_width; element(2,:)+((axis_height-element_height)/2)];
element_1_speed = 0;
element_2_speed = 0;
element_speed = 1;
random_dir_x = [-0.8,0.8];
random_dir_y = [-1,1];
ball_dx = random_dir_x(randi(numel(random_dir_x)));
ball_dy = random_dir_y(randi(numel(random_dir_y)));
ball_speed = 0.5;
ball_radius = 1.5;
score_p1 = {'','I','I','I','I','I'};
score_p2 = {'','I','I','I','I','I'};
counter_p1 = 1;
counter_p2 = 1;
text_move_p1 = [1,2,3,4,5,6];
text_move_p2 = [1,2,3,4,5,6];
text_counter_p1 = 1;
text_counter_p2 = 1;
adj_factor = 1; %prevents collision bugs when the ball touches the elements
ball_acc = 0;
ball_acc_per_touch = 0.05;
max_acc = 0.5;
set_true_false = true;
[a, b] = audioread('duel_zone.mp3');
%[c, d] = audioread('battlefield.mp3');
[e, f] = audioread('battlefield_melee.mp3');

    function [] = main_game_interface()
        screen = get(0,'screensize');
        main_screen = figure('position', [(screen(3)-game_width)/2, (screen(4)-game_height)/2, game_width, game_height]); %left, bot, width, height
        set(main_screen,'menubar','none');
        set(main_screen,'resize','off');
        axis([0,axis_width, 0, axis_height]); %xmin, xmax, ymin, ymax
        set(main_screen,'keypressfcn',@move, 'keyreleasefcn',@do_not_move);
        set(main_screen,'numbertitle','off','name','PONG reloaded');
        
        %colours/images/background
        bg_img = imread('gradient2.jpg');
        image('CData',flipdim(bg_img,1), 'xdata', [0,100],'ydata',[0,100]);
        text(41,90,'PONG','color','w','fontsize',30,'fontweight','bold');
        text(45,84,'reloaded','color',([164/255, 255/255, 33/255]),'fontsize',12,'fontweight','bold');
        text(0,-3,'First player to obtain 3 points wins!','color','w','fontsize',8,'fontweight','bold');
        text(0,-6,'Press R to restart the game at any time.','color','w','fontsize',8,'fontweight','bold');
        text(0,-9,'Player 1: W,S          Player 2: Up,Down','color','w','fontsize',8,'fontweight','bold');
        text(83,-9,'Joost Thissen s1767089 PiE','color','w','fontsize',6,'fontweight','bold');
        
        set(gca, 'color', ([90/255, 90/255, 90/255]), 'xtick', [], 'ytick', []);%where gca is current chart
        set(main_screen,'color',[0/255, 0/255, 0/255]);
        
        %draw score
        text(5,105, 'Score P1:','color','w','fontsize',10,'fontweight','bold');
        text(85,105, 'Score P2:','color','w','fontsize',10,'fontweight','bold');
       
        %draw edges
        hold on;
        plot([0,0,axis_width,axis_width], [75,100,axis_width,75],'-','linewidth',2,'color',([255/255, 255/255, 255/255])); %top
        plot([0,0,axis_width,axis_width], [25,0,0,25],'-','linewidth',2,'color',([255/255, 255/255, 255/255])); %bot
        
        %draw field lines
        plot([50,50],[0,axis_height],'--','linewidth',1,'color',([255/255, 255/255, 255/255]));
        plot([48,52],[axis_height/2, axis_height/2],'-','linewidth',1,'color',([255/255, 255/255, 255/255]));
        
        %draw ball
        ball = plot(50,50);
        %ball_img = imread('ball.jpg');
        %image('CData',ball_img, 'xdata', ball_xpos,'ydata',ball_ypos)
        set(ball,'marker','o','color','g', 'markerSize',10,'markerFaceColor',([164/255, 255/255, 33/255]));
        
        %draw 2 movable elements
        draw_element_1 = plot(0,0,'-','color',([164/255, 255/255, 33/255]),'linewidth',1);
        draw_element_2 = plot(0,0,'-','color',([164/255, 255/255, 33/255]),'linewidth',1);
        
        set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
        set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:)); 
    end

    function [] = countdown()
        ready = text(38,70,'READY?','color','w','fontsize',30,'fontweight','bold');
        [y, Fs] = audioread('ready.wav');
        sound(y, Fs);
        pause(1.5);
        delete(ready);
        three = text(48,70,'3','color','w','fontsize',30,'fontweight','bold');
        [y, Fs] = audioread('3.wav');
        sound(y, Fs);
        pause(1);
        delete(three);
        two = text(48,70,'2','color','w','fontsize',30,'fontweight','bold');
        [y, Fs] = audioread('2.wav');
        sound(y, Fs);
        pause(1);
        delete(two)
        one = text(48,70,'1','color','w','fontsize',30,'fontweight','bold');
        [y, Fs] = audioread('1.wav');
        sound(y, Fs);
        pause(1);
        delete(one);
        go = text(45,70,'GO!','color','w','fontsize',30,'fontweight','bold');
        [y, Fs] = audioread('go.wav');
        sound(y, Fs);
        pause(0.5);
        delete(go);
        start_game = 1;
    end
   
    function [] = bg_themes()
        sound(a,b);
        if (start_game == 0)
            clear sound;
        end
    end

    function [] = Refresh_screen()
        set(ball, 'xdata', ball_xpos, 'ydata', ball_ypos);
        set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
        set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:));
        drawnow;
        
    end

    function [] = control_elements
        element_1(2,:) = element_1(2,:) + element_1_speed;
        element_2(2,:) = element_2(2,:) + element_2_speed;
        
        %element_1
        if(element_1(2,2) >= axis_height)
            element_1(2,:) = element(2,:) + axis_height - element_height;
        elseif(element_1(2,3) <= 0)
            element_1(2,:) = element(2,:);
        end
        %element_2
        if(element_2(2,2) >= axis_height)
            element_2(2,:) = element(2,:) + axis_height - element_height;
        elseif(element_2(2,3) <= 0)
            element_2(2,:) = element(2,:);
        end
    end

    function [] = do_not_move(src, event)
        switch event.Key
            case 'uparrow'
                if element_2_speed == element_speed;
                    element_2_speed = 0;
                end
            case 'downarrow'
                if element_2_speed == -element_speed;
                    element_2_speed = 0;
                end
            case 'w'
                if element_1_speed == element_speed;
                    element_1_speed = 0;
                end
            case 's'
                if element_1_speed == -element_speed;
                    element_1_speed = 0;
                end
        end
    end

    function [] = move(src, event)
        switch event.Key
            case 'uparrow'
                element_2_speed = element_speed;
            case 'downarrow'
                element_2_speed = -element_speed;
            case 'w'
                element_1_speed = element_speed;
            case 's'
                element_1_speed = -element_speed;
            case 'r'
                clear sound;
                close all;
                main();
        end
    end

    function [] = move_ball()
        ball_xpos =  ball_xpos + (ball_dx * (ball_speed + ball_acc));
        ball_ypos =  ball_ypos + (ball_dy * (ball_speed + ball_acc));
        
        %ELEMENT_2
        %left side
        if(ball_xpos + ball_radius >= (element_2(1,1)-adj_factor) && ball_xpos + ball_radius <= (element_2(1,1)+adj_factor)...
                && ball_ypos + ball_radius >= (element_2(2,3)-adj_factor) && ball_ypos - ball_radius <= (element_2(2,1)+adj_factor))
            ball_dx = -abs(ball_dx);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %right side
        if(ball_xpos - ball_radius <= (element_2(1,2)+adj_factor) && ball_xpos - ball_radius >=(element_2(1,2)-adj_factor)...
                && ball_ypos + ball_radius >= (element_2(2,3)-adj_factor) && ball_ypos - ball_radius <= (element_2(2,1)+adj_factor))
            ball_dx = abs(ball_dx);
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %bot
        if(ball_xpos + ball_radius >= (element_2(1,1)-adj_factor) && ball_xpos - ball_radius <=(element_2(1,1)+adj_factor)...
                && ball_ypos + ball_radius >= (element_2(2,3)-adj_factor) && ball_ypos + ball_radius <= (element_2(2,3)+adj_factor))
            ball_dy = -abs(ball_dy);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %top
        if(ball_xpos + ball_radius >= (element_2(1,1)-adj_factor) && ball_xpos - ball_radius <=(element_2(1,1)+adj_factor)...
                && ball_ypos - ball_radius <= (element_2(2,1)+adj_factor) && ball_ypos - ball_radius >= (element_2(2,1)-adj_factor))
            ball_dy = abs(ball_dy);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %ELEMENT_1
        %right side
        if(ball_xpos - ball_radius <= (element_1(1,2)+adj_factor) && ball_xpos - ball_radius >=(element_1(1,2)-adj_factor)...
                && ball_ypos + ball_radius >= (element_1(2,3)-adj_factor) && ball_ypos - ball_radius <= (element_1(2,1)+adj_factor))
            ball_dx = abs(ball_dx);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %left side
        if(ball_xpos + ball_radius >= (element_1(1,1)-adj_factor) && ball_xpos + ball_radius <=(element_1(1,1)+adj_factor)...
                && ball_ypos + ball_radius >= (element_1(2,3)-adj_factor) && ball_ypos - ball_radius <= (element_1(2,1)+adj_factor))
            ball_dx = -abs(ball_dx);   
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %bot
        if(ball_xpos + ball_radius >= (element_1(1,1)-adj_factor) && ball_xpos - ball_radius <=(element_1(1,1)+adj_factor)...
                && ball_ypos + ball_radius >= (element_1(2,3)-adj_factor) && ball_ypos + ball_radius <= (element_1(2,3)+adj_factor))
            ball_dy = -abs(ball_dy);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %top
        if(ball_xpos + ball_radius >= (element_1(1,1)-adj_factor) && ball_xpos - ball_radius <=(element_1(1,1)+adj_factor)...
                && ball_ypos - ball_radius <= (element_1(2,1)+adj_factor) && ball_ypos - ball_radius >= (element_1(2,1)-adj_factor))
            ball_dy = abs(ball_dy);
            ball_acc = ball_acc + ball_acc_per_touch;
            if(ball_acc >= max_acc)
                ball_acc = max_acc;
            end
            [y, Fs] = audioread('Beep2.wav');
            sound(y, Fs)
        end
        %right wall
        if((ball_xpos + ball_radius > axis_width) && ((ball_ypos > 75) || (ball_ypos < 25)))
           ball_dx = -abs(ball_dx);
           [y, Fs] = audioread('Beep1.wav');
           sound(y, Fs)
        end
        %left wall
        if((ball_xpos - ball_radius <= 0) && ((ball_ypos >75) || (ball_ypos < 25)))
            ball_dx = abs(ball_dx);
            [y, Fs] = audioread('Beep1.wav');
            sound(y, Fs)
        end
        %upper wall
        if(ball_ypos + ball_radius >= axis_height)
            ball_dy = -abs(ball_dy);
            [y, Fs] = audioread('Beep1.wav');
            sound(y, Fs)
        end
        %lower wall
        if(ball_ypos - ball_radius <= 0)
            ball_dy = abs(ball_dy);
            [y, Fs] = audioread('Beep1.wav');
            sound(y, Fs)
        end
    end

    function [] = goal()
    goal = false;
    if(ball_xpos + ball_radius > axis_width+2)
        goal = true;
        ball_acc = 0;
        [y, Fs] = audioread('goal.wav');
        sound(y, Fs)
        counter_p1 = counter_p1 + 1;
        text_counter_p1 = text_counter_p1 + 1;
        restart_game();
    end
    if(ball_xpos - ball_radius < -2)
        goal = true;
        ball_acc = 0;
        [y, Fs] = audioread('goal.wav');
        sound(y, Fs)
        counter_p2 = counter_p2 + 1;
        text_counter_p2 = text_counter_p2 + 1;
        restart_game();  
    end
    end

    function [] = restart_game()
        ball_xpos = [axis_width/2];
        ball_ypos = [axis_height/2];
        element_1 = [element(1,:) + from_goal; element(2,:)+((axis_height-element_height)/2)];
        element_2 = [element(1,:) + axis_width-from_goal-element_width; element(2,:)+((axis_height-element_height)/2)];
        pause(0.5);
        [y, Fs] = audioread('respawn.wav');
        sound(y, Fs)
        random_dir_x = [-0.8,0.8];
        random_dir_y = [-1,1];
        ball_dx = random_dir_x(randi(numel(random_dir_x)));
        ball_dy = random_dir_y(randi(numel(random_dir_y)));
        text(13+text_move_p1(text_counter_p1),105,(score_p1(counter_p1)),'color','g','fontsize',10,'fontweight','bold');
        text(93+text_move_p2(text_counter_p2),105,(score_p2(counter_p2)),'color','g','fontsize',10,'fontweight','bold');
        pause(0.3);
    end
    function [] = stage_2()
        if((counter_p1 == 3 || counter_p2 == 3) && set_true_false == true)
            clear sound;
            sound(e,f);
            set_true_false = false;
            if(counter_p1 == 3)
                about_to_win_p1 = text(32,70,'Player 1 is about to win!','color','w','fontsize',15,'fontweight','bold');
                set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
                set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:));
                pause(1.5);
                delete(about_to_win_p1);
            end
            if(counter_p2 == 3)
                about_to_win_p2 = text(32,70,'Player 2 is about to win!','color','w','fontsize',15,'fontweight','bold');
                set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
                set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:));
                pause(1.5);
                delete(about_to_win_p2);
            end
        end
    end


    function [] = winner()
        if(counter_p1 == 4)
            clear sound;
            [y, Fs] = audioread('game.wav');
            sound(y, Fs)
            set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
            set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:));
            pause(1)
            text(29,70,'Player 1 wins!','color','w','fontsize',30,'fontweight','bold');
            %player 2 defeated
            [y, Fs] = audioread('player2.wav');
            sound(y, Fs);
            pause(0.8)
            [y, Fs] = audioread('defeated.wav');
            sound(y, Fs);
            pause(5)
            clear sound;
            start_game = 0;
        end
        if(counter_p2 == 4)
            clear sound;
            [y, Fs] = audioread('game.wav');
            sound(y, Fs)
            set(draw_element_1, 'xdata', element_1(1,:),'ydata',element_1(2,:));
            set(draw_element_2, 'xdata', element_2(1,:),'ydata',element_2(2,:));
            pause(1)
            text(29,70,'Player 2 wins!','color','w','fontsize',30,'fontweight','bold');
            %player 1 defeated
            [y, Fs] = audioread('player1.wav');
            sound(y, Fs);
            pause(0.8)
            [y, Fs] = audioread('defeated.wav');
            sound(y, Fs);
            pause(5);
            start_game = 0;
        end
    end
            
main_game_interface();
countdown();
bg_themes();
while (start_game == 1)
    stage_2();
    control_elements();
    move_ball();
    Refresh_screen();
    goal();
    winner();
end
clear sound;
end