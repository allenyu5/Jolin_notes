--Get events
select p.name + N'.' + o.name as EventName, o.description 
from sys.dm_xe_objects o 
	inner join sys.dm_xe_packages p on o.package_guid = p.guid 
where object_type = N'event'

--Get event properties
select name, column_id, type_name, column_type, column_value, description 
from sys.dm_xe_object_columns where object_name = 'latch_suspend_end'

--Get maped value.
select * from sys.dm_xe_map_values
where name = 'keyword_map'

select * from sys.dm_xe_map_values
where name = 'latch_mode'

--Get types.
select * from sys.dm_xe_objects where object_type = 'type'

--Get actions
select p.name + N'.' + o.name as ActionName, o.description , o.type_name
from sys.dm_xe_objects o 
	inner join sys.dm_xe_packages p on o.package_guid = p.guid 
where object_type = N'action'

--Get predicate source.
select p.name + N'.' + o.name as PredicateSourceName, o.description , o.type_name
from sys.dm_xe_objects o 
	inner join sys.dm_xe_packages p on o.package_guid = p.guid 
where object_type = N'pred_source'

select p.name + N'.' + o.name as PredicateSourceName, o.description , o.type_name
from sys.dm_xe_objects o 
	inner join sys.dm_xe_packages p on o.package_guid = p.guid 
where object_type = N'pred_compare' 
