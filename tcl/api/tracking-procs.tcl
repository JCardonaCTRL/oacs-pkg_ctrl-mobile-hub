ad_library {

    Set of TCL procedures to handle tracking events in the app

    @author JC
    @cvs-id $Id$
    @creation-date 2021-06-07

}

namespace eval dap::api::tracking_events {}

ad_proc -public dap::api::tracking_events::record {
    -tile_code:required
    -tile_module:required
    -action:required
    -context:required
} {
    Records a new tracking event in the app
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1

    ctrl::oauth::check_auth_header
    set user_id     $user_info(user_id)
    set token_str   $user_info(token_str)

    if {$user_id eq "" || $user_id == 0} {
        set response_code       "INVALID"
        set response_message    "Unauthorized : Undefined user"
        set continue_p 0
    }

    if {$continue_p} {
        db_transaction {
            dgit::tracking_events::new \
                -creation_user $user_id \
                -tile_code $tile_code \
                -tile_module $tile_module \
                -action $action \
                -context $context

            set response_code       "Ok"
            set response_message    "Tracking event recorded"
        } on_error {
            set response_code       "Error"
            set response_message    "Tracking event not recorded: $errmsg"
        }
    }

    if {$response_body eq ""} {
        set return_data_json [ctrl::restful::api_return -response_code "$response_code" \
                                                        -response_message "$response_message" \
                                                        -response_body ""]
    } else {
        set return_data_json [ctrl::restful::api_return -response_code "$response_code" \
                                                        -response_message "$response_message" \
                                                        -response_body "$response_body" \
                                                        -response_body_value_p f]
    }
    doc_return 200 application/json $return_data_json
    ad_script_abort
}
