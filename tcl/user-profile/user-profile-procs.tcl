ad_library {

    Set of TCL procedures to handle user profile data

    @author JC
    @cvs-id $Id$
    @creation-date 2021-07-22

}

namespace eval dap::user::profile {}

ad_proc -public dap::user::profile::get {
    -user_id:required
    {-column_array "user_info"}
} {
    Returns the main information of a user with the extra values from the profile

    @see acs_user::get

} {
    upvar $column_array row

    acs_user::get -user_id $user_id -array row

    set profile_p [db_0or1row select "" -column_array profile]

    set row(profile_p) $profile_p
    if {$profile_p} {
        set row(department)         $profile(department)
        set row(office_location)    $profile(office_location)
        set row(mobile_phone)       $profile(mobile_phone)

        if {$profile(email) ne ""} {
            set row(email) $profile(email)
        }
    } else {
        set row(department)         ""
        set row(office_location)    ""
        set row(mobile_phone)       ""
    }
}

ad_proc -public dap::user::profile::create_or_update {
    -user_id:required
    -creation_user:required
    -first_name
    -last_name
    -email
    -department
    -office_location
    -mobile_phone
} {
    Creates or updates the information for the user profile

    @see dap::user::profile::get
} {

    set success_p 0
    dap::user::profile::get -user_id $user_id -column_array "profile_info"

    set init_list   [list first_name last_name email department office_location mobile_phone]
    set params_list [list]
    foreach var $init_list {
        if [info exists $var] {
            lappend params_list "-$var \"[set $var]\""
        }
    }
    set params_list [join $params_list " "]

    if {!$profile_info(profile_p)} {
        set success_p   [dap::user::profile::new \
                            -user_id $user_id \
                            -creation_user $creation_user \
                            {*}$params_list]
    } else {
        set success_p   [dap::user::profile::edit \
                            -user_id $user_id \
                            -modifying_user $creation_user \
                            {*}$params_list]
    }
    return $success_p
}

ad_proc -private dap::user::profile::new {
    -user_id:required
    -creation_user:required
    {-first_name    ""}
    {-last_name     ""}
    {-email         ""}
    {-department    ""}
    {-office_location ""}
    {-mobile_phone  ""}
} {
    Creates the information for the user profile

    @see dap::user::profile::get
} {
    set success_p 0
    db_transaction {

        if {$first_name != "" || $last_name != ""} {
            acs_user::get -user_id $user_id -array row;# This is needed because the person::update proc requires both params

            if {$first_name != "" && $last_name != ""} {
                person::update -person_id $user_id -first_names $first_name -last_name $last_name
            } elseif {$first_name != ""} {
                person::update -person_id $user_id -first_names $first_name -last_name $row(last_name)
            } elseif {$last_name != ""} {
                person::update -person_id $user_id -first_names $row(first_names) -last_name $last_name
            }
        }

        db_dml insert ""
        set success_p 1
    } on_error {
        ns_log error "dap::user::profile::new - $errmsg"
        set success_p 0
        db_abort_transaction
    }
    if {$success_p} {
        set screen_name [acs_user::get_element -user_id $user_id -element screen_name]
    }
    return $success_p
}

ad_proc -private dap::user::profile::edit {
    -user_id:required
    -modifying_user:required
    -first_name
    -last_name
    -email
    -department
    -office_location
    -mobile_phone
} {
    Updates the information for the user profile

    @see dap::user::profile::get
} {
    set success_p 0
    set edit_p 0
    set init_list [list email department office_location mobile_phone]
    set sql_update [list]
    foreach var $init_list {
        if [info exists $var] {
            lappend sql_update "$var = :$var"
        }
    }
    set sql_update [join $sql_update ,]

    db_transaction {
        if {([info exists first_name] && $first_name != "") || ([info exists last_name] && $last_name != "")} {
            acs_user::get -user_id $user_id -array row;# This is needed because the person::update proc requires both params

            if {([info exists first_name] && $first_name != "") && ([info exists last_name] && $last_name != "")} {
                person::update -person_id $user_id -first_names $first_name -last_name $last_name
            } elseif {[info exists first_name] && $first_name != ""} {
                person::update -person_id $user_id -first_names $first_name -last_name $row(last_name)
            } elseif {[info exists last_name] && $last_name != ""} {
                person::update -person_id $user_id -first_names $row(first_names) -last_name $last_name
            }
        }

        if {$sql_update eq ""} {
            set success_p 1
        } else {
            db_dml update ""
            set success_p 1
            set edit_p 1
        }
    } on_error {
        ns_log error "dap::user::profile::edit - $errmsg"
        set edit_p 0
        db_abort_transaction
    }
    return $success_p
}
