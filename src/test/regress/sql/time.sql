--
-- TIME
--

CREATE TABLE TIME_TBL (f1 time(2));

INSERT INTO TIME_TBL VALUES ('00:00');
INSERT INTO TIME_TBL VALUES ('01:00');
-- as of 7.4, timezone spec should be accepted and ignored
INSERT INTO TIME_TBL VALUES ('02:03 PST');
INSERT INTO TIME_TBL VALUES ('11:59 EDT');
INSERT INTO TIME_TBL VALUES ('12:00');
INSERT INTO TIME_TBL VALUES ('12:01');
INSERT INTO TIME_TBL VALUES ('23:59');
INSERT INTO TIME_TBL VALUES ('11:59:59.99 PM');

INSERT INTO TIME_TBL VALUES ('2003-03-07 15:36:39 America/New_York');
INSERT INTO TIME_TBL VALUES ('2003-07-07 15:36:39 America/New_York');
-- this should fail (the timezone offset is not known)
INSERT INTO TIME_TBL VALUES ('15:36:39 America/New_York');


SELECT f1 AS "Time" FROM TIME_TBL ORDER BY f1;

SELECT f1 AS "Three" FROM TIME_TBL WHERE f1 < '05:06:07' ORDER BY f1;

SELECT f1 AS "Five" FROM TIME_TBL WHERE f1 > '05:06:07' ORDER BY f1;

SELECT f1 AS "None" FROM TIME_TBL WHERE f1 < '00:00' ORDER BY f1;

SELECT f1 AS "Eight" FROM TIME_TBL WHERE f1 >= '00:00' ORDER BY f1;

--
-- TIME simple math
--
-- We now make a distinction between time and intervals,
-- and adding two times together makes no sense at all.
-- Leave in one query to show that it is rejected,
-- and do the rest of the testing in horology.sql
-- where we do mixed-type arithmetic. - thomas 2000-12-02

SELECT f1 + time '00:01' AS "Illegal" FROM TIME_TBL ORDER BY f1;


--test now(), expect now() in transaction block keep a const value crossing node.
create table tbl_now_cross_node(i int, t timestamp) distribute by shard(i);

--we are sure that distribute key i with value 1 and 3 would be scattered on different nodes.
--expect select get nothing
begin;
insert into tbl_now_cross_node values(1, now());
insert into tbl_now_cross_node values(3, now());

select * from tbl_now_cross_node t1, tbl_now_cross_node t2 where t1.t <> t2.t;

insert into tbl_now_cross_node values(1, now());
insert into tbl_now_cross_node values(3, now());
select * from tbl_now_cross_node t1, tbl_now_cross_node t2 where t1.t <> t2.t;
--make sure there are record in the table.
select i from tbl_now_cross_node order by i;
abort;
drop table tbl_now_cross_node;















