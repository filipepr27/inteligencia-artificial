%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Servidor em prolog

% Módulos:
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_dirindex)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_server_files)).
%DEBUG:
%:- use_module(library(http/http_error)).
%:- debug.

:- use_module(jatos_controle, [vez/3]).

% GET
:- http_handler(
    root(action), % Alias /action
    action,       % Predicado 'action'
    []).

:- http_handler(root(.), http_reply_from_files('.', []), [prefix]).

:- json_object
    controles(forward:integer, reverse: integer, left:integer, right:integer, boom:integer).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server(Port) :-
    http_stop_server(Port, []).

action(Request) :-
    http_parameters(Request,
                    % sensores do jato:
                    [ id(VEZ, [integer]),
                      x(X, [float]),
                      y(Y, [float]),
                      angle(ANGLE, [float]),
                      s1(S1, [float]),
                      s2(S2, [float]),
                      s3(S3, [float]),
                      s4(S4, [float]),
                      s5(S5, [float]),
                      s6(S6, [float]),
                      s7(S7, [float]),
                      s8(S8, [float]),
                      s9(S9, [float]),
                      s10(S10, [float]),
                      score(SCORE, [integer]),
                      speed(SPEED, [float])
                    ]),
    SENSORES = [X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED],
    vez(VEZ, SENSORES, CONTROLES),
    %DEBUG:
    %FORWARD is 0, REVERSE is 1, LEFT is 0, RIGHT is 1, BOOM is 1,
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM],
    prolog_to_json( controles(FORWARD, REVERSE, LEFT, RIGHT, BOOM), JOut ),
    reply_json( JOut ).

start :- format('~n~n--========================================--~n~n'),
         start_server(8080),
         format('~n~n--========================================--~n~n').
:- initialization start.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,SCORE,SPEED], [FORWARD, REVERSE, LEFT, RIGHT, BOOM]) :-
%%    random_between(0,1,AA),
%%    troca(AA, BB),
%%    random_between(0,1,CC),
%%    FORWARD is AA,
%%    REVERSE is 0,
%%    LEFT is AA,
%%    RIGHT is BB,
%%    BOOM is CC.
