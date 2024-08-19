/*select 
  decode(et.CODE_ERROR, null, 'S','E')||';'||
  et.FIELD2||';'||
  et.FIELD3||';'||
  decode(et.CODE_ERROR, null, cd.cash_back||';'||cd.total_cashback, et.CODE_ERROR||';'||et.TEXT_ERROR)||';' as cb_data
from exchange_table et
  left join cashback_data cd
    on et.transaction_id = cd.TRANSACTION_ID
where  et.FIELD1 in ('P','R')
order by et.row_id;
       */

select 
  decode(et.CODE_ERROR, null, 'S','E')||';'||
  et.FIELD2||';'||
  et.FIELD3||';'||
  decode(et.CODE_ERROR, null, cd_full.cash_back||';'||cd_full.total_cashback, et.CODE_ERROR||';'||et.TEXT_ERROR)||';' as cb_data       
from exchange_table et
left join (       
    select s.transaction_id
    , s.cash_back
    , s.sum_cashback
    , case 
        when s.sum_cashback > 3000 then 3000
        when s.sum_cashback < 100 then 0
      else
        s.sum_cashback
      end as total_cashback
    from (       
          select cd.*
          , sum(cd.cash_back) over (partition by cd.CLIENT_ID order by cd.opr_date) sum_cashback
          from cashback_data cd) s) cd_full
  on et.transaction_id = cd_full.transaction_id
where et.file_id = 63
and et.FIELD1 in ('P','R')
order by et.row_id;

select *
from validated_files t


select cd.client_id, c.card_crypto_num, cd.cash_back
      from cashback_data cd
      join cards c
        on cd.client_id = c.client_id
        and c.card_is_main = 1
      where cd.client_id is not null;

select tot_cb.client_id, c.card_crypto_num, tot_cb.total_cash_back
from
(select cd.client_id, sum(cd.cash_back) as total_cash_back
      from cashback_data cd
      where cd.client_id is not null
/*      and (cd.opr_date >= v_start
        and cd.opr_date < v_fin)*/
group by cd.CLIENT_ID) tot_cb
join cards c
  on tot_cb.client_id = c.client_id
where c.card_is_main = 1;


  
  

      
