CREATE TABLE DMS_SAMPLE.PRODUCT_TBL
   (ID NUMBER(8,0), 
    PRDNM VARCHAR2(25 BYTE), 
    STOCK CLOB, 
    Details CLOB );

alter table "DMS_SAMPLE"."PRODUCT_TBL" add(PK_ID NUMBER generated always as identity);
alter table "DMS_SAMPLE"."PRODUCT_TBL" add constraint pk_product1 primary key(PK_ID);


DECLARE
type t_prd_names is varray(3) of varchar2(20) not null;
t_prd t_prd_names  := t_prd_names('Mobile','Tablet','Laptop');

TYPE del_sch IS TABLE OF VARCHAR2(64) INDEX BY VARCHAR2(10);
v_del_sch del_sch;

DET_CLOB CLOB;
DET_TXT CLOB ;
v_amount number(8);
v_offset number(2);

begin
v_del_sch('Laptop') := 'Ready for Delivery in 3 days';
v_del_sch('Tablet') := 'Ready for Delivery in 7 days';
v_del_sch('Mobile') := 'Ready for Delivery in 5 days';
v_amount := 6;
v_offset := 1;

  for i in 1..1000
  loop
  DBMS_LOB.CREATETEMPORARY(DET_CLOB, TRUE);
  DBMS_LOB.OPEN(DET_CLOB, DBMS_LOB.LOB_READWRITE);

  if t_prd(MOD(i,3)+1) = 'Mobile'
  then
  DBMS_LOB.WRITE(DET_CLOB,v_amount, v_offset,t_prd(MOD(i,3)+1));
  DET_TXT := ' is a portable telephone that can make and receive calls over a radio frequency link while the user 
  is moving within a telephone service area, as opposed to a fixed-location phone (landline phone).' || RPAD('tech', i*30, '0') ;
  DBMS_LOB.WRITEAPPEND(DET_CLOB, LENGTH(DET_TXT), DET_TXT);
  insert into DMS_SAMPLE.PRODUCT_TBL values (i,t_prd(MOD(i,3)+1),v_del_sch(t_prd(MOD(i,3)+1)),DET_CLOB);
  end if;

    if t_prd(MOD(i,3)+1) = 'Tablet'
  then
  DBMS_LOB.WRITE(DET_CLOB,v_amount, v_offset,t_prd(MOD(i,3)+1));
  DET_TXT := ' is a mobile device, typically with a mobile operating system and touchscreen display processing circuitry, and a rechargeable battery in a single, thin and flat package.' || RPAD('tech', i*30, '0') ;
  DBMS_LOB.WRITEAPPEND(DET_CLOB, LENGTH(DET_TXT), DET_TXT);
  insert into DMS_SAMPLE.PRODUCT_TBL values (i,t_prd(MOD(i,3)+1),v_del_sch(t_prd(MOD(i,3)+1)),DET_CLOB);
  end if;

  if t_prd(MOD(i,3)+1) = 'Laptop'
  then
  DBMS_LOB.WRITE(DET_CLOB,v_amount, v_offset,t_prd(MOD(i,3)+1));
  DET_TXT := '  is known either as a laptop or notebook for short, is a small, portable personal computer(PC).' || RPAD('tech', i*30, '0') ;
  DBMS_LOB.WRITEAPPEND(DET_CLOB, LENGTH(DET_TXT), DET_TXT);
  insert into DMS_SAMPLE.PRODUCT_TBL values (i,t_prd(MOD(i,3)+1),v_del_sch(t_prd(MOD(i,3)+1)),DET_CLOB);
  end if;
  end loop; 
  end;
  /

  commit;
