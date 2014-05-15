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
    {driver, {Module, Func}, Module_config} = lists:keyfind(driver, 1, Config),
    [Pin, Int_type] = config:get_values([pin, int_type], Module_config),
	gpio:set_interrupt(Pin, Int_type),
	{ok, Config}.

handle_msg({gpio_interrupt, 0, Pin, Status}, Config, Modul_config) ->
	Msg = create_message(Status, config_handler:get_id(Config)),
	sensor:send_message(Msg),
	thing:set_value(self(), create_value(Status)),
	lager:debug("send message : ~p", [Msg]),
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
create_value(1) ->
	?RISING;
create_value(0) ->
	?FALLING.
create_message(1, Id) ->
	sensor:create_message(node(), ?MODULE, Id, date:get_date_seconds(), ?RISING);
create_message(0, Id) ->
	sensor:create_message(node(), ?MODULE, Id, date:get_date_seconds(), ?FALLING).
%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.
