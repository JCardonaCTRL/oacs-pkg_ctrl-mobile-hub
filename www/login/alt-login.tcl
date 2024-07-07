ad_page_contract {
    Prompt the user for email and password.
} {
    {authority_id:naturalnum ""}
    {username ""}
    {email ""}
    {return_url:localurl ""}
    {host_node_id:naturalnum ""}
} -validate {
    valid_email -requires email {
        if {![regexp {^[\w.@+/=$%!*~-]+$} $email]} {
            ad_complain "invalid email address"
        }
    }
}

set subsite_id [ad_conn subsite_id]
set return_url "[ad_conn package_url]login/userProfile"

security::csp::require "style-src" "cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css"
security::csp::require "style-src" "cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.47/css/bootstrap-datetimepicker.min.css"



# Persistent login
set default_persistent_login_p 0


set subsite_url [subsite::get_element -element url]
set system_name [ad_system_name]
set authority_options [auth::authority::get_authority_options]
set authority_id [lindex $authority_options 0 1]

set login_button [list [list [_ acs-subsite.Log_In] ok]]
ad_form \
    -name login \
    -html { class "form-vertical" } \
    -show_required_p 0 \
    -edit_buttons $login_button \
    -action "[ad_conn package_url]login/alt-login" \
    -form {
        {return_url:text(hidden)}
        {time:text(hidden)}
        {host_node_id:text(hidden),optional}
        {token_id:integer(hidden)}
        {hash:text(hidden)}
        {email:email(text),nospell
            {label "[_ acs-subsite.Email]"}
            {html {class "form-control" required "required"}}
        }
        {password:text(password)
            {label "[_ acs-subsite.Password]"}
            {html {class "form-control"  required "required"}}
        }
    } -validate {
        { token_id {$token_id < 2**31} "invalid token id"}
    }

set username_widget text

set focus {}
set user_id_widget_name email
if { $email ne "" } {
    set focus "password"
} else {
    set focus "email"
}
set focus "login.$focus"


ad_form -extend -name login -on_request {
    # Populate fields from local vars

    # One common problem with login is that people can hit the back button
    # after a user logs out and relogin by using the cached password in
    # the browser. We generate a unique hashed timestamp so that users
    # cannot use the back button.

    set time [ns_time]
    set token_id [sec_get_random_cached_token_id]
    set token [sec_get_token $token_id]
    set hash [ns_sha1 "$time$token_id$token"]

} -on_submit {

    # Check timestamp
    set token [sec_get_token $token_id]
    set persistent_p "f"
    if {![element exists login email]} {
        set email [ns_queryget email ""]
    }
    set first_names [ns_queryget first_names ""]
    set last_name   [ns_queryget last_name ""]

    array set auth_info [auth::authenticate \
                             -return_url $return_url \
                             -authority_id $authority_id \
                             -email [string trim $email] \
                             -first_names $first_names \
                             -last_name $last_name \
                             -username [string trim $username] \
                             -password $password \
                             -host_node_id $host_node_id \
                             -persistent=$persistent_p]

    # Handle authentication problems
    switch $auth_info(auth_status) {
        ok {
            # Continue below
        }
        bad_password {
            form set_error login password $auth_info(auth_message)
            break
        }
        default {
            form set_error login $user_id_widget_name $auth_info(auth_message)
            break
        }
    }

    if { [info exists auth_info(account_url)] && $auth_info(account_url) ne "" } {
        ad_returnredirect $auth_info(account_url)
        ad_script_abort
    }

    # Handle account status
    switch $auth_info(account_status) {
        ok {
            # Continue below
        }
        default {
            # if element_messages exists we try to get the element info
            if {[info exists auth_info(element_messages)]
            && [auth::authority::get_element \
                -authority_id $authority_id \
                -element allow_user_entered_info_p]} {
                foreach message [lsort $auth_info(element_messages)] {
                    ns_log notice "LOGIN $message"
                    switch -glob -- $message {
                    *email* {
                        if {[element exists login email]} {
                        set operation set_properties
                        } else {
                        set operation create
                        }
                        element $operation login email \
                                        -widget $username_widget \
                                        -datatype text \
                                        -label [_ acs-subsite.Email]
                        if {[element error_p login email]} {
                        template::form::set_error login email [_ acs-subsite.Email_not_provided_by_authority]
                        }
                    }
                    *first* {
                        element create login first_names \
                                        -widget text \
                                        -datatype text \
                                        -label [_ acs-subsite.First_names]
                        template::form::set_error login email [_ acs-subsite.First_names_not_provided_by_authority]
                    }
                    *last* {
                        element create login last_name \
                                        -widget text \
                                        -datatype text \
                                        -label [_ acs-subsite.Last_name]
                        template::form::set_error login last_name [_ acs-subsite.Last_name_not_provided_by_authority]
                    }
                    }
                }
                set auth_info(account_message) ""
                ad_return_template

            } else {
                set message [expr { [info exists auth_info(account_message)] ? $auth_info(account_message) : "" }]
                # Display the message on a separate page
                ad_returnredirect \
                -message $message \
                -html \
                "[apm_package_url_from_key 'ctrl-mobile-hub']login/alt-login"
                ad_script_abort
            }
        }
    }
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
