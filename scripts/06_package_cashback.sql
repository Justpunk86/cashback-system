-- пакет процедур для системы cashback
create or replace package cashback
is
  -- возвращает текст ошибки
  function get_text_error (sql_code IN pls_integer) return dic_errors.text_error%type;

  -- вызывает польз-е исключение
  procedure raise_sqlcode (sql_code IN pls_integer);
  
  -- обновляет код и текст ошибки в таблице обмена
  procedure update_error_extab (in_row_id IN number, sql_code IN pls_integer);

  -- типы для коллекций
  -- для хранения целых чисел
  type integer_array is table of integer;
  -- для хранения строк
  type varchar2_table is table of varchar2(2000);
  
  -- запись для таблицы обмена
  type type_ex_tab_rec is record (
    tr_type       exchange_table.field1%type,
    card_id       exchange_table.field2%type,
    tr_merch_id   exchange_table.field3%type,
    p_r_date      exchange_table.field4%type,
    p_r_amount    exchange_table.field5%type,
    merch_id      exchange_table.field6%type,
    mcc_purch_id  exchange_table.field7%type,
    note          exchange_table.field8%type,
    row_num       exchange_table.row_id%type,
    file_id       exchange_table.file_id%type
  );
  
  -- фун-ии воз-ие ид-ры адрибутов
  function get_trans_type_id (in_tr_type IN exchange_table.field1%type) return dic_transaction_types.type_id%type;
  function get_card_id (in_card IN exchange_table.field2%type) return cards.card_id%type;
  function get_merchant_id (in_merch IN exchange_table.field6%type) return merchants.merchant_id%type;
  function get_mcc_id (in_mcc IN exchange_table.field7%type) return dic_mcc.mcc_id%type;
  function get_purchase_id (in_mcc_purch IN exchange_table.field7%type) return purchases.purchase_id%type;
  
  -- воз-т сумму покупки
  function get_purchase_amount (in_purch_id IN purchases.purchase_id%type) return purchases.amount%type;
  -- воз-т сумму возвратов для покупки
  function get_sum_returns (in_purch_id IN purchases.purchase_id%type) return returns.amount%type;
 
  -- функция возвращающая запись для вставки в таблицу обмена
  function get_value_from_str (str in varchar2) return exchange_table%rowtype;
  
  -- ф-я для расчёта кэшбэка
  function calc_cashback (
    in_amount IN purchases.amount%type 
  , in_mcc_id IN dic_mcc.mcc_id%type
  , in_merchant_id IN merchants.merchant_id%type
  , in_opr_cnt IN number
  ) return number;
  
  -- читает файл и загружает в таблицу обмена
  procedure download_from_file (file_name in varchar2);
  
  -- запись файла с результатом проверки
  --procedure create_file (in_fname IN varchar2, in_header IN varchar2, in_last_row IN varchar2, in_cur IN sys_refcursor);
  
  -- загрузка данных из таблицы обмена в рабочие таблицы
  procedure upload_to_tables;
  
  -- проц-а для получения файла с данными о проверке поступившего файла
  procedure get_response_file(in_file_id IN number);

  -- проц-а для получения файла с данными о cashback  
  procedure get_cashback_file(in_yyyymm IN number);
  
  -- проц-а для получения реестра
  procedure get_register;
  
  -- проц-а запускающая послед-ть проц-р
  -- от загрузки файла до получения файла с рез-м    
  procedure main_proc;
  
end cashback;
/

