-- Мат.представление или Обычное представление
-- для рассчёта начислений кешбека

select *
from purchases p
left join returns r
  on p.purchase_id = r.purchase_id
where p.purchase_data >= to_date()  


select * from exchange_table;
select * from validated_files;

select * from dic_errors;
select * from dic_mcc;
select * from dic_params;
select * from dic_transaction_types;
select * from dic_user_types;
