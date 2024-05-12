create schema partman;
create extension pg_partman with schema partman;


SELECT partman.create_parent( p_parent_table => 'data_mart.events_daily',
p_control => 'created_at',
p_interval=> '1 day',
p_start_partition := '2024-04-01 00:00:00'::text,
p_premake => 35);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_monthly',
p_control => 'created_at',
p_interval=> '1 month',
p_start_partition := '2024-01-01 00:00:00'::text,
p_premake => 13);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_quarterly',
p_control => 'created_at',
p_interval=> '3 months',
p_start_partition := '2023-01-01 00:00:00'::text,
p_premake => 5);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_yearly',
p_control => 'created_at',
p_type => 'native',
p_interval=> 'yearly',
p_start_partition := '2023-01-01 00:00:00'::text,
p_premake => 2);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_range',
p_control => 'event_id',
p_type => 'native',
p_interval=> '10000',
p_start_partition := '1',
p_premake => 3);

SELECT i.inhrelid::regclass partition_name, 
       partition_bound,
       split_part(partition_bound, $$'$$, 2) AS lower_bound,
       split_part(partition_bound, $$'$$, 4) AS upper_bound
  FROM pg_tables t, 
       pg_inherits i, 
       pg_class c, 
       pg_get_expr(c.relpartbound, i.inhrelid) AS partition_bound
 WHERE c.oid = i.inhrelid 
   AND c.relname = t.tablename and t.schemaname='data_mart'
   AND i.inhparent = 'data_mart.events_yearly'::regclass
 ORDER BY 1;
