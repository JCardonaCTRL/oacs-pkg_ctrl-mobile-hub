ad_page_contract {


    Display the users profile for DGSOM App

} {
   {token_id:integer ""}
}

set user_id  [ad_conn user_id]

if {$user_id < 1} {
   switch [parameter::get -parameter "loginMethod"] {
      "local" {
         ad_returnredirect "[ad_conn package_url]login/alt-login"
      }
   }
   ad_script_abort
}
# Using wrapper for the extra profile info
dap::user::profile::get -user_id $user_id -column_array "user_info"
# Get restful package id
set package_id             [ad_conn package_id]
set authCtrlRestPackageId  [parameter::get -package_id $package_id -parameter "authCtrlRestPackageId"]
# Get the jwt setup info
ctrl::restful::jwt::get_setup -package_id $authCtrlRestPackageId -column_array "setup_info"
set field_list [list jwt_type client_key public_key]

foreach field $field_list {
   set $field $setup_info($field)
}
# Get all the tokens for the user
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
   set exp_pos [lsearch $claims_list "exp"]
   set exp     [lindex $claims_list [expr {$exp_pos + 1}]]
   set current_time [clock seconds]
   # 30 days in seconds. The time the token needs to be valid to be used in this page.
   set min_diff [expr {30*24*60*60}]
   if {[expr {$current_time + $min_diff}] > $exp} {
      continue
   } else {
      set jwt_token $token
      break
   }
}
# If there is no valid token for the user, create a new one
if {$jwt_token eq ""} {
   set jwt_token  [ctrl::restful::jwt::generate_token \
                     -package_id       $authCtrlRestPackageId \
                     -user_id          $user_id \
                     -field            "email" \
                     -field_type_label "email"]
}
# Return user information
set json [ctrl::json::construct_record \
            [list \
               [list name              "$user_info(last_name), $user_info(first_names)" s] \
               [list firstName         $user_info(first_names) s] \
               [list lastName          $user_info(last_name) s] \
               [list email             $user_info(email)] \
               [list uclaID            $user_info(screen_name)] \
               [list department        $user_info(department)] \
               [list officeLocation    $user_info(office_location)] \
               [list mobilePhone       $user_info(mobile_phone)] \
               [list jwtToken          $jwt_token] \
            ] \
         ]

doc_return 200 text/json "{$json}"
