ad_library {

    Set of TCL procedures to handle base tile

    @author JC
    @cvs-id $Id$
    @creation-date 2020-06-16

}

namespace eval dap::api::tile {}

ad_proc -public dap::api::tile::info {
    -appCode:required
} {
    Returns the information of a tile<br>
    DAC, DAI, DATC, DATI properties

    @option tile_id package_id of the tile instance
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

    set tile_id [dap::tile::getIdFromAppCode -app_code $appCode]

    if {$tile_id eq -1} {
        set continue_p          0
        set response_code       "Error"
        set response_message    "Tile not found"
    }

    if {$continue_p} {
        set version         [dap::tile::getVersion -tile_id $tile_id]
        set package_key     [dap::tile::getRefKey  -tile_id $tile_id]

        set DATC    [list]
        set DATI    [list]
        set DAC     [list]

        db_foreach get "" {

            switch $section_name {
                "DAC" {
                    set property [string range $property 5 end]
                }
                "DATC" - "DATI" {
                    set property [string range $property 6 end]
                }
            }
            lappend $section_name [list "$property" $property_value ""]
        }

        set DAC     [ctrl::json::construct_record $DAC]
        set DATC    [ctrl::json::construct_record $DATC]
        set DATI    [ctrl::json::construct_record $DATI]

        set body    [ctrl::json::construct_record   [list \
                                                        [list "tileId" "$tile_id" ""] \
                                                        [list "refName" "$package_key" ""] \
                                                        [list "version" "$version" ""] \
                                                        [list "appCustoms" $DAC "o"] \
                                                        [list "appTileCustoms" $DATC "o"] \
                                                        [list "appTileInternals" $DATI "o"] \
                                                    ]\
                    ]
        set response_code       "Ok"
        set response_message    "Tile Information"
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

ad_proc -public dap::api::tile::get_list {
} {
    Returns the list of tiles for the latest app
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1

    #ctrl::oauth::check_auth_header
    #set user_id     $user_info(user_id)
    #set token_str   $user_info(token_str)
    #
    #if {[empty_string_p $user_id] || $user_id == 0} {
    #    set response_code       "INVALID"
    #    set response_message    "Unauthorized : Undefined user"
    #    set continue_p 0
    #}

    if {$continue_p} {
        set tile_list_json  [list]

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
            }
            set DAC                 [ctrl::json::construct_record $DAC]

            lappend tile_list       [list "appCustoms" $DAC "o"]
            lappend tile_list_json  [list [ctrl::json::construct_record $tile_list]]
        }

        set body    [ctrl::json::construct_record   [list [list "tileList" "$tile_list_json" "a"]]]

        set response_code       "Ok"
        set response_message    "Tile List"
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
