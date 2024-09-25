 -- procedure download_from_file (file_name in varchar2)
 -- is
 declare
    file_name varchar2(255) := upper('transactions.csv');
    
    type exch_tab is table of exchange_table%rowtype;
    v_data_list exch_tab := exch_tab();
    
    v_file      utl_file.file_type;
    v_line      varchar2(1000);
    v_eof       boolean;
       
    v_file_id  number;
    rec_exch   exchange_table%rowtype;
       
    v_cnt_p    number;
    v_cnt_r    number;
    
    v_file_ident exchange_table.field2%type;
  begin
    v_file := utl_file.fopen('IN_FILES',file_name,'R');
    
    v_cnt_p := 0;
    v_cnt_r := 0;

    loop
      -- проверка на достижение конца файла
      exit when v_eof;
             
      -- чтение следующей строки
      fileIO.get_nextline(v_file, v_line, v_eof);

      if v_line is not null
      then
        rec_exch := cashback.get_value_from_str(v_line);
        v_data_list.extend;
        v_data_list(v_data_list.last) := rec_exch;
      end if;
              
      if upper(rec_exch.field1) = upper('P')
      then
        v_cnt_p := v_cnt_p + 1;
      elsif upper(rec_exch.field1) = upper('R')
      then
        v_cnt_r := v_cnt_r + 1;
      end if;

    end loop;
    
    --dbms_output.put_line(v_data_list(v_data_list.first).field1);
    
    -- запись данных о загружаемом файле
    if v_data_list(v_data_list.first).field1 = 'H'
    then
    
      v_file_ident := v_data_list(v_data_list.first).field2;
      -- вставка в таблицу с проверенными файлами
      -- без данных о проверке, только о загрузке
      insert into VALIDATED_FILES (file_id,
                                  merchant_file_id,
                                  result_file,
                                  VALIDATED_date,
                                  result_file_name,
                                  download_date)
      values(in_file_seq.nextval,
             v_file_ident,
             null,
             null,
             null,
             sysdate)
      returning file_id into v_file_id;
      
      for i in v_data_list.first..v_data_list.last
      loop
        v_data_list(i).file_id := v_file_id;
      end loop;

    else
      --В файле отсутствует заголовок
      cashback.raise_sqlcode (-20000);
    end if;
    
    if v_data_list(v_data_list.last).field1 = 'T'
    then
      null;
    else
      --В файле отсутствует концевик
      cashback.raise_sqlcode(-20000);
    end if;
    
    if v_cnt_p = to_number(v_data_list(v_data_list.last).field2) and v_cnt_r = to_number(v_data_list(v_data_list.last).field3)
    then
      null;
    else
      --Кол-во записей в файле не соответствует данным в концевике
      cashback.raise_sqlcode(-20000);
    end if;
        
    -- вставка записей в таблицу обмена 
    forall i in v_data_list.first..v_data_list.last
      insert into exchange_table values v_data_list(i);
    
    utl_file.fclose(v_file);
    commit;
    
    exception
      --Повторное поступление файла
      when DUP_VAL_ON_INDEX then
         cashback.raise_sqlcode (-20002);
      --Длина значения атрибута превышает лими
      when VALUE_ERROR then
         cashback.raise_sqlcode (SQLCODE);
  end;
--  end download_from_file;




