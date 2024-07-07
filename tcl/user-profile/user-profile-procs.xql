<?xml version="1.0"?>
<queryset>

  <fullquery name="dap::user::profile::get.select">
    <querytext>
      select
        email,
        department,
        office_location,
        mobile_phone
      from dgit_user_profile
      where user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="dap::user::profile::new.insert">
    <querytext>
      insert into dgit_user_profile
        (user_id, email, department, office_location, mobile_phone, creation_user, creation_date)
      values
        (:user_id, :email, :department, :office_location, :mobile_phone, :creation_user, now())
    </querytext>
  </fullquery>

  <fullquery name="dap::user::profile::edit.update">
    <querytext>
      update dgit_user_profile
        set $sql_update,
          last_modified = now(),
          modifying_user = :modifying_user
      where user_id = :user_id
    </querytext>
  </fullquery>

</queryset>
