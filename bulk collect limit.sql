CREATE TABLE jobs_ AS
SELECT * FROM jobs WHERE 1=2;

declare
   vcRecs SYS_REFCURSOR;
   TYPE T_RECS IS TABLE OF jobs_%ROWTYPE;
   vtRecs T_RECS;
begin
   open vcRecs for
      select * from jobs;
   loop
      fetch vcRecs bulk collect into vtRecs LIMIT 100;
      EXIT WHEN vtRecs.count = 0;
      
      FORALL i IN 1..vtRecs.count
         INSERT INTO jobs_ VALUES vtRecs(i);
   END LOOP;
END;
/