create or replace package body cashback
is
  
  function get_text_error (sql_code IN pls_integer) return dic_errors.text_error%type
  is
    v_text dic_errors.text_error%type;
  begin
    select e.text_error
    into v_text
    from dic_errors e
    where e.sql_code_val = sql_code;
    
    return v_text;
  end get_text_error;
  
  -- вызывает польз-е исключение
  procedure raise_sqlcode (sql_code IN pls_integer)
  is
    v_errcode  dic_errors.code_error%type;
    v_errtxt  dic_errors.text_error%type;
  begin
    select t.code_error, t.text_error
    into v_errcode, v_errtxt
    from dic_errors t
    where t.sql_code_val = sql_code;

    RAISE_APPLICATION_ERROR (v_errcode, v_errtxt);
  end raise_sqlcode;
  
  -- обновляет код и текст ошибки в таблице обмена
  procedure update_error_extab (in_row_id IN number, sql_code IN pls_integer)
  is
    v_code_err  dic_errors.code_error%type;
  begin
  
    select e.code_error
    into v_code_err
    from dic_errors e
    where e.sql_code_val = sql_code;
  
    update exchange_table e
    set e.code_error = v_code_err,
      e.text_error = get_text_error(sql_code)
    where e.row_id = in_row_id;
    
    --commit;
    
  end update_error_extab;

  -- фун-я воз-я ид-р типа транзакции
  function get_trans_type_id (in_tr_type IN exchange_table.field1%type) return dic_transaction_types.type_id%type
  is
  v_pur_id dic_transaction_types.type_id%type;
  v_ret_id dic_transaction_types.type_id%type;
  begin
  
    select dt.type_id 
    into v_pur_id
    from dic_transaction_types dt 
    where upper(dt.type_name) = upper('Покупка');
    
    select dt.type_id 
    into v_ret_id
    from dic_transaction_types dt 
    where upper(dt.type_name) = upper('Возврат');
  
    if upper(in_tr_type) = upper('p')
    then
      return v_pur_id;
    elsif upper(in_tr_type) = upper('r')
    then
      return v_ret_id;
    end if;

  end get_trans_type_id;

  -- фун-я воз-я ид-р карты
  function get_card_id (in_card IN exchange_table.field2%type) return cards.card_id%type
  is
  v_out cards.card_id%type := null;
  begin
    select c.card_id
    into v_out
    from cards c
    where upper(c.card_crypto_num) = upper(in_card);
    
    return v_out;
  end get_card_id;

  -- фун-я воз-я ид-р партнёра
  function get_merchant_id (in_merch IN exchange_table.field6%type) return merchants.merchant_id%type
  is
    v_out   merchants.merchant_id%type := null;
  begin
    select m.merchant_id
    into v_out
    from merchants m
    where upper(m.merchant_orig_id) = upper(in_merch);
    
    return v_out;
  end get_merchant_id;
  
  -- фун-я воз-я ид-р mcc
  function get_mcc_id (in_mcc IN exchange_table.field7%type) return dic_mcc.mcc_id%type
  is
    v_out dic_mcc.mcc_id%type := null;
  begin
    select m.mcc_id
    into v_out
    from dic_mcc m
    where m.mcc_code = to_number(in_mcc);
    
    return v_out;
  end get_mcc_id;
  
  -- фун-я воз-я ид-р покупки
  function get_purchase_id (in_mcc_purch IN exchange_table.field7%type) return purchases.purchase_id%type
  is
    v_out purchases.purchase_id%type := null;
  begin
  
    select p.purchase_id
    into v_out
    from purchases p
      join transactions t
        on p.transaction_id = t.transaction_id
    where upper(t.original_transaction_id) = upper(in_mcc_purch);
    
    return v_out;
  end get_purchase_id;
  
  function get_purchase_amount (in_purch_id IN purchases.purchase_id%type) return purchases.amount%type
  is
    v_purch_amount  purchases.amount%type;
  begin
    select p.amount
    into v_purch_amount
    from purchases p
    where p.purchase_id = in_purch_id;  
  
    return v_purch_amount;
  end get_purchase_amount;
        
  function get_sum_returns (in_purch_id IN purchases.purchase_id%type) return returns.amount%type
  is
    v_sum_returns returns.amount%type;
  begin
    select sum(r.amount)
    into v_sum_returns
    from returns r
    where r.purchase_id = in_purch_id;
  
    return v_sum_returns;
  end get_sum_returns;

   -- функция возвращающая запись для вставки в таблицу обмена
  function get_value_from_str (str in varchar2) return exchange_table%rowtype
  is
    dmtr        varchar2(1) := ';';
    v_part      varchar2(200);
    curr_pos    number := 1;
    text_l      number := length(str);
    part_l      number;
    rec         exchange_table%rowtype; 
    cnt_field   number := 0;
  begin
  -- if str is not null-- and length(str) > 2
  -- then
      loop
          v_part := regexp_substr(str,'([A-z0-9]+\s*)+',curr_pos);
          --dbms_output.put_line(v_part);
          cnt_field := cnt_field + 1;
          part_l := length(coalesce(v_part,' '));
          curr_pos := instr(str,dmtr,curr_pos + part_l);
          case cnt_field
            when 1 then rec.field1 := v_part;
            when 2 then rec.field2 := v_part;
            when 3 then rec.field3 := v_part;
            when 4 then rec.field4 := v_part;
            when 5 then rec.field5 := v_part;
            when 6 then rec.field6 := v_part;
            when 7 then rec.field7 := v_part;
            when 8 then rec.field8 := v_part;
