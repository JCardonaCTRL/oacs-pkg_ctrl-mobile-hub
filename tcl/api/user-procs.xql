<?xml version="1.0"?>
<queryset>

<fullquery name="dap::api::user::login.get_user_tokens">
      <querytext>
         select jwt_token
         from shib_login_oauth_tokens
         where for_user_id = :user_id
          and package_id   = :authCtrlRestPackageId
          and enable_p     = 't'
      </querytext>
   </fullquery>

<fullquery name="dap::api::user::get_tiles_list.get_public_group">
    <querytext>
        select g.group_id
        from groups           g
            join acs_objects  obj on g.group_id = obj.object_id
        where obj.object_type = :group_type_name
            and g.group_name  = :public_group
    </querytext>
  </fullquery>

  <fullquery name="dap::api::user::get_tiles_list.get">
    <querytext>
        select
            p.package_id as tile_id,
            p.instance_name as ref_name,
            v.version_name as version,
            v.package_key,
            d.dependency_id,
            d.dependency_type,
            d.service_version,
            (
              select param_values.attr_value
              from apm_parameters         param
                join apm_parameter_values param_values on (param_values.parameter_id = param.parameter_id)
              where param.parameter_name      = '_dac_tilePriority'
                and  param_values.package_id  = p.package_id
            )::int as tile_priority
        from apm_package_versions           v
            join apm_package_dependencies   d       on (d.version_id = v.version_id)
            join apm_package_types          t       on (t.package_key = v.package_key)
            join apm_packages               p       on (p.package_key = t.package_key)
            join dgit_group_tiles           gt      on (gt.tile_id = p.package_id and gt.deleted_p is false)
            join acs_rels                   rels    on (rels.object_id_one = gt.group_id)
        where d.service_uri     = 'dgit-base-tile'
            and d.dependency_type = 'extends'
            and (
                installed_p = 't' or
                enabled_p   = 't' or
                not exists (
                    select 1
                    from apm_package_versions v2
                    where v2.package_key = v.package_key
                    and (
                        v2.installed_p  = 't' or
                        v2.enabled_p    = 't'
                    )
                    and apm_package_version__sortable_version_name(v2.version_name) > apm_package_version__sortable_version_name(v.version_name)
                )
            )
            and rels.object_id_two = :user_id
            and (
                 rels.rel_type = 'auto_membership_rel' or
                 rels.rel_type = 'manual_membership_rel'
            )
        union
        select
            p.package_id as tile_id,
            p.instance_name as ref_name,
            v.version_name as version,
            v.package_key,
            d.dependency_id,
            d.dependency_type,
            d.service_version,
            (
              select param_values.attr_value
              from apm_parameters         param
                join apm_parameter_values param_values on (param_values.parameter_id = param.parameter_id)
              where param.parameter_name      = '_dac_tilePriority'
                and  param_values.package_id  = p.package_id
            )::int as tile_priority
        from apm_package_versions           v
            join apm_package_dependencies   d       on (d.version_id = v.version_id)
            join apm_package_types          t       on (t.package_key = v.package_key)
            join apm_packages               p       on (p.package_key = t.package_key)
            join dgit_group_tiles           gt      on (gt.tile_id = p.package_id and gt.deleted_p is false)
        where d.service_uri       = 'dgit-base-tile'
            and d.dependency_type = 'extends'
            and (
                installed_p = 't' or
                enabled_p   = 't' or
                not exists (
                    select 1
                    from apm_package_versions v2
                    where v2.package_key = v.package_key
                    and (
                        v2.installed_p  = 't' or
                        v2.enabled_p    = 't'
                    )
                    and apm_package_version__sortable_version_name(v2.version_name) > apm_package_version__sortable_version_name(v.version_name)
                )
            )
            and gt.group_id = :public_group_id
        order by tile_priority
    </querytext>
  </fullquery>

  <fullquery name="dap::api::user::get_tiles_list.get_dacs">
    <querytext>
        select  param.default_value,
                param.parameter_name as property,
                param_values.attr_value as property_value,
                param.section_name
        from apm_parameter_values   param_values
            join apm_parameters     param on param.parameter_id = param_values.parameter_id
        where param.package_key         = :package_key
            and param_values.package_id = :tile_id
            and param.parameter_name like '_dac_%'
            and param.parameter_name    != '_dac_deployableP'
        order by section_name, property
    </querytext>
  </fullquery>

  <fullquery name="dap::api::user::get_tiles_list.get_group_codes">
    <querytext>
      select dapg.group_code
      from acs_rels       ar
      join acs_objects    ao    on ar.object_id_one = ao.object_id
      join dgsom_app_ext  dapg  on dapg.group_id = ao.object_id
      where ar.object_id_two   = :user_id and
            ao.object_type     = :group_type_name
      union
      select dapg.group_code
      from dgsom_app_ext  dapg
      where dapg.group_id = :public_group_id
    </querytext>
  </fullquery>

</queryset>
