-- пакет процедур для системы cashback
create or replace package cashback
is
  -- типы для коллекций
  -- для хранения целых чисел
  type integer_array is table of integer;
  
  -- запись для таблицы обмена
  type type_ex_tab_rec is record (
    tr_type       exchange_table.field1%type,
    card_id       exchange_table.field2%type,
    tr_merch_id   exchange_table.field3%type,
    p_r_data      exchange_table.field4%type,
    p_r_amount    exchange_table.field5%type,
    merch_id      exchange_table.field6%type,
    mcc_purch_id  exchange_table.field7%type,
    note          exchange_table.field8%type,
    row_num       exchange_table.row_id%type
  );
  
  -- фун-ии воз-ие ид-ры адрибутов
  function get_trans_type_id (in_tr_type IN exchange_table.field1%type) return dic_transaction_types.type_id%type;
  function get_card_id (in_card IN exchange_table.field2%type) return cards.card_id%type;
  function get_merchant_id (in_merch IN exchange_table.field6%type) return merchants.merchant_id%type;
  function get_mcc_id (in_mcc IN exchange_table.field7%type) return dic_mcc.mcc_id%type;
  function get_purchase_id (in_mcc_purch IN exchange_table.field7%type) return purchases.purchase_id%type;
 
  -- функция возвращающая запись для вставки в таблицу обмена
  function get_value_from_str (str in varchar2) return exchange_table%rowtype;
  
  -- читает файл и загружает в таблицу обмена
  procedure upload_from_file (file_name in varchar2);
  
  -- запись файла с результатом проверки
  procedure create_result_file (file_id_in IN number, ref_in IN sys_refcursor);
  
  -- загрузка данных из таблицы обмена в рабочие таблицы
  procedure upload_to_tables;
end cashback;
/

create or replace package body cashback
is
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

  end;

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
  end;

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
  end;
  
  -- фун-я воз-я ид-р mcc
  function get_mcc_id (in_mcc IN exchange_table.field7%type) return dic_mcc.mcc_id%type
  is
    v_out dic_mcc.mcc_id%type := null;
  begin
    select m.mcc_id
    into v_out
    from dic_mcc m
    where m.mcc_code = to_number(v_out);
    
    return v_out;
  end;
  
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
    where upper(t.transaction_merch_id) = upper(in_mcc_purch);
    
    return v_out;
  end;

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
  
    -- читает файл и загружает в таблицу обмена
  procedure upload_from_file (file_name in varchar2)
  is
   l_file     utl_file.file_type;
   l_line     varchar2(1000);
   l_eof      boolean;
   
   v_file_id  number;
   rec_exch   exchange_table%rowtype;
  begin
    l_file := utl_file.fopen('IN_FILES',file_name,'R');

     -- чтение первой строки - заголовка файла
     fileIO.get_nextline(l_file, l_line, l_eof);
     rec_exch := cashback.get_value_from_str(l_line);
     
     -- запись данных о загружаемом файле
     if not l_eof and rec_exch.field1 = 'H'
     then
        -- вставка в таблицу с проверенными файлами
        -- без данных о проверке, только о загрузке
        insert into VALIDATED_FILES (file_id,
                                    merchant_file_id,
                                    result_file,
                                    VALIDATED_data,
                                    result_file_name,
                                    download_data)
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
        -- RAISE_APPLICATION_ERROR (-20000,'В файле отсутствует заголовок');
        raise_sqlcode (-20000);
      end if;

    loop
     fileIO.get_nextline(l_file, l_line, l_eof);

     -- проверка на достижение конца файла
     exit when l_eof;
     -- вставка записей в таблицу обмена 
     if l_line is not null
     then       
       rec_exch := cashback.get_value_from_str(l_line);
       rec_exch.file_id := v_file_id;
       insert into exchange_table values rec_exch;
     end if;

    end loop;
    
    utl_file.fclose(l_file);
    commit;
    
    exception
      when DUP_VAL_ON_INDEX then
      -- в случае если файл был загружен ранее
--        RAISE_APPLICATION_ERROR (-20001,'Повторное поступление файла');
         raise_sqlcode (SQLCODE);
      when VALUE_ERROR then
         raise_sqlcode (SQLCODE);
--        RAISE_APPLICATION_ERROR (-20002,'Длина значения атрибута превышает лимит');

  end upload_from_file;

  -- запись файла с результатом проверки
  procedure create_result_file (file_id_in IN number, ref_in IN sys_refcursor)
  is
  l_file           utl_file.file_type;
  new_fname        varchar2(255);
  create_date       date := sysdate;