--          else null;
          end case;            
          rec.row_id := rows_seq.nextval;  
          rec.file_id := null;
          rec.code_error := null;
          rec.text_error := null;         
          
          exit when curr_pos = 0 or curr_pos = text_l;
      end loop;
           
   -- end if;
    return rec;
  end get_value_from_str;

  -- ф-я расчёта КБ  
  function calc_cashback (
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
  
  end calc_cashback;

  -- Здесь можно исп-ть коллекции для покупок, возвратов и транзакций
  -- читает файл и загружает в таблицу обмена
  procedure download_from_file (file_name in varchar2)
  is
   v_file     utl_file.file_type;
   v_line     varchar2(1000);
   v_eof      boolean;
   
   v_file_id  number;
   rec_exch   exchange_table%rowtype;
  begin
    v_file := utl_file.fopen('IN_FILES',file_name,'R');

     -- чтение первой строки - заголовка файла
     fileIO.get_nextline(v_file, v_line, v_eof);
     rec_exch := cashback.get_value_from_str(v_line);
     
     -- запись данных о загружаемом файле
     if not v_eof and rec_exch.field1 = 'H'
     then
        -- вставка в таблицу с проверенными файлами
        -- без данных о проверке, только о загрузке
        insert into VALIDATED_FILES (file_id,
                                    merchant_file_id,
                                    result_file,
                                    VALIDATED_date,
                                    result_file_name,
                                    download_date)
        values(in_file_seq.nextval,
               rec_exch.field2,
               null,
               null,
               null,
               sysdate)
        returning file_id into v_file_id;
        
        -- добавляем ссылку на ид-р файла для построения отчёта
        rec_exch.file_id := v_file_id;
        -- вставка в таблицу обмена
        insert into exchange_table values rec_exch;
        
        commit;  
      else
        --В файле отсутствует заголовок
        raise_sqlcode (-20000);
      end if;

    loop
     fileIO.get_nextline(v_file, v_line, v_eof);

     -- проверка на достижение конца файла
     exit when v_eof;
     -- вставка записей в таблицу обмена 
     if v_line is not null
     then       
       rec_exch := cashback.get_value_from_str(v_line);
       rec_exch.file_id := v_file_id;
       insert into exchange_table values rec_exch;
     end if;

    end loop;
    
    utl_file.fclose(v_file);
    commit;
    
    exception
      --Повторное поступление файла
      when DUP_VAL_ON_INDEX then
         raise_sqlcode (-20002);
      --Длина значения атрибута превышает лими
      when VALUE_ERROR then
         raise_sqlcode (SQLCODE);

  end download_from_file;

  -- загрузка данных в таблицы: purchases, returns, transactions
  procedure create_transaction (in_data_rec IN type_ex_tab_rec)
  is
    over_sum_purch exception;
    pragma exception_init (over_sum_purch, -20006);

    error_owner_card exception;
    pragma exception_init (error_owner_card, -20005);
    
    oper_closed_period exception;
    pragma exception_init (oper_closed_period, -20007);    
  
    v_trans_id          transactions.transaction_id%type;
    v_trans_type        dic_transaction_types.type_id%type;
    v_card_id           cards.card_id%type;
    v_mcc_id            dic_mcc.mcc_id%type;
    v_merch_id          merchants.merchant_id%type;
    v_purchase_id       purchases.purchase_id%type := null;
    v_sum_returns       returns.amount%type :=  null;
    v_purchase_amount   purchases.amount%type;
    v_operation_date    purchases.purchase_date%type;
    
    v_rep_date          date;
    v_range_is_open     varchar2(10);
    v_low_limit         date;
    v_high_limit        date;
  begin
  
    select to_date(to_char(param_value, '99'), 'dd')
      into v_rep_date                 
      from dic_params
     where param_name = 'reporting_date';

    
    v_trans_type  := get_trans_type_id (in_data_rec.tr_type);
    v_card_id     := get_card_id (in_data_rec.card_id);
    v_merch_id    := get_merchant_id (in_data_rec.merch_id);

    v_operation_date := to_date(in_data_rec.p_r_date,'yyyy.mm.dd hh24:mi:ss');
    
    
    
      
    -- открыт ли период предыдущего месяца
    -- вычисляется нижняя и верхняя граница
    if sysdate < v_rep_date
    then
      v_low_limit := trunc(sysdate,'mm') - interval '1' month;
      v_high_limit := trunc(sysdate);
    else
      v_low_limit := trunc(sysdate,'mm');
      v_high_limit := trunc(sysdate);
    end if;
    
    --dbms_output.put_line(v_low_limit ||' '|| to_date(v_operation_date, 'dd.mm.yyyy hh24:mi:ss') ||' '||v_high_limit);


    -- проверка попадания в закрытый период
    if v_operation_date < v_low_limit or v_operation_date > v_high_limit
    then
      raise_sqlcode (-20007);
    end if;
    
    -- вставка транзакции
      insert into transactions (transaction_id,
                                transaction_type,
                                original_transaction_id,
                                trans_note,
                                merchant_id,
                                in_file_id)
      values (transactions_seq.nextval,
              v_trans_type,    
              in_data_rec.tr_merch_id,
              in_data_rec.note,
              v_merch_id,
              in_data_rec.file_id
              )
      returning transaction_id into v_trans_id;
      

    --вставка покупок и возвратов
    if upper(in_data_rec.tr_type) = upper('p')
    then
      --dbms_output.put_line(v_trans_id);
      v_mcc_id := get_mcc_id (in_data_rec.mcc_purch_id);

      -- вставка покупки
      insert into purchases (purchase_id,
                             card_id,
                             purchase_date,
                             amount,
                             transaction_id,
                             mcc_id)
      values(operations_seq.nextval,
             v_card_id,
             v_operation_date,
             to_number(in_data_rec.p_r_amount),
             v_trans_id,
             v_mcc_id
            );
          
    elsif upper(in_data_rec.tr_type) = upper('r')
    then
       
      v_purchase_id := get_purchase_id (in_data_rec.mcc_purch_id);
      
      v_purchase_amount := get_purchase_amount (v_purchase_id);
      
      v_sum_returns := get_sum_returns (v_purchase_id);
      
      -- Сумма возвратов превышает стоимость покупки
      if (v_sum_returns + to_number(in_data_rec.p_r_amount)) > v_purchase_amount
      then
        raise_sqlcode (-20006);
      end if;

      -- Карта для возврата принадлежит не тому клиенту который совершал покупку
      /*
      if (v_sum_returns + to_number(in_data_rec.p_r_amount)) > v_purchase_amount
      then
        raise_sqlcode (-20005);
      end if;*/
        
      -- вставка возврата
      insert into returns (return_id,
                           return_date,
                           amount,
                           card_id,
                           transaction_id,
                           purchase_id)
      values(operations_seq.nextval,
             v_operation_date,
             to_number(in_data_rec.p_r_amount),
             v_card_id,
             v_trans_id,
             v_purchase_id
      );   
     
    end if;
    
    update exchange_table et
    set et.transaction_id = v_trans_id
    where et.row_id = in_data_rec.row_num;

    --dbms_output.put_line('trans created'); 
    commit;               
                         
  exception
  -- Длина значения атрибута превышает лимит
    when VALUE_ERROR then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,SQLCODE);

  -- Ид-р атрибута(карты, мерчанта, покупки для возврата) не существует в БД
    when NO_DATA_FOUND then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,SQLCODE); 

   -- Ид-р транзакции уже существует в БД
    when DUP_VAL_ON_INDEX then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,-20009); 
    
   -- Сумма возвратов превышает сумму покупки
    when over_sum_purch then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,SQLCODE); 
        
    
    --TODO:
    --Дата операции попадает в закрытый период
    when oper_closed_period then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,SQLCODE);
    
    -- Карта для возврата принадлежит не тому клиенту который совершал покупку
    when error_owner_card then
    dbms_output.put_line(SQLCODE);
    rollback;
    update_error_extab(in_data_rec.row_num,SQLCODE);
                          
  end create_transaction;
 
  
