CREATE TABLE "DMS_SAMPLE"."TEST_INDEX_1"(
 "COL_1" NUMBER NOT NULL,
 "COL_2" DATE,
 "COL_3" VARCHAR2(1 BYTE),
 CONSTRAINT "TEST_INDEX_1_PK" PRIMARY KEY ("COL_1")
);

CREATE INDEX "DMS_SAMPLE"."TEST_INDEX_1"
ON "DMS_SAMPLE"."TEST_INDEX_1" (TO_NUMBER(TO_CHAR("COL_2",'YYYYMMDD')), COALESCE("COL_3",'N'));

CREATE TABLE "DMS_SAMPLE"."TEST_INDEX_2"(
 "COL_1" NUMBER,
 "COL_2" DATE,
 "COL_3" VARCHAR2(1 BYTE),
 "COL_4" DATE
);
CREATE INDEX "DMS_SAMPLE"."TEST_INDEX_2"
ON "DMS_SAMPLE"."TEST_INDEX_2" (TO_NUMBER(TO_CHAR(TRUNC("COL_4"),'YYYYMMDD')));
