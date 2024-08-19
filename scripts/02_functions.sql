-- черновой вариант ф-ии - добавлена в пакет под calc_cashback
create or replace function calc_cashback_v2 (
    in_amount IN purchases.amount%type 
  , in_mcc_id IN dic_mcc.mcc_id%type
  , in_merchant_id IN merchants.merchant_id%type
  , in_opr_cnt IN number
  ) return number
  is
    v_cashback      number;
    v_high_rate     dic_params.param_value%type;
    v_standart_rate dic_params.param_value%type;
    v_excluded      mcc_merchant_excluded.excluding_id%type;
    v_mcc_high      dic_mcc.with_high_rate%type;
    v_merch_high    merchants.with_high_rate%type;
  begin
  
    select d.param_value
    into v_high_rate
    from dic_params d
    where upper(d.param_name) = upper('high_rate');
    
    select d.param_value
    into v_standart_rate
    from dic_params d
    where upper(d.param_name) = upper('standart_rate');
    
    select nvl(s.excluding_id, s.val_null)
    into v_excluded
    from
    (select null as val_null, 
        (select t.excluding_id
        from mcc_merchant_excluded t
        where t.mcc_id = in_mcc_id and t.merchant_id = in_merchant_id) as excluding_id
    from dual) s;
    
    select d.with_high_rate
    into v_mcc_high
    from dic_mcc d
    where d.mcc_id = in_mcc_id;
    
    select m.with_high_rate
    into v_merch_high
    from merchants m
    where m.merchant_id = in_merchant_id;
  
    if in_opr_cnt < 10
    then
      v_cashback := 0;
      return v_cashback;
    end if;
                
     if v_excluded is not null
     then
      v_cashback := 0;
     elsif v_excluded is null and v_merch_high = 1
     then
      v_cashback := in_amount * v_high_rate;
     elsif v_excluded is null and v_mcc_high = 1
     then
      v_cashback := in_amount * v_high_rate;
     else
      v_cashback := in_amount * v_standart_rate;
     end if;
     
     return v_cashback;
  
  end calc_cashback_v2;