-- процедура в кот-й вып-ся:
-- 1.загрузка данных в рабочие таблицы
-- 2.валидируются данные

  procedure upload_to_tables
  is
  
  arr_file_id         integer_array;
  rec_data            type_ex_tab_rec;
 
  begin

    -- валидация дублей транзакций для мерчанта
    for rec_dup in (
          select et.row_id, et.field1 trans_type, et.field3 trans_id, et.field6 merch_id
          from exchange_table et
            join exchange_table etd
              on (et.field3 = etd.field3 and et.field6 = etd.field6)
          where et.transaction_id is null
            and et.code_error is null
            and et.field1 in ('P','R')
            and et.row_id <> etd.row_id
          )
      loop
        update exchange_table et
        set et.code_error = '-20004',
            et.text_error = 'Дубликат идентификатора транзакции в рамках мерчанта'
        where et.row_id = rec_dup.row_id;
          
      end loop;
        
    commit;
    
    -- Здесь можно исп-ть коллекции для покупок, возвратов и транзакций
    -- загрузки данных о покупках в рабочие таблицы из таблицы обмена
    for f_id in (select vf.file_id from validated_files vf where vf.validated_date is null)
    loop
    
      --dbms_output.put_line(f_id.file_id);
    

      for rec_data in (      
                      select et.field1 as tr_type,
                             et.field2 as card_id,
                             et.field3 as tr_merch_id,
                             et.field4 as p_r_date,
                             et.field5 as p_r_amount,
                             et.field6 as merch_id,
                             et.field7 as mcc_purch_id,
                             et.field8 as note,
                             et.row_id as row_num,
                             et.file_id
                       from exchange_table et
                      where et.file_id = f_id.file_id
                        and et.transaction_id is null
                        and et.field1 in ('P')
                        and et.code_error is null
                      )
      loop
        --dbms_output.put_line(rec_data.tr_type);
          create_transaction (rec_data);
      end loop;
       
      --commit;
        
      -- загрузки данных о возвратах в рабочие таблицы из таблицы обмена
      for rec_data in (      
                      select et.field1 as tr_type,
                             et.field2 as card_id,
                             et.field3 as tr_merch_id,
                             et.field4 as p_r_data,
                             et.field5 as p_r_amount,
                             et.field6 as merch_id,
                             et.field7 as mcc_purch_id,
                             et.field8 as note,
                             et.row_id as row_num,
                             et.file_id
                       from exchange_table et
                      where et.file_id = f_id.file_id
                        and et.transaction_id is null
                        and et.field1 in ('R')
                        and et.code_error is null
                      )
       loop

         --dbms_output.put_line(rec_data.tr_type);
         create_transaction (rec_data);

       end loop;
       
     --commit;

    end loop;
      
    --cashback.create_result_file();
  
  end upload_to_tables;

