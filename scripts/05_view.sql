-- Мат.представление или Обычное представление
-- для рассчёта начислений кешбека

--v3
--purchases
create or replace view cashback_data as
select client_opr.*
, c.card_id
, p.purchase_date as opr_date
, p.amount
, p.mcc_id 
, tr.merchant_id
, p.transaction_id
, cashback.calc_cashback(in_amount      => p.amount,
                   in_mcc_id      => p.mcc_id,
                   in_merchant_id => tr.merchant_id,
                   in_opr_cnt     => client_opr.opr_cnt) as cash_back

from
  (select 
   ct.client_id
  , count(p.purchase_id) as opr_cnt
  from purchases p
  join cards cd
    on p.card_id = cd.card_id
  join clients ct
    on cd.client_id = ct.client_id
  group by ct.client_id) client_opr
join cards c
  on client_opr.client_id = c.client_id
join purchases p
  on c.card_id = p.card_id
join transactions tr
  on p.transaction_id = tr.transaction_id 

union 
-- returns  
select client_opr.*
, c.card_id
, r.return_date as opr_date
, r.amount
, p.mcc_id 
, tr.merchant_id
, r.transaction_id
, cashback.calc_cashback(in_amount      => -1 * r.amount,
                   in_mcc_id      => p.mcc_id,
                   in_merchant_id => tr.merchant_id,
                   in_opr_cnt     => client_opr.opr_cnt) as cash_back
from
  (select 
   ct.client_id
  , count(p.purchase_id) as opr_cnt
  from purchases p
  join cards cd
    on p.card_id = cd.card_id
  join clients ct
    on cd.client_id = ct.client_id
  group by ct.client_id) client_opr
join cards c
  on client_opr.client_id = c.client_id
join purchases p
  on c.card_id = p.card_id
join transactions tr
  on p.transaction_id = tr.transaction_id
join returns r
  on p.purchase_id = r.purchase_id;

--v2
create or replace view cashback_data as
select 
  s.transaction_id,
  s.client_id, 
  s.cash_back,
  s.opr_date,
  sum(s.cash_back) over (partition by s.client_id) total_cashback
from  
(select pur.client_id,
  pur.transaction_id,
  pur.opr_date,
  count(pur.opr_id) over (partition by pur.client_id) opr_cnt,
  decode(pur.excluded_true, null,  
    decode(pur.merch_high_rate, 1, pur.amount * (select d.param_value from dic_params d where d.param_name = 'high_rate'),
      decode(pur.mcc_high_rate, 1, pur.amount * (select d.param_value from dic_params d where d.param_name = 'high_rate'),
        pur.amount * (select d.param_value from dic_params d where d.param_name = 'standart_rate'))
        ),
        0
       ) cash_back
  
  from
  (select cl.client_id,
    cr.card_id,
    p.purchase_id opr_id,
    p.amount,
    p.purchase_date opr_date,
    (select d.mcc_code from dic_mcc d where d.mcc_id = p.mcc_id) mcc_code,
    (select d.with_high_rate from dic_mcc d where d.mcc_id = p.mcc_id) mcc_high_rate,
    p.transaction_id,
    tr.merchant_id,
    (select m.with_high_rate from merchants m where m.merchant_id = tr.merchant_id) merch_high_rate,
    (select mmd.excluding_id from mcc_merchant_excluded mmd where mmd.merchant_id = tr.merchant_id and mmd.mcc_id = p.mcc_id) excluded_true

  from clients cl
  join cards cr
    on cl.client_id = cr.client_id
  join purchases p
    on cr.card_id = p.card_id
  join transactions tr
    on p.transaction_id = tr.transaction_id  
  ) pur
  
  union all
  
  select ret.client_id,
  ret.transaction_id,
  ret.opr_date,
  null opr_cnt,
  decode(ret.excluded_true, null,  
    decode(ret.merch_high_rate, 1, ret.amount * (select d.param_value from dic_params d where d.param_name = 'high_rate') * -1,
      decode(ret.mcc_high_rate, 1, ret.amount * (select d.param_value from dic_params d where d.param_name = 'high_rate') * -1,
        ret.amount * (select d.param_value from dic_params d where d.param_name = 'standart_rate') * -1)
        ),
        0
       ) cash_back
  from
  (select cl.client_id,
    cr.card_id,
    r.return_id opr_id,
    r.amount,
    r.return_date opr_date,
    (select d.mcc_code from dic_mcc d where d.mcc_id = p.mcc_id) mcc_code,
    (select d.with_high_rate from dic_mcc d where d.mcc_id = p.mcc_id) mcc_high_rate,
    r.transaction_id,
    tr.merchant_id,
    (select m.with_high_rate from merchants m where m.merchant_id = tr.merchant_id) merch_high_rate,
    null excluded_true

  from clients cl
  join cards cr
    on cl.client_id = cr.client_id
  join returns r
    on cr.card_id = r.card_id
  join purchases p
    on r.purchase_id = p.purchase_id
  join transactions tr
    on p.transaction_id = tr.transaction_id  
  ) ret 
) s;


