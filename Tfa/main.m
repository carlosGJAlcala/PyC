conectar;
coordenas_dst=[1,1];
coordenas_src=[0,0];
coordenas_curren;
ini_simulador;
%% codificacion




desconectar;

function resultado=isDst(coordenas_curren,coordenas_dst)
resutaldo=(coordenas_curren(1)==coordenas_dst(1))&&(coordenas_curren(2)==coordenas_dst(2))
end
function resultado=leerDatos()
msg_sonar0 = receive(sub_sonar0, 10);
msg_sonar1 = receive(sub_sonar1, 10);
msg_sonar2 = receive(sub_sonar2, 10);
msg_sonar3 = receive(sub_sonar3, 10);
msg_sonar4 = receive(sub_sonar4, 10);
msg_sonar5 = receive(sub_sonar5, 10);
msg_sonar6 = receive(sub_sonar6, 10);
msg_sonar7 = receive(sub_sonar7, 10);
msg_laser = sub_laser.LatestMessage;


distancia0=msg_sonar0.Range_;
distancia1=msg_sonar1.Range_;
distancia2=msg_sonar2.Range_;
distancia3=msg_sonar3.Range_;
distancia4=msg_sonar4.Range_;
distancia5=msg_sonar5.Range_;
distancia6=msg_sonar6.Range_;
distancia7=msg_sonar7.Range_;

end