-- 4.формируется файл с результатом проверки
-- 5.Удаляются данные по проверенным файлам из таблицы обмена  
  procedure get_response_file (in_file_id IN number)
  is
  
    repeat_valid_file exception;
    pragma exception_init (repeat_valid_file, -20002);

    type rec_varchar2 is record (
      cb_data varchar2(2000)
      );
    type cur_cashback is ref cursor return rec_varchar2;

    v_cur_cb      cur_cashback;
--    v_rec_cb      v_cur_cb%rowtype;
    
    v_new_fname   varchar2(255);
    v_s_cnt       integer;
    v_e_cnt       integer;    
    
    v_header      varchar2(30);
    v_last_row    varchar2(23);
    
    create_date   date := sysdate;
    res_bfile     bfile;
    
    v_check_fname varchar2(255);
    
  begin
    
    -- проверка создан ли файл с результатом проверки
    select vf.result_file_name
    into v_check_fname
    from validated_files vf
    where vf.file_id = in_file_id;
    
    if v_check_fname is not null
    then
      raise_sqlcode (-20002);
    end if;
  
    v_header := 'H'||';'||trim(to_char(new_file_seq.nextval,'000000000009'))||';'||to_char(sysdate, 'yyyymmddhh24miss')||';';

    v_new_fname := 'res_'||create_date||'_'||new_file_seq.nextval||'.csv';
    
    select count(*)
      into v_s_cnt
      from exchange_table t 
     where t.FILE_ID = in_file_id
     and t.FIELD1 in ('P','R')
     and t.CODE_ERROR is null;
     
     select count(*)
      into v_e_cnt
      from exchange_table t 
     where t.FILE_ID = in_file_id
     and t.FIELD1 in ('P','R')
     and t.CODE_ERROR is not null;
     
    -- концевик      
    v_last_row := 'T'||';'||v_s_cnt||';'||v_e_cnt;
    
    open v_cur_cb for 
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
      where et.file_id = in_file_id
      and et.FIELD1 in ('P','R')
      order by et.row_id;
       
    -- вызов процедуры для создания файла
    fileio.create_file(v_new_fname,v_header,v_last_row, v_cur_cb);    
 

    -- создание локатора на файл с результатом
    res_bfile := BFILENAME('OUT_FILES',v_new_fname);
    
    -- Обновление имени нового файла
    update VALIDATED_FILES vf
    set vf.result_file = res_bfile,
        vf.result_file_name = v_new_fname,
        vf.validated_date = sysdate
    where vf.file_id = in_file_id;
    
    -- удаление данных по проверенным файлам
    delete from exchange_table et where et.file_id = in_file_id;
    
    commit;
    
    exception
      when NO_DATA_FOUND then
        rollback;
        raise_application_error(-20008,'Указанный идентификатор файла не найден');
      when repeat_valid_file then
        rollback;      
        raise_application_error(-20002,'Для указанного файла файл с результатом уже создавался ранее');
  end get_response_file;
  
  
  -- 3.рассчитывается кешбэк для транзакций из файла  
  procedure get_cashback_file (in_yyyymm IN number)
  is

    type rec_varchar2 is record (
      cb_data varchar2(2000)
      );
    type cur_cashback is ref cursor return rec_varchar2;

    v_cur_cb      cur_cashback;
