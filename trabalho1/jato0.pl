% Jato 0
:- module(jato0, [obter_controles/2]).

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

caminho_mais_livre(SA, SB, AA, BB) :-
    SA < SB,
    AA is 1,
    BB is 0.

caminho_mais_livre(SA, SB, AA, BB) :-
    SA > SB,
    AA is 0,
    BB is 1.

caminho_mais_livre(SA, SB, AA, BB) :-
    SA = SB,
    random_between(0,1,AA),
    troca(AA, BB).


%% CENÁRIO DE FINAL DA PARTIDA

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 0, 1]) :-
    S1 =< 0.2,
    S2 =< 0.2,
    S3 =< 0.2,
    S4 =< 0.2,
    S5 =< 0.2,
    S6 =< 0.2,
    S7 =< 0.2,
    S8 =< 0.2,
    S9 =< 0.2,
    S10 =< 0.2.


%% CENÁRIO DE SOBREPOSIÇÃO DE JATOS

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 0, 1]) :-
    S1 >= 0.8,
    S2 >= 0.8,
    S3 >= 0.8,
    S4 >= 0.8,
    S5 >= 0.8,
    S6 >= 0.8,
    S7 >= 0.8,
    S8 >= 0.8,
    S9 >= 0.8,
    S10 >= 0.8.

%%%% CENÁRIO S5 (FRENTE) ----------------------------------------------------------------------------

% 1 -> nao detecta obstáculo e somente anda para frente 
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 0, 0]) :-
    S5 = 0.

% 2 -> detecta obstáculo à frente, dispara e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, AA, BB, 1]) :-
    S5 =< 0.3,
    caminho_mais_livre(S4, S6, AA, BB).

% 3 -> detecta obstáculo se aproximando, atira, para de acelerar e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, AA, BB, 1]) :- 
    S5 > 0.3,
    S5 < 0.75,
    caminho_mais_livre(S4, S6, AA, BB).


%% CENÁRIO DE CANTOS 

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 1, 0]) :-
    S1 >= 0.75,
    S2 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 1, 0]) :-
    S2 >= 0.75,
    S3 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 0, 1, 0]) :-
    S3 >= 0.75,
    S4 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 0]) :-
    S4 >= 0.75,
    S5 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, AA, BB, 1]) :-
    S4 >= 0.60,
    S5 >= 0.60,
    S6 >= 0.60,
    caminho_mais_livre(S2, S8, AA, BB).

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 0]) :-
    S6 >= 0.75,
    S7 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 0]) :-
    S7 >= 0.75,
    S8 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 1, 0, 0]) :-
    S8 >= 0.75,
    S9 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 1, 0, 0]) :-
    S9 >= 0.75,
    S10 >= 0.75.

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 1, 0, 0]) :-
    S10 >= 0.75,
    S1 >= 0.75.

%% CENÁRIOS DE BATIDAS

% 1 -> batida de frente e virar para o lado mais "limpo"

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, AA, BB, 1]) :-
    S5 >= 0.75,
    caminho_mais_livre(S4, S6, AA, BB).

% 5 -> batida em S4
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 0, 1, 1]) :-
    S4 >= 0.75.

% 6 -> batida em S6
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 1]) :-
    S6 >= 0.75.

% 7 -> batida em S7
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 0]) :-
    S7 >= 0.75.

% 3 -> batida em S2
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 0, 1, 0]) :-
    S2 >= 0.75.

% 4 -> batida em S3
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 0, 1, 0]) :-
    S3 >= 0.75.

% 8 -> batida em S8
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, 1, 0, 0]) :-
    S8 >= 0.75.

% 9 -> batida em S9
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 1, 0, 0]) :-
    S9 >= 0.75.

% 2 -> batida em S1
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 0, 1, 0]) :-
    S1 >= 0.75.

% 10 -> batida em S10
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, 1, 0, 0]) :-
    S10 >= 0.75.





%%%% CENÁRIO S6 (DIREITA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a direita, dispara e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, AA, BB, 0]) :-
    S6 > 0.3,
    S6 < 0.5,
    caminho_mais_livre(S5, S7, AA, BB).

% 2 -> detecta obstáculo próximo a direita, dispara, desacelera e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, AA, BB, 1]) :-
    S6 >= 0.5,
    S6 < 0.75,
    caminho_mais_livre(S5, S7, AA, BB).


%%%% CENÁRIO S4 (ESQUERDA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a esquerda, dispara e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, AA, BB, 1]) :-
    S4 > 0.3,
    S4 < 0.5,
    caminho_mais_livre(S3, S5, AA, BB).


% 2 -> detecta obstáculo proximo a esquerda, dispara, desacelera e vira para o caminho mais livre
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 1, AA, BB, 1]) :-
    S4 >= 0.5,
    S4 < 0.75,
    caminho_mais_livre(S3, S5, AA, BB).


%%%% CENÁRIO S10 (ATRÁS) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo e tenta fugir 
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [1, 0, AA, BB, 0]) :-
    S10 > 0.3,
    caminho_mais_livre(S4, S6, AA, BB).


%%%% CENÁRIO S9 (DIREITA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a direita, vira a esquerda
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 1, 0, 0]) :-
    S9 > 0.3.


%%%% CENÁRIO S1 (ESQUERDA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a esquerda, vira a direita
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 0, 1, 0]) :-
    S1 > 0.3.



%%%% CENÁRIO S7 (DIREITA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a direita, vira a esquerda
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 1, 0, 0]) :-
    S7 >= 0.5.



%%%% CENÁRIO S3 (ESQUERDA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a esquerda, vira a direita
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 0, 1, 0]) :-
    S3 >= 0.5.



%%%% CENÁRIO S8 (DIREITA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a direita, vira a esquerda
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 1, 0, 0]) :-
    S8 >= 0.5.


%%%% CENÁRIO S2 (ESQUERDA) ----------------------------------------------------------------------------

% 1 -> detecta obstáculo a esquerda, vira a direita
obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [0, 0, 0, 1, 0]) :-
    S2 >= 0.5.



%%%% CENÁRIOS ALEATÓRIOS ----------------------------------------------------------------------------

troca(0, 1).
troca(1, 0).
% [FORWARD, REVERSE, LEFT, RIGHT, BOOM]
%obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [FORWARD, REVERSE, LEFT, RIGHT, BOOM]) :-
%    random_between(0,1,AA),
%    troca(AA, BB),
%    random_between(0,1,CC),
%    FORWARD is AA,
%    REVERSE is 0,
%    LEFT is AA,
%    RIGHT is BB,
%    BOOM is CC.

% Para evitar erros, o jato para:
% obter_controles(_, [0,0,0,0,0]).
