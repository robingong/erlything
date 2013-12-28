%% Copyright (c) 2013 Ulf Angermann
%% See MIT-LICENSE for licensing information.

%%% -------------------------------------------------------------------
%%% Author  : Ulf Angermann uaforum1@googlemail.com
%%% Description :
%%%
%%% Created : 04.11.2013
-module(cube_driver).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../include/horst.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([init/1, stop/1, handle_msg/3]).

init(Config) ->
    lager:info("~p:init('~p')", [?MODULE, Config]),
    case application:start(cuberl) of
        ok -> cuberl:register_listener(self()),
              ok;
        {error, {already_started, App}} ->
            ok
    end.
    

stop(Config) ->
    lager:info("~p:stop('~p')", [?MODULE, Config]),
    cuberl:disconnect(),
    application:stop(cuberl),
    application:unload(cuberl). 

handle_msg({external_event, cuberl,  {fatal, Reason}}, Config, Module_config) ->
    lager:info("~p got an fatal message with values: ~p. I will stop the cube.", [?MODULE, Reason]),
    stop(Config),
    Config;

handle_msg({external_event, cuberl,  Body}, Config, Module_config) ->
    lager:info("~p got a message with values: ~p", [?MODULE, Body]),
    send_message(Body),
    Config;

handle_msg({external_event, Application,  Body}, Config, Module_config) ->
    lager:warning("~p got a message with incorrect values: ~p", [?MODULE, {Application, Body}]),
    Config;

handle_msg([Node ,Sensor, Id, Time, Body], Config, Module_config) ->
    lager:warning("~p got a message with incorrect values: ~p", [?MODULE, [Node ,Sensor, Id, Time, Body]]),
    Config.

send_message(Body) ->
    Msg = sensor:create_message(node(), ?MODULE, Body), 
    sensor:send_message(Msg).
%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.