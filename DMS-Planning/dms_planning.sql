WITH INPUT AS 
                        (SELECT UPPER('DMS_SAMPLE') AS SCHEMANAME FROM DUAL) , 
                        ALIAS1 AS 
                        (SELECT /*+ MATERIALIZE */
                            alias1.owner,
                            alias1.table_name,
                            COALESCE((SELECT 'Y' FROM dba_lobs where dba_lobs.owner = upper(alias1.owner) and  dba_lobs.table_name =    alias1.table_name    and rownum=1),'N')        "LOB?",
                            COALESCE((SELECT 'Y' FROM all_constraints cons, all_cons_columns cols WHERE cons.owner  = alias1.owner and cols.table_name = alias1.table_name AND cons.constraint_type = 'P' AND cons.constraint_name = cols.constraint_name AND cons.owner = cols.owner and rownum =1),'N') as "PK",
                            (SELECT cc.column_name FROM all_constraints tc JOIN all_cons_columns cc ON tc.constraint_name = cc.constraint_name AND tc.owner = cc.owner and  tc.table_name = alias1.table_name JOIN all_tab_columns atc ON cc.table_name = atc.table_name AND cc.column_name = atc.column_name AND cc.owner = atc.owner WHERE tc.constraint_type = 'P' AND tc.owner = alias1.owner AND cc.position = 1 AND atc.data_type IN ('NUMBER', 'FLOAT', 'INTEGER', 'DECIMAL')) "LEADING_PK_NUMBER",
                            round(SUM("Total Size Gigs"),4) "SIZEGIGS",
                            SUM(lobsize)              AS "LOBSIZE",
                            SUM(nonlobsize)           AS "NONLOBSIZE",
                            (
                                SELECT
                                    num_rows
                                FROM
                                    dba_tables
                                WHERE
                                        dba_tables.owner = alias1.owner
                                    AND dba_tables.table_name = alias1.table_name
                            )                         AS num_rows_approx,
                            (
                                SELECT
                                    avg_row_len
                                FROM
                                    dba_tables
                                WHERE
                                        dba_tables.owner = alias1.owner
                                    AND dba_tables.table_name = alias1.table_name
                            )                         AS avg_row_len,
                            round((SUM("Total Size Gigs") * 1024 * 1024) /(
                                SELECT
                                    CASE
                                        WHEN num_rows = 0 THEN
                                            1
                                        ELSE
                                            num_rows
                                    END
                                FROM
                                    dba_tables
                                WHERE
                                        dba_tables.owner = alias1.owner
                                    AND dba_tables.table_name = alias1.table_name
                            ),
                                2)                  AS avg_rows_size_approx_kb,
                            nvl((
                                SELECT
                                    partitioned
                                FROM
                                    dba_tables
                                WHERE
                                        dba_tables.owner = alias1.owner
                                    AND dba_tables.table_name = alias1.table_name
                            ), 'NO')                  AS "PARTITION?",
                            (
                                SELECT
                                    COUNT(1)
                                FROM
                                    dba_tab_columns
                                WHERE
                                        dba_tab_columns.owner = alias1.owner
                                    AND dba_tab_columns.table_name = alias1.table_name
                                    AND data_type IN ( 'CLOB', 'NCLOB', 'BLOB' )
                                    AND nullable = 'N'
                            )                         not_null_lob_constraint
                        FROM
                            (
                                SELECT
                                    owner,
                                    (
                                        CASE
                                            WHEN table_name IS NULL THEN
                                                tab_name
                                            ELSE
                                                table_name
                                        END
                                    )    table_name,
                                    round(SUM("Total Size Gigs"),2) AS "Total Size Gigs",
                                    round((
                                        SELECT
                                            SUM(
                                                CASE
                                                    WHEN segment_type IN('LOBSEGMENT', 'LOB PARTITION', 'LOBINDEX') THEN
                                                        bytes
                                                END
                                            ) / 1024 / 1024 / 1024
                                        FROM
                                            dba_segments ds
                                        WHERE
                                                ds.segment_name = tab_name
                                            AND ds.owner = owner
                                    ),
                                        4)               AS lobsize,
                                    round((
                                        SELECT
                                            SUM(
                                                CASE
                                                    WHEN segment_type NOT IN('LOBSEGMENT', 'LOB PARTITION', 'LOBINDEX') THEN
                                                        bytes
                                                END
                                            ) / 1024 / 1024 / 1024
                                        FROM
                                            dba_segments ds
                                        WHERE
                                                ds.segment_name = tab_name
                                            AND ds.owner = owner
                                    ),
                                        4)               AS nonlobsize
                                FROM
                                    (
                                        SELECT
                                            size_list.owner,
                                            size_list.tab_name,
                                            size_list.segment_type,
                                            lob_list.table_name,
                                            SUM(size_list."Total Size Gigs") / 1024 / 1024 / 1024 "Total Size Gigs"
                                        FROM
                                            (
                                                SELECT
                                                    owner,
                                                    segment_name,
                                                    table_name
                                                FROM
                                                    dba_lobs
                                                WHERE
                                                    owner = (SELECT SCHEMANAME FROM INPUT)
                                            ) lob_list
                                            RIGHT OUTER JOIN (
                                                SELECT
                                                    owner,
                                                    segment_name,
                                                    segment_name AS tab_name,
                                                    'N'          AS contain_lob,
                                                    segment_type,
                                                    SUM(bytes)   "Total Size Gigs"
                                                FROM
                                                    dba_segments
                                                WHERE
                                                        owner = (SELECT SCHEMANAME FROM INPUT)
                                                    AND segment_type IN ( 'TABLE SUBPARTITION', 'TABLE PARTITION', 'NESTED TABLE', 'LOB PARTITION', 'LOBSEGMENT','TABLE' )
                                                    and segment_name not like 'BIN$%'
                                                GROUP BY
                                                    owner,
                                                    segment_name,
                                                    segment_type
                                            ) size_list ON lob_list.segment_name = size_list.segment_name
                                                        AND lob_list.owner = size_list.owner
                                        GROUP BY
                                            size_list.owner,
                                            size_list.segment_type,
                                            size_list.tab_name,
                                            lob_list.table_name
                                    )
                                GROUP BY
                                    owner,tab_name,
                                    (
                                        CASE
                                            WHEN table_name IS NULL THEN
                                                tab_name
                                            ELSE
                                                table_name
                                        END
                                    )
                            ) alias1
                        GROUP BY
                            alias1.owner,
                            alias1.table_name
                        ORDER BY
                            4 DESC),
                        ALIAS2 AS 
                        (SELECT owner , table_name , "LOB?" ,  "PK", "LEADING_PK_NUMBER",  "SIZEGIGS", "LOBSIZE","NONLOBSIZE",num_rows_approx , avg_row_len , avg_rows_size_approx_kb , "PARTITION?"  , not_null_lob_constraint,
                        trunc(("SIZEGIGS"/SUM("SIZEGIGS") OVER ())*100) as "TOP%" , trunc(("LOBSIZE"/SUM("LOBSIZE") OVER ())*100) "LOB%" , trunc(("NONLOBSIZE"/SUM("NONLOBSIZE") OVER ())*100)  "NONLOB%" , 
                        ROW_NUMBER() OVER (ORDER BY "SIZEGIGS" DESC NULLS LAST) "RN_TOTALSIZE" , 
                        ROW_NUMBER() OVER (ORDER BY "LOBSIZE" DESC NULLS LAST) "RN_LOBSIZE",
                        ROW_NUMBER() OVER (ORDER BY "NONLOBSIZE" DESC NULLS LAST) "RN_NONLOBSIZE"
                        FROM ALIAS1)
                        SELECT *
                        FROM ALIAS2;
