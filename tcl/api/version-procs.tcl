ad_library {

    Set of TCL procedures to handle app version

    @author SH
    @creation-date 2022-01-26

}

namespace eval dap::api::version {}

ad_proc -public dap::api::version::info {
} {
    Returns the version info
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1

    ctrl::oauth::check_auth_header
    set user_id     $user_info(user_id)
    set token_str   $user_info(token_str)

    if {[empty_string_p $user_id] || $user_id == 0} {
        set continue_p 0
        set response_code       "INVALID"
        set response_message    "Unauthorized : Undefined user"
    }

    if {$continue_p} {
        set currentVersion        [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter currentVersion]
        set minimumVersion        [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter minimumVersion]
        set minimumVersionMessage [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter minimumVersionMessage]
        set body    [ctrl::json::construct_record   [list \
                                                        [list "currentVersion" "$currentVersion" ""] \
                                                        [list "minimumVersion" "$minimumVersion" ""] \
                                                        [list "minimumVersionMessage" "$minimumVersionMessage" ""] \
                                                    ]\
                    ]
        set response_code       "Ok"
        set response_message    "Version Information"
        set response_body       $body
    }


    if {[empty_string_p $response_body]} {
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
