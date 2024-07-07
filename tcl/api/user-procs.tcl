ad_library {

    Set of TCL procedures to handle base tile

    @author JC
    @cvs-id $Id$
    @creation-date 2020-07-04

}

namespace eval dap::api::user {}

ad_proc -public dap::api::user::login {
    -user:required
    -password:required
} {
    Returns the information of a user
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""

    array set auth  [auth::authenticate \
                        -username $user \
                        -password $password \
                        -no_cookie]

    if {$auth(auth_status) ne "ok" } {
        array set auth [auth::authenticate \
                            -email $user \
                            -password $password \
                            -no_cookie]
    }

    if {$auth(auth_status) ne "ok" } {
        ns_log debug "\ndap::api::user::login auth status $auth(auth_status)"
        set response_code       "Error"
        set response_message    "User not found"
    }


    if {$auth(auth_status) eq "ok"} {
        set user_id                 $auth(user_id)
        set authCtrlRestPackageId   [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter "authCtrlRestPackageId"]
        set field_list              [list jwt_type client_key public_key]

        ctrl::restful::jwt::get_setup -package_id $authCtrlRestPackageId -column_array "setup_info"
        foreach field $field_list {
            set $field $setup_info($field)
        }
        # Get all the tokens for the user and then we validate 
        set jwt_token  ""
        set token_list [db_list get_user_tokens ""]
        foreach token $token_list {
            switch $jwt_type {
                "shared_secret" {
                    if { [catch {set jwtTokenObject  [ctrl::jwt::cjwt_decode_token \
                                                        -jwt_token $token \
                                                        -secret $client_key]} fid]
                    } {
                        continue
                    }
                }
                "public_private_key" {
                    set root  [acs_root_dir]
                    if { [catch {set jwtTokenObject  [ctrl::jwt::cjwt_decode_token \
                                                        -jwt_token $token \
                                                        -public_key_file "${root}/${public_key}"]} fid]
                    } {
                        continue
                    }
                }
            }

            set valid_p       [$jwtTokenObject set isValid]
            set claims_list   [$jwtTokenObject set getClaimList]

            if {!$valid_p} {
                continue
            }

            # Get the value next to the exp tag
            set exp_pos         [lsearch $claims_list "exp"]
            set exp             [lindex $claims_list [expr {$exp_pos + 1}]]
            set current_time    [clock seconds]
            # 30 days in seconds. The time the token needs to be valid to be used in this page.
            set min_diff        [expr {30*24*60*60}]
            if {[expr {$current_time + $min_diff}] > $exp} {
                continue
            } else {
                set jwt_token $token
                break
            }
        }
        # If there is no valid token for the user, create a new one
        if {$jwt_token eq ""} {
            set jwt_token   [ctrl::restful::jwt::generate_token \
                                -package_id       $authCtrlRestPackageId \
                                -user_id          $user_id \
                                -field            "email" \
                                -field_type_label "email"]
        }

        acs_user::get -user_id $user_id -array user_info

        set body    [ctrl::json::construct_record   [list \
                                                        [list "name"        "$user_info(name)" ""] \
                                                        [list "uclaId"      "$user_info(screen_name)" ""] \
                                                        [list "firstName"   "$user_info(first_names)" ""] \
                                                        [list "lastName"    "$user_info(last_name)" ""] \
                                                        [list "email"       "$user_info(email)" ""] \
                                                        [list "userId"      "$user_info(user_id)" ""] \
                                                        [list "jwt"         "$jwt_token" ""] \
                                                    ]\
                    ]
        set response_code       "Ok"
        set response_message    "User found"
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

ad_proc -public dap::api::user::get_tiles_list {
} {
    Returns the tiles list of a user based on the group and tile relation
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1

    ctrl::oauth::check_auth_header
    set user_id         $user_info(user_id)
    set token_str       $user_info(cust_acc_token)

    if {$user_id eq "" || $user_id == 0} {
        set response_code       "INVALID"
        set response_message    "Unauthorized : Undefined user"
        set continue_p 0
    }

    set public_group        [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter "defaultPublicGroup"]
    set background_url      [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter "appBackgroundImageUrl"]
    set current_events_url  [parameter::get_from_package_key -package_key "ctrl-mobile-hub" -parameter "currentEventsUrl"]
    set version_id          [apm_version_id_from_package_key "ctrl-mobile-hub"]
    set group_type_name     "dgsom_app"
    set public_group_id     [db_string get_public_group "" -default 0]

    apm_version_get -version_id $version_id -array package_info
    set version_name        $package_info(version_name)

    if {$continue_p} {
        set tile_list_json  [list]
        set tags_list       [list]
        #Tile Elements
        db_foreach get "" {
            set tile_list       ""
            set app_code        [dap::tile::getModuleName -tile_id $tile_id]
            set deployable_p    [dap::tile::isDeployable? -tile_id $tile_id]

            if {$app_code eq "" || $deployable_p eq "" || !$deployable_p} {
                continue
            }

            lappend tile_list   [list "tileId" $tile_id ""]
            lappend tile_list   [list "refName" $package_key "" ]
            lappend tile_list   [list "version" $version "" ]

            set DAC [list]
            db_foreach get_dacs "" {
                set property    [string range $property 5 end]
                lappend DAC     [list "$property" $property_value ""]

                if {$property eq "appCode"} {
                    lappend tags_list [list "appCode_$property_value" "true" ""]
                }
            }
            set DAC                 [ctrl::json::construct_record $DAC]

            lappend tile_list       [list "appCustoms" $DAC "o"]
            lappend tile_list_json  [list [ctrl::json::construct_record $tile_list]]
        }
        #Group Elements
        set group_type_name "dgsom_app"
        db_foreach get_group_codes "" {
            lappend tags_list [list "appGroup_$group_code" "true" ""]
        }
        #App Info
        set app_info        [list   [list "appVersion" $version_name ""] \
                                    [list "currentEventsUrl" $current_events_url ""]\
                                    [list "appBackgroundImageUrl" $background_url ""]]
        set app_info_json   [ctrl::json::construct_record $app_info]
        #Tags
        set tags_list_json  [ctrl::json::construct_record $tags_list]

        set body    [ctrl::json::construct_record   [list \
                                                        [list "dgsomAppInfo" "$app_info_json" "o"]\
                                                        [list "tagsList" "$tags_list_json" "o"]\
                                                        [list "tileList" "$tile_list_json" "a"]\
                                                    ]\
                    ]

        set response_code       "Ok"
        set response_message    "User tile list"
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
