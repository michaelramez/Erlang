-module(subscriber_mnesia).
-export([start/0,store_subscriber/1, update_subscriber/1, delete_subscriber/1, lookup_subscriber/1]).

-record(subscriber, {sub_id, account_id, last_deduction_date, next_deduction_date, installments_remaining, 
installments_completed}).
% -record(subscriber, {sub_id, account_id}).
start() ->
    start_node_mnesia(),
    create_subscribers_table().

start_node_mnesia() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    io:format("Mnesia Successfully started~n").

create_subscribers_table() ->
   mnesia:create_table(subscriber, [{attributes, record_info(fields, subscriber)}]),
   io:format("Table subscriber successfully created~n"). 


store_subscriber(Subscriber) ->
    mnesia:dirty_write(Subscriber),
    io:format("Successfully inserted~n").


update_subscriber(Subscriber) ->
    SubscriberID = Subscriber#subscriber.account_id,
    SubscriberFromDB = lookup_subscriber(SubscriberID),
    check_and_update(Subscriber, SubscriberFromDB).

check_and_update(_, []) ->
    io:format("Subscriber does not exist~n");

check_and_update(Subsciber, _) ->
    mnesia:dirty_write(subscriber, Subsciber).

delete_subscriber(Subscriber) ->
    mnesia:dirty_delete_object(Subscriber).

lookup_subscriber(SubscriberID) ->
    io:format("looking for subscriber with id = ~p~n", [SubscriberID]),
    mnesia:dirty_read(subscriber, SubscriberID).

