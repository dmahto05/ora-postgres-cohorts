select atc.owner,
       atc.table_name,
       atc.column_name,
       atc.data_type
  from all_tab_columns atc
 where data_type in ( 'VARCHAR2',
                      'CHAR',
                      'NUMBER' )
   and owner = 'DMS_SAMPLE'
   and num_distinct <= 2
   and upper(
	to_char(
		utl_raw.cast_to_varchar2(
			atc.low_value
		)
	)
) in ( 'Y',
       'N',
       'TRUE',
       'FALSE',
       'YES',
       'NO',
       '1',
       '0',
       'ON',
       'OFF' )
   and upper(
	to_char(
		utl_raw.cast_to_varchar2(
			atc.high_value
		)
	)
) in ( 'Y',
       'N',
       'TRUE',
       'FALSE',
       'YES',
       'NO',
       '1',
       '0',
       'ON',
       'OFF' );
