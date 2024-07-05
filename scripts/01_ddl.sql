
-- create directory for download files
create or replace directory files as 'C:\cashback\';

-- create extarnal table for file exchange
drop table cb.exchange;

create table cb.exchange(
  row_type         varchar2(1),
  card_crypto      varchar2(100),
  trans_merc_id    number,
  trans_date       varchar2(100),
  sum_prise        number,
  merchant_id      number,
  mcc_code         varchar2(100),
  describe         varchar2(2000)  
)
organization external(
  type oracle_loader
  default directory files
  
  access parameters 
  (
    records delimited by newline
    fields terminated by ';'
    
  )
  location ('transactions.csv')
)
reject limit unlimited;

select * from cb.exchange;

-- create temp table for file exchange
/*create global temporary table cb.table_exchange 

on commit;*/



