-module(subscriberETS).
-export([start/0, connect/3, disconnect/2, get_socket/2, stop/1]).


start() ->
    ets:new(subscriber, []).

connect(Subscriber, Username, Socket) ->
    ets:insert(Subscriber, {Username, Socket}).


disconnect(Subscriber, Username) ->
    ets:delete(Subscriber, Username).

get_socket(Subsciber, Username) ->
    ets:lookup_element(Subsciber, Username, 2).

stop(Subscriber) ->
    ets:delete(Subscriber).