--    v_rec_cb      v_cur_cb%rowtype;
    
    v_new_fname   varchar2(255);
    v_c_cnt       integer;
    
    v_header      varchar2(37);
    v_last_row    varchar2(23);
    
    v_start date := to_date(to_char(in_yyyymm),'yyyymm');
    v_fin   date := to_date(to_char(in_yyyymm),'yyyymm') + interval '1' month;
    
    create_date   date := sysdate;
    res_bfile     bfile;
    
    v_check_fname varchar2(255);
  begin

    v_header := 'H'||';'||
        trim(to_char(new_file_seq.nextval,'000000000009'))||';'||
        to_char(sysdate, 'yyyymmddhh24miss')||';'||
        in_yyyymm||';';

    v_new_fname := 'cbk_'||create_date||'_'||new_file_seq.nextval||'.csv';
    
    select count(*)
      into v_c_cnt
      from
      (select tot_cb.client_id, c.card_crypto_num, tot_cb.total_cash_back
        from
        (select cd.client_id, sum(cd.cash_back) as total_cash_back
           from cashback_data cd
          where cd.client_id is not null
            and (cd.opr_date >= v_start
            and cd.opr_date < v_fin)
          group by cd.CLIENT_ID
        ) tot_cb
        join cards c
          on tot_cb.client_id = c.client_id
        where c.card_is_main = 1);
     
    -- концевик      
    v_last_row := 'T'||';'||v_c_cnt||';';

    open v_cur_cb for 
      select 
          'C'||';'||
          s.card_crypto_num||';'||
          s.total_cashback||';'
           as cb_data
       from
      (select tot_cb.client_id
          , c.card_crypto_num
          , case 
              when tot_cb.total_cash_back > 3000 then 3000
              when tot_cb.total_cash_back < 100 then 0
            else
              tot_cb.total_cash_back
            end as total_cashback
        from
        (select cd.client_id, sum(cd.cash_back) as total_cash_back
           from cashback_data cd
          where cd.client_id is not null
            and (cd.opr_date >= v_start
            and cd.opr_date < v_fin)
          group by cd.CLIENT_ID
        ) tot_cb
        join cards c
          on tot_cb.client_id = c.client_id
        where c.card_is_main = 1) s;
       
    -- вызов процедуры для создания файла
    fileio.create_file(v_new_fname,v_header,v_last_row, v_cur_cb);    

  end get_cashback_file;
  
  procedure get_register
  is
    type rec_varchar2 is record (
      cb_data varchar2(2000)
      );
    type cur_cashback is ref cursor return rec_varchar2;

    v_cur_cb      cur_cashback;

    create_date   date := sysdate;
    v_new_fname   varchar2(255);
    
    v_mm      number := to_number(to_char(sysdate,'mm'));
    v_yyyy    number := to_number(to_char(sysdate,'yyyy'));
    
    v_start   date := trunc(sysdate,'mm') - interval '1' month;
    v_fin     date := trunc(sysdate,'mm');
  begin
  
    /*select to_number(to_char(sysdate,'mm')), to_number(to_char(sysdate,'yyyy'))
    into v_mm, v_yyyy
    from dual;*/
    
    v_mm := to_number(to_char(v_start,'mm'));
    v_yyyy := to_number(to_char(v_start,'yyyy'));
    
