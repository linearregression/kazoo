%%%-------------------------------------------------------------------
%%% @copyright (C) 2015, 2600Hz Inc
%%% @doc
%%%
%%% @end
%%% @contributors
%%%   Peter Defebvre
%%%-------------------------------------------------------------------
-module(teletype_port_utils).

-export([get_attachments/1]).
-export([fix_email/1]).
-export([fix_port_request_data/1]).

-include("../teletype.hrl").

-spec get_attachments(wh_json:object()) -> attachments().
-spec get_attachments(wh_json:object(), boolean()) -> attachments().
get_attachments(DataJObj) ->
    get_attachments(DataJObj, teletype_util:is_preview(DataJObj)).

get_attachments(_DataJObj, 'true') -> [];
get_attachments(DataJObj, 'false') ->
    PortReqId = wh_json:get_value(<<"port_request_id">>, DataJObj),
    Doc = wh_json:get_value(<<"port_request">>, DataJObj),

    lists:foldl(fun(Name, Acc) -> get_attachment_fold(Name, Acc, PortReqId, Doc) end
                ,[]
                ,wh_doc:attachment_names(Doc)
               ).

-spec get_attachment_fold(wh_json:key(), attachments(), ne_binary(), wh_json:object()) ->
                                 attachments().
get_attachment_fold(Name, Acc, PortReqId, Doc) ->
    {'ok', Attachment} = couch_mgr:fetch_attachment(?KZ_PORT_REQUESTS_DB, PortReqId, Name),
    ContentType = wh_doc:attachment_content_type(Doc, Name),
    [{ContentType, Name, Attachment}|Acc].

-spec fix_email(wh_json:object()) -> wh_json:object().
fix_email(ReqData) ->
    fix_email(ReqData
              ,wh_json:get_value([<<"port_request">>, <<"notifications">>, <<"email">>, <<"send_to">>], ReqData)
             ).

-spec fix_email(wh_json:object(), ne_binary() | ne_binaries()) -> wh_json:object().
fix_email(ReqData, <<_/binary>> = Email) ->
    wh_json:set_value(<<"to">>, [Email], ReqData);
fix_email(ReqData, [_|_]=Emails) ->
    wh_json:set_value(<<"to">>, Emails, ReqData).

-spec fix_port_request_data(wh_json:object()) -> wh_json:object().
fix_port_request_data(JObj) ->
    Routines = [fun fix_numbers/1
                ,fun fix_billing/1
               ],
    lists:foldl(fun(F, J) -> F(J) end, JObj, Routines).

-spec fix_numbers(wh_json:object()) -> wh_json:object().
fix_numbers(JObj) ->
    Numbers =  wh_json:foldl(fun fix_number_fold/3
                             ,[]
                             ,wh_json:get_value(<<"numbers">>, JObj)
                            ),
    wh_json:set_value(<<"numbers">>, Numbers, JObj).

-spec fix_number_fold(wh_json:object(), _, wh_json:keys()) -> wh_json:keys().
fix_number_fold(Number, _Value, Acc) ->
    [Number|Acc].

-spec fix_billing(wh_json:object()) -> wh_json:object().
fix_billing(JObj) ->
    wh_json:foldl(
      fun fix_billing_fold/3
      ,wh_json:delete_key(<<"bill">>, JObj)
      ,wh_json:get_value(<<"bill">>, JObj)
     ).

-spec fix_billing_fold(wh_json:key(), wh_json:json_term(), wh_json:object()) ->
                              wh_json:object().
fix_billing_fold(Key, Value, Acc) ->
    wh_json:set_value(<<"bill_", Key/binary>>, Value, Acc).
