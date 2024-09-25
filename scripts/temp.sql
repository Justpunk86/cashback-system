/*create table cb.exchange(
  field1    varchar2(1),
  field2    varchar2(100),
  field3    number,
  field4    varchar2(100),
  field5    number,
  field6    number,
  field7    varchar2(100),
  field8    varchar2(2000)
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
reject limit unlimited;*/
/*
select t.*, et.*
from transactions t
left join exchange_table et
  on t.original_transaction_id = et.field3
where t.transaction_type = 39
and t.transaction_id not in (select p.transaction_id from purchases p);

select t.*, et.*
from transactions t
left join exchange_table et
  on t.original_transaction_id = et.field3
where t.transaction_type = 40
and t.transaction_id not in (select r.transaction_id from returns r);
*/ 
    
select * from dic_params;    

update dic_params p
set p.param_value = 30
where p.param_name = 'reporting_date';



truncate table exchange_table;
truncate table returns;
truncate table purchases;
truncate table registries;
truncate table transactions;
truncate table validated_files;

/*
begin
  cashback.download_from_file('transactions.csv');
end;
/

begin
 cashback.upload_to_tables;
end;
/

*/

begin
  cashback.get_cashback_file(202407);
end;
/

begin
  cashback.main_proc;
end;
/  

begin
  cashback.get_register;
end;
/

select * from exchange_table;
select * from purchases;
select * from returns;
select * from transactions;
select * from validated_files;
select * from registries;

select * from dic_client_types;
select * from dic_errors;
select * from dic_mcc;
select * from dic_merchant_programs;
select * from dic_params;
select * from dic_transaction_types;
select * from cards;
select * from clients;
select * from individual_persons;
select * from merchants;
select * from merchants_programs;


