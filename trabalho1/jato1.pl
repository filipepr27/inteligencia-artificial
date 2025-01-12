% Jato 1
:- module(jato1, [obter_controles/2]).

%% Explicação:
% Sensores:
% X: posição horizontal do jato
% Y: posiçao vertical do jato
% ANGLE: angulo de inclinacao do jato: 0 para virado para frente até PI*2 (~6.28)
% Sensores: olhe em "doc/info.png"
%   S1,S2,S3,S4,S5,S6,S7,S8,S9,S10: valores de 0 à 1, onde 0 indica sem obstáculo e 1 indica tocando o jato
% SCORE: inteiro com a "vida" do jato. Em zero, ele perdeu
% SPEED: velocidade do jato
% Controles:
% [FORWARD, REVERSE, LEFT, RIGHT, BOOM]
% FORWARD: 1 para acelerar e 0 para continuar a velocidade atual
% REVERSE: 1 para desacelerar e 0 para continuar a velocidade atual
% LEFT: 1 para ir pra esquerda e 0 para não ir
% RIGHT: 1 para ir pra direita e 0 para não ir
% BOOM: 1 para tentar disparar (BOOM). Obs.: ele só pode disparar uma bala a cada segundo
% obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [FORWARD, REVERSE, LEFT, RIGHT, BOOM]) :-
%     FORWARD is 1,
%     REVERSE is 0,
%     LEFT is 1,
%     RIGHT is 0,
%     BOOM is 1.

%%% Faça seu codigo a partir daqui, sendo necessario sempre ter o predicado:
%%%% obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,SCORE], [FORWARD, REVERSE, LEFT, RIGHT, BOOM]) :- ...

troca(0, 1).
troca(1, 0).
% [FORWARD, REVERSE, LEFT, RIGHT, BOOM]
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [FORWARD, REVERSE, LEFT, RIGHT, BOOM]) :-
    random_between(0,1,AA),
    troca(AA, BB),
    random_between(0,1,CC),
    FORWARD is AA,
    REVERSE is BB,
    LEFT is AA,
    RIGHT is BB,
    BOOM is CC.

% Para evitar erros, o jato para:
obter_controles(_, [0,0,0,0,0]).
