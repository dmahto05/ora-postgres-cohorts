with 
b as ( -- begin snapshot
  select clock_timestamp() as "snap_time", * 
  from pg_stat_statements, pg_sleep(15) -- 15 second snapshots
),
e as ( -- end snapshot
  select clock_timestamp() as "snap_time", * 
  from pg_stat_statements, pg_sleep(0)
),
u as ( -- union all as timeseries
  select * from e union all select * from b
),
d as ( -- delta values from cumulative metrics
  select
    snap_time,
    extract(epoch from snap_time - lag(snap_time) over(query_cumulative_stats)) as seconds,
    (total_plan_time + total_exec_time) - lag(total_plan_time + total_exec_time) over(query_cumulative_stats) as total_time,
    calls - lag(calls) over(query_cumulative_stats) as calls,
    plans - lag(plans) over(query_cumulative_stats) as plans,
    rows - lag(rows) over(query_cumulative_stats) as rows,
    shared_blks_hit - lag(shared_blks_hit) over(query_cumulative_stats) as shared_blks_hit,
    shared_blks_read - lag(shared_blks_read) over(query_cumulative_stats) as shared_blks_read,
    shared_blks_dirtied - lag(shared_blks_dirtied) over(query_cumulative_stats) as shared_blks_dirtied,
    shared_blks_written - lag(shared_blks_written) over(query_cumulative_stats) as shared_blks_written,
    query
  from u 
  window query_cumulative_stats as (
    partition by userid, dbid, queryid, query order by snap_time
  )
) 
select -- final output
  round((calls / seconds)::numeric, 2) as "call/sec",
  round(((total_time / 1000) / seconds)::numeric, 1) as "AAS",
  date_trunc('second', (total_time / 1000) * interval '1 second') as total_time,
  calls as "total calls",
  plans as "total plans",
  rows as "total rows",
  shared_blks_hit as "shared blocks hit",
  shared_blks_read as "shared blocks read",
  shared_blks_dirtied as "shared blocks dirtied",
  shared_blks_written as "shared blocks written",
  substring(query, 1, 50) AS short_query 
from d 
where calls > 0 and total_time > 0
order by "AAS" desc 
fetch first 5 rows only;
