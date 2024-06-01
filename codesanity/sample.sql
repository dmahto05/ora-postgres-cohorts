CREATE OR REPLACE FUNCTION public.func_mock(integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE var1 INTEGER;
BEGIN
IF $1 > 0
THEN
PERFORM I_dont_Exists();
RAISE NOTICE '%', $1;
ELSIF $1 < 0 THEN
SELECT columns_does_not_exists INTO var1 FROM table_that_does_not_exists LIMIT 1;
RAISE NOTICE '%' , var1;
ELSE
RAISE NOTICE 'Please Note - Error Here %',1/0;
END IF;
END;
$function$
