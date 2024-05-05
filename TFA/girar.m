function resultado=girar(angulo_giro)
    ini_simulador;
    lee_sensores;
    th= angulo_giro*(3.14/180);
    msg_vel.Angular.Z= 0.6;
    if (th<0)
        msg_vel.Angular.Z = msg_vel.Angular.Z * -1;
    end
    yaw=0.0;
    initori = sub_odom.LatestMessage.Pose.Pose.Orientation;
    ang_euler=quat2eul([initori.W initori.X initori.Y initori.Z]);
    yawini=ang_euler(1);  
    disp(yawini);
    i=0;
    
    while(1)
        i=i+1;
        ori = sub_odom.LatestMessage.Pose.Pose.Orientation;
        ang_euler1=quat2eul([ori.W ori.X ori.Y ori.Z]);
        yaw=ang_euler1(1);
        ang=angdiff(yawini,yaw);
        disp(ang);
        if(abs(ang)>abs(th))    
            msg_vel.Angular.Z=0.0;
            send(pub_vel,msg_vel);
            break;
        else
            if msg_vel.Angular.Z > 1 
                msg_vel.Angular.Z = 1;
            end
            send(pub_vel,msg_vel);
        end
        lee_sensores;
        waitfor(r);
    end    
end