/*    select r.reg_file_name
    into 
    from registries r
    where r.reg_month = v_mm and r.reg_year = v_yyyy;*/

    v_new_fname := 'reg_'||create_date||'_'||new_file_seq.nextval||'.csv';  
    
    insert into registries (reg_id,
                            reg_month,
                            reg_year,
                            reg_file_name)
    values (
      registries_seq.nextval,
      v_mm,
      v_yyyy,
      v_new_fname);
  
    dbms_output.put_line(v_start||', '||v_fin);
  
    open v_cur_cb for 
      select 
          s.card_crypto_num||';'||
          s.total_cashback||';'
           as cb_data
       from
      (select tot_cb.client_id
          , c.card_crypto_num
          , case 
              when tot_cb.total_cash_back > 3000 then 3000
              when tot_cb.total_cash_back < 100 then 0
            else
              tot_cb.total_cash_back
            end as total_cashback
        from
        (select cd.client_id, sum(cd.cash_back) as total_cash_back
           from cashback_data cd
          where cd.client_id is not null
            and (cd.opr_date >= v_start
            and cd.opr_date < v_fin)
          group by cd.CLIENT_ID
        ) tot_cb
        join cards c
          on tot_cb.client_id = c.client_id
        where c.card_is_main = 1) s;
  
    -- вызов процедуры для создания файла
    fileio.create_file(v_new_fname,null,null,v_cur_cb);  
  
    commit;
    
  exception
    when DUP_VAL_ON_INDEX then
      raise_application_error (sqlcode, 'Реестр за указанный период сформирован ранее');
    
  end get_register;
  
    
  procedure main_proc 
  is
    v_fid number;
  begin
  
    cashback.download_from_file('transactions.csv');
      
    cashback.upload_to_tables;
  
    select min(vf.file_id)
    into v_fid
    from validated_files vf
    where vf.validated_date is null;
    
    cashback.get_response_file(v_fid);

  end main_proc;
  
begin
  null;
  
end;
/





