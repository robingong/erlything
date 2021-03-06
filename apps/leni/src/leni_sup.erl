%%
%% Copyright (c) 2013 Ulf Angermann  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%%% -------------------------------------------------------------------
%%% Author  : Ulf Angermann uaforum1@googlemail.com
%%% Description :
%%%
%%% Created : 

-module(leni_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type, Arg), {I, {I, start_link, [Arg]}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Ip = get_ip(),
    {ok, Dispatch} = file:consult(filename:join([filename:dirname(code:which(?MODULE)), "..", "priv", "dispatch.conf"])),
    WebConfig = [
                 {ip, Ip},
                 {port, get_port()},                 
                 {dispatch, Dispatch},
                 {dispatch_group, leni},
                 {name, leni},
                 {error_handler, leni_webmachine_error_handler}
                 ],               
    Web = {wm_instance_2, {webmachine_mochiweb, start, [WebConfig]}, permanent, 5000, worker, dynamic},
    Processes = [Web],
    {ok, { {one_for_one, 10, 10}, Processes} }.


get_port() ->
    {ok, Port} = application:get_env(leni, port),
    Port.

get_ip() ->
    case application:get_env(moni, ip) of 
        undefined ->  "0.0.0.0";
        {ok, Ip} -> Ip
    end.