ad_library {

    Set of TCL procedures to handle base tile callbacks

    @author JC
    @cvs-id $Id$
    @creation-date 2020-09-14

}

namespace eval dap::apm {}

ad_proc -private dap::apm::after_install {} {} {
    # db_transaction {
    # } on_error {
    #     ns_log error "dap::apm::after_install - $errmsg"
    # }
}

ad_proc dap::apm::upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Logic to help upgrade oats-department package, this is usefull when need to run
    tcl scripts to perform upgrade, make DB inserts/updates, etc.
} {
    # apm_upgrade_logic \
	# -from_version_name $from_version_name \
	# -to_version_name $to_version_name \
	# -spec {
    # }
}
