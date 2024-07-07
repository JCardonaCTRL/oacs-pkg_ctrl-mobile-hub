ad_library {
    Set of TCL procedures to handle dgit_tracking_events table

    @author: jcardona@mednet.ucla.edu
    @creation-date: 2021-06-01
}

namespace eval dgit::tracking_events {}

ad_proc -public dgit::tracking_events::new {
    {-creation_user:required}
    {-tracking_id   ""}
    {-tile_code     ""}
    {-tile_module   ""}
    {-action        ""}
    {-context       ""}
    {-active_p      "TRUE"}
} {
    Create a new tracking event record and @return a tracking_id
} {
    if {$tracking_id ne ""} {
        set tracking_id [db_nextval "dgit_dgsom_app_id_seq"]
    }

    db_transaction {
        db_dml insert ""
    } on_error {
        db_abort_transaction
        error "Tracking Event: An error occured while inserting a record into tracking events table: $errmsg"
    }
    return $tracking_id
}

ad_proc -public dgit::tracking_events::edit {
    {-tracking_id:required}
    {-modifying_user:required}
    {-tile_code}
    {-tile_module}
    {-action}
    {-context}
    {-active_p}
} {
    Edit a new tracking event record and @return a boolean type for success_p
} {
    set success_p       0
    set sql_update      [list]
    set varchar_list    [list tile_code tile_module action context active_p]
    foreach {column_var} $varchar_list {
        if {[info exists $column_var]} {
            lappend sql_update "$column_var = :$column_var"
        }
    }

    set sql_update [join $sql_update ,]

    if {$sql_update ne ""} {
        db_transaction {
            db_dml update ""
            set success_p 1
        }  on_error {
            db_abort_transaction
            error "Tracking Event: An error occured while updating a record of tracking events table: $errmsg"
        }
    }
    return $success_p
}

ad_proc -private dgit::tracking_events::get {
    {-tracking_id:required}
    {-column_array "tracking_info"}
    {-all:boolean}
} {
    Get the record information from tracking events table and return an array with the elements
} {
    upvar $column_array row

    set sql_and_where   "AND tracking.active_p IS TRUE"
    if {$all_p} {
        set sql_and_where ""
    }
    return [db_0or1row select "" -column_array row]
}

ad_proc -public dgit::tracking_events::mark_as_delete {
    {-tracking_id:required}
    {-modifying_user:required}
} {
    Sets as active_p false for the record in tracking events table and @return a boolean type for success_p
} {
    set success_p   [dgit::tracking_events::edit \
                        -tracking_id $tracking_id \
                        -modifying_user $modifying_user \
                        -active_p FALSE]

    return $success_p
}

ad_proc -public dgit::tracking_events::remove {
    {-tracking_id:required}
} {
    Delete a record from tracking events table and @return a boolean type for success_p
} {
    set success_p 0
    db_transaction {
        db_dml delete ""
        set success_p 1
    }  on_error {
        db_abort_transaction
        error "Tracking Event: An error occured while deleting a record from tracking events table: $errmsg"
    }
    return $success_p
}
