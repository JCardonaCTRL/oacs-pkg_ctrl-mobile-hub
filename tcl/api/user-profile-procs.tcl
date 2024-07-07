ad_library {

    Set of TCL procedures to handle user profile from the API

    @author JC
    @cvs-id $Id$
    @creation-date 2021-07-23

}

namespace eval dap::api::user::profile {}

ad_proc -public dap::api::user::profile::create_or_update {
    -firstName
    -lastName
    -email
    -department
    -officeLocation
    -mobilePhone
} {
    Creates or updates the information for the user profile

    @see dap::user::profile::create_or_update
} {

    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1
    set status_code         200

    ctrl::oauth::check_auth_header
    set user_id         $user_info(user_id)
    set token_str       $user_info(cust_acc_token)

    if {$user_id eq "" || $user_id == 0} {
        set response_code       "INVALID"
        set response_message    "Unauthorized : Undefined user"
        set continue_p          0
        set status_code         401
    }

    if {$continue_p} {
        set init_list   [list   firstName first_name \
                                lastName last_name \
                                email email \
                                department department \
                                officeLocation office_location \
                                mobilePhone mobile_phone]
        set params_list [list]
        foreach {var param} $init_list {
            if {[info exists $var] && [set $var] ne ""} {
                set new_val [set $var]
                lappend params_list "-$param \"$new_val\""
            }
        }
        set params_list [join $params_list " "]
        set success_p   [dap::user::profile::create_or_update \
                            -user_id $user_id \
                            -creation_user $user_id \
                            {*}$params_list]

        if {$success_p} {
            set response_code       "Ok"
            set response_message    "User profile updated"
            set status_code         200
        } else {
            set response_code       "Error"
            set response_message    "User profile not updated"
            set status_code         500
        }
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
    doc_return $status_code application/json $return_data_json
    ad_script_abort
}