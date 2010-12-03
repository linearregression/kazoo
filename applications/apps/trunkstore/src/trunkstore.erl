-module(trunkstore).

-author('James Aimonetti <james@2600hz.com>').
-export([start/0, start_link/0, stop/0, set_amqp_host/1, set_couch_host/1]).

%% @spec start_link() -> {ok,Pid::pid()}
%% @doc Starts the app for inclusion in a supervisor tree
start_link() ->
    start_deps(),
    trunkstore_sup:start_link().

%% @spec start() -> ok
%% @doc Start the callmgr server.
start() ->
    application:start(trunkstore).

start_deps() ->
    trunkstore_deps:ensure(),
    ensure_started(sasl),
    ensure_started(crypto),
    ensure_started(whistle_amqp),
    ensure_started(whistle_couch),
    ensure_started(dynamic_compile),
    ensure_started(log_roller),
    ensure_started(ibrowse).

%% @spec stop() -> ok
%% @doc Stop the callmgr server.
stop() ->
    application:stop(trunkstore).

ensure_started(App) ->
    case application:start(App) of
	ok ->
	    ok;
	{error, {already_started, App}} ->
	    ok
    end.

set_amqp_host(H) ->
    ts_responder:set_amqp_host(H).

set_couch_host(H) ->
    ts_responder:set_couch_host(H).
