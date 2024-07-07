<?xml version="1.0"?>
<queryset>

  <fullquery name="dap::api::tile::info.get_tile_id_from_app_code">
    <querytext>
      select param_values.package_id as tile_id
      from apm_parameters         param
        join apm_parameter_values param_values on param_values.parameter_id = param.parameter_id
      where param.parameter_name    = '_dac_appCode'
        and param_values.attr_value = :app_code
    </querytext>
  </fullquery>

  <fullquery name="dap::api::tile::info.get">
    <querytext>
        select  param.default_value,
                param.parameter_name as property,
                param_values.attr_value as property_value,
                param.section_name
        from apm_parameter_values   param_values
            join apm_parameters     param on param.parameter_id = param_values.parameter_id
        where param.package_key         = :package_key
            and param_values.package_id = :tile_id
            and (
                param.parameter_name like '_dac_%' or
                param.parameter_name like '_datc_%' or
                param.parameter_name like '_dati_%'
            )
        order by section_name, property
    </querytext>
  </fullquery>

  <fullquery name="dap::api::tile::get_list.get">
    <querytext>
        select
            p.package_id as tile_id,
            p.instance_name as ref_name,
            v.version_name as version,
            v.package_key,
            d.dependency_id,
            d.dependency_type,
            d.service_version
        from apm_package_versions           v
            join apm_package_dependencies   d on (d.version_id = v.version_id)
            join apm_package_types          t on (t.package_key = v.package_key)
            join apm_packages               p on (p.package_key = t.package_key)
        where d.service_uri     = 'dgit-base-tile'
            and d.dependency_type = 'extends'
            and (
                installed_p = 't' or
                enabled_p = 't' or
                not exists (
                    select 1
                    from apm_package_versions v2
                    where v2.package_key = v.package_key
                    and (
                        v2.installed_p = 't' or
                        v2.enabled_p = 't'
                    )
                    and apm_package_version__sortable_version_name(v2.version_name) > apm_package_version__sortable_version_name(v.version_name)
                )
            )
    </querytext>
  </fullquery>

  <fullquery name="dap::api::tile::get_list.get_dacs">
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

</queryset>