--  verif_file_id    varchar2(12);
  new_str          varchar2(2000);
  res_bfile        bfile;
  begin
    new_fname := 'res_'||create_date||'_'||new_file_seq.nextval||'.csv';
    l_file := utl_file.fopen(location     => 'OUT_FILES',
                            filename     => upper(new_fname),
                            open_mode    => 'W');
                            
    -- создание локатора на файл с результатом
    res_bfile := BFILENAME('OUT_FILES',new_fname);   
    
              
    -- Обновление имени нового файла
    update VALIDATED_FILES
    set result_file = res_bfile,
        result_file_name = new_fname
    where file_id = file_id_in;
    
    -- TODO: выборка данных из курсорной переменной
    --for rec in ref_in

    for rec in (select t.field1 ||';'||t.field2||';'||t.field3||';'
                       ||t.field4||';'||t.field5||';'||t.field6||';'
                       ||t.field7||';'||t.field8
                       ||t.code_error||';'||t.text_error||';' as str
                 from exchange_table t)
      loop

        /*new_str := rec.field1 ||','||rec.field2||','||rec.field3||','
                   ||rec.field4||','||rec.field5||','||rec.field6||','
                   ||rec.field7||','||rec.field8
                   ||rec.code_error||','||rec.text_error;*/
       -- записи в файл
        utl_file.put_line(l_file, rec.str);
      end loop;                        
    
   utl_file.fclose(l_file);
    
  end create_result_file;
  
  -- загрузка данных в таблицы: purchases, returns, transactions
  procedure create_transaction (in_data_rec IN type_ex_tab_rec)
  is
    v_trans_id        transactions.transaction_id%type;
    v_trans_type      dic_transaction_types.type_id%type;
    v_card_id         cards.card_id%type;
    v_mcc_id          dic_mcc.mcc_id%type;
    v_merch_id        merchants.merchant_id%type;
    v_purchase_id     purchases.purchase_id%type := null;
    
  begin
    
    v_trans_type  := get_trans_type_id (in_data_rec.tr_type);
    v_card_id     := get_card_id (in_data_rec.card_id);
    v_mcc_id      := get_mcc_id (in_data_rec.mcc_purch_id);
    v_merch_id    := get_merchant_id (in_data_rec.merch_id);
    
    
    -- вставка транзакции
      insert into transactions (transaction_id,
                                transaction_type,
                                transaction_merch_id,
                                trans_note)
      values (transactions_seq.nextval,
              v_trans_type,    
              in_data_rec.tr_merch_id,
              in_data_rec.note
              )
      returning transaction_id into v_trans_id;
  

    if upper(in_data_rec.tr_type) = upper('p')
    then

      -- вставка покупки
      insert into purchases (purchase_id,
                             card_id,
                             purchase_data,
                             amount,
                             transaction_id,
                             mcc_id,
                             merchant_id)
      values(operations_seq.nextval,
             v_card_id,
             to_date(in_data_rec.p_r_data,'dd.mm.yyyy'),
             to_number(in_data_rec.p_r_amount),
             v_trans_id,
             v_mcc_id,
             v_merch_id
            );
          
    elsif upper(in_data_rec.tr_type) = upper('r')
    then
      /*select p.purchase_id
        into v_purchase_id
        from purchases p
          join transactions t
            on p.transaction_id = t.transaction_id
        where upper(t.transaction_merch_id) = upper(in_data_rec.mcc_purch_id);*/
        
      v_purchase_id := get_purchase_id (in_data_rec.mcc_purch_id);
        
      -- вставка возврата
      insert into returns (return_id,
                           return_data,
                           amount,
                           card_id,
                           transaction_id,
                           purchase_id)
      values(operations_seq.nextval,
             to_date(in_data_rec.p_r_data,'dd.mm.yyyy'),
             to_number(in_data_rec.p_r_amount),
             v_card_id,
             v_trans_id,
             v_purchase_id
      );   
    /*else

      update exchange_table et
      set et.code_error = '-20008',
        et.text_error = (select e.text_error from dic_errors e where e.code_error = '-20008')
      where et.row_id = in_data_rec.row_num;
      
      commit;*/
        
    end if;

    dbms_output.put_line('trans created');                
                         
  exception
    when others then
      rollback;
      
      /*if SQLCODE = -20008
      then*/
        
                             
  end create_transaction;
 
  
-- процедура в кот-й вып-ся:
-- 1.загрузка данных в рабочие таблицы
-- 2.валидируются данные
-- 3.рассчитывается кешбэк для транзакций из файла
-- 4.формируется файл с результатом проверки
-- 5.Удаляются данные по проверенным файлам из таблицы обмена
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
   
    -- загрузки данных о покупках в рабочие таблицы из таблицы обмена
    for f_id in (select vf.file_id from validated_files vf where vf.validated_data is null)
    loop
    
      dbms_output.put_line(f_id.file_id);
    

      for rec_data in (      
                      select et.field1 as tr_type,
                             et.field2 as card_id,
                             et.field3 as tr_merch_id,
                             et.field4 as p_r_data,
                             et.field5 as p_r_amount,
                             et.field6 as merch_id,
                             et.field7 as mcc_purch_id,
                             et.field8 as note,
                             et.row_id as row_num
                       from exchange_table et
                      where et.file_id = f_id.file_id
                        and et.transaction_id is null
                        and et.field1 in ('P')
                        and et.code_error is null
                      )
      loop

        dbms_output.put_line(rec_data.tr_type);
        create_transaction (rec_data);

      end loop;
       
      commit;
        
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
                             et.row_id as row_num
                       from exchange_table et
                      where et.file_id = f_id.file_id
                        and et.transaction_id is null
                        and et.field1 in ('R')
                        and et.code_error is null
                      )
       loop

         dbms_output.put_line(rec_data.tr_type);
         create_transaction (rec_data);

       end loop;
       
     commit;

    end loop;
      
    --cashback.create_result_file();
  
  end upload_to_tables;
  
 /* procedure get_requests_file
  is
  
  begin
  
    cashback.create_result_file();
    -- удаление данных по проверенным файлам
    delete from exchange_table where ;
    
  end get_requests_file;
  
  procedure get_cashback_file
  is
  
  begin
  
    cashback.create_result_file();
  end get_cashback_file;
  
  procedure get_register
  is
  
  begin
    
  end get_register;*/
  
begin
  null;
  
end;
/





