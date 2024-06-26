set pages 50000
set lines 200
set serveroutput on
set verify off
set feedback off
DECLARE
    v_TableCol VARCHAR2(100) := '';
    v_Size NUMBER := 0;
    v_TotalSize NUMBER := 0;
BEGIN
    FOR v_Rec IN (
                  SELECT OWNER || '.' || TABLE_NAME || '.' || COLUMN_NAME AS TableAndColumn,
                      'SELECT MAX(DBMS_LOB.GetLength("' || COLUMN_NAME || '")/1024) AS SizeKB FROM ' || OWNER || '.' || TABLE_NAME AS sqlstmt
                  FROM ALL_TAB_COLUMNS
                  WHERE DATA_TYPE LIKE '%LOB'
                        AND OWNER LIKE 'DMS_SAMPLE')
    LOOP
        BEGIN
          EXECUTE IMMEDIATE v_Rec.sqlstmt INTO v_Size;
          DBMS_OUTPUT.PUT_LINE (v_Rec.TableAndColumn || ': size in KB is :' || ROUND(NVL(v_Size,0),2));
          v_TotalSize := v_TotalSize + NVL(v_Size,0);
        EXCEPTION WHEN no_data_found THEN NULL;
        END;
    END LOOP;
   
END;
/
