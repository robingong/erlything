%% Copyright (c) 2013 Ulf Angermann
%% See MIT-LICENSE for licensing information.

%%% -------------------------------------------------------------------
%%% Author  : Ulf Angermann uaforum1@googlemail.com
%%% Description :
%%%
%%% Created :  
-module(hc_sr501_driver).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../include/horst.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([init/1]).
-export([handle_msg/3]).
%% --------------------------------------------------------------------
%% if you want to initialize during startup, you have to do it here
%% --------------------------------------------------------------------
init(Config) ->
	lager:info("~p:init('~p')", [?MODULE, Config]),
    {driver, {Module, _Func}, Module_config} = lists:keyfind(driver, 1, Config),
    [Pin, Int_type] = config:get_values([pin, int_type], Module_config),
	gpio:set_interrupt(Pin, Int_type),
	{ok, Config}.

handle_msg({gpio_interrupt, 0, Pin, Status}, Config, Modul_config) ->
	send(Config, Status),
	thing:set_value(self(), Status),	
	Module_config_1 = lists:keyreplace(last_changed, 1, Modul_config, {last_changed, date:get_date_seconds()}),
	lists:keyreplace(driver, 1, Config, {driver, {?MODULE, handle_msg}, Module_config_1});

%%
%% This function handles unknwon messages.
%%
handle_msg(Unknown_message, Config, Module_config) ->
    lager:warning("~p got an unkown message with values: ~p",[?MODULE, Unknown_message]),
    Config.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
send(Config, 1) ->
    ?SEND(?RISING);
send(Config, 0) ->
	?SEND(?FALLING).
%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.
