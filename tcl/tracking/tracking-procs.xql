<?xml version="1.0"?>
<queryset>


    <fullquery name="dgit::tracking_events::new.insert">
        <querytext>
            insert into dgit_tracking_events (
                tracking_id, tile_code, tile_module, action, context, creation_user
            ) values (
                :tracking_id, :tile_code, :tile_module, :action, :context, :creation_user
            )
        </querytext>
    </fullquery>

    <fullquery name="dgit::tracking_events::edit.update">
        <querytext>
            UPDATE dgit_tracking_events
                SET $sql_update
            WHERE tracking_id = :tracking_id
        </querytext>
    </fullquery>

    <fullquery name="dgit::tracking_events::get.select">
        <querytext>
            SELECT
                tracking.*,
                to_char(tracking.creation_date, 'YYYY-MM-DD HH12:MI:SS AM') as creation_date_pretty,
                to_char(tracking.last_modified, 'YYYY-MM-DD HH12:MI:SS AM') as last_modified_pretty,
                p.first_names || ' ' || p.last_name as creation_name
            FROM dgit_tracking_events tracking
                JOIN persons p
                    ON (p.person_id = tracking.creation_user)
            WHERE tracking.tracking_id = :tracking_id
                $sql_and_where
        </querytext>
    </fullquery>

    <fullquery name="dgit::tracking_events::delete.delete">
        <querytext>
            DELETE FROM dgit_tracking_events
            WHERE tracking_id = :tracking_id
        </querytext>
    </fullquery>

</queryset>
