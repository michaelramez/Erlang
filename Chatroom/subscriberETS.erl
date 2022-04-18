-module(subscriberETS).
-export([start/0, connect/3, disconnect/2, get_online_users/1, get_all_sockets/1, get_socket/2, stop/1]).


start() ->
    ets:new(subscriber, [public]).

connect(Subscriber, Username, Socket) ->
    ets:insert_new(Subscriber, {Username, Socket}).

disconnect(Subscriber, Username) ->
    ets:delete(Subscriber, Username).

get_online_users(Subscriber) ->
    ets:match(Subscriber, {'$1', '_'}).

get_all_sockets(Subscriber) ->
    ets:match(Subscriber, {'_', '$1'}).

get_socket(Subsciber, Username) ->
    ets:lookup_element(Subsciber, Username, 2).

stop(Subscriber) ->
    ets:delete(Subscriber).
