<?xml version="1.0"?>

<queryset>
   <fullquery name="get_user_tokens">
      <querytext>
         select jwt_token
         from shib_login_oauth_tokens
         where for_user_id = :user_id
          and package_id   = :authCtrlRestPackageId
          and enable_p     = 't'
      </querytext>
   </fullquery>
</queryset>
