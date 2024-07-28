-- ����� �������� ��� ������� cashback
create or replace package cashback
is

  -- ���������� ��� ����������
  
  
  -- ������� ������������ ������ ��� ������� � ������� ������
  function get_value_from_str (str in varchar2) return exchange_table%rowtype;
  
  -- ������ ���� � ��������� � ������� ������
  procedure load_exchange_table (file_name in varchar2);
  
  -- ������ ����� � ����������� ��������
  procedure create_result_file (ref_in IN sys_refcursor);
end cashback;
/

create or replace package body cashback
is
   -- ������� ������������ ������ ��� ������� � ������� ������
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
  
    -- ������ ���� � ��������� � ������� ������
  procedure upload_from_file (file_name in varchar2)
  is
   l_file     utl_file.file_type;
   l_line     varchar2(1000);
   l_eof      boolean;
   
   v_file_id  number;
   rec_exch   exchange_table%rowtype;
  begin
    l_file := utl_file.fopen('IN_FILES',file_name,'R');
    

     -- ������ ������ ������ - ��������� �����
     fileIO.get_nextline(l_file, l_line, l_eof);
     rec_exch := cashback.get_value_from_str(l_line);
     
     -- ������ � ������� � �������� �����  
     if not l_eof and rec_exch.field1 = 'H'
     then
      
      
       --������� � ������� � ������������ �������
        --��� ������ � ��������, ������ � ��������
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
        
        -- ��������� ������ �� ��-� ����� ��� ���������� ������
         rec_exch.file_id := v_file_id;
        -- ������� � ������� ������
         insert into exchange_table values rec_exch;
        
        commit;  
      else
--        RAISE_APPLICATION_ERROR (-20000,'� ����� ����������� ���������');
          raise_sqlcode (-20000);
      end if;

    loop
     fileIO.get_nextline(l_file, l_line, l_eof);

     -- �������� �� ���������� ����� �����
     exit when l_eof;
      
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
      -- � ������ ���� ���� ��� �������� �����
--        RAISE_APPLICATION_ERROR (-20001,'��������� ����������� �����');
         raise_sqlcode (SQLCODE);
      when VALUE_ERROR then
         raise_sqlcode (SQLCODE);
--        RAISE_APPLICATION_ERROR (-20002,'����� �������� �������� ��������� �����');

  end upload_from_file;
  
  procedure validate_file (file_name IN varchar)
  is
  begin
    null;
  end validate_file;

  -- ������ ����� � ����������� ��������
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
                            
    -- �������� �������� �� ���� � �����������
    res_bfile := BFILENAME('OUT_FILES',new_fname);   
    
              
    -- ���������� ����� ������ �����
    update VALIDATED_FILES
    set result_file = res_bfile,
        result_file_name = new_fname
    where file_id = file_id_in;
    
    for rec in ref_in

   /* for rec in (select t.field1 ||','||t.field2||','||t.field3||','
                       ||t.field4||','||t.field5||','||t.field6||','
                       ||t.field7||','||t.field8
                       ||t.code_error||','||t.text_error
                 from exchange_table t)*/
      loop

        /*new_str := rec.field1 ||','||rec.field2||','||rec.field3||','
                   ||rec.field4||','||rec.field5||','||rec.field6||','
                   ||rec.field7||','||rec.field8
                   ||rec.code_error||','||rec.text_error;*/
       -- ������ � ����
        utl_file.put_line(l_file, rec);
      end loop;                        
    
   utl_file.fclose(l_file);
    
  end create_result_file;
  
-- ��������� � ���-� ���-��:
-- 1.�������� ������ � ������� �������
-- 2.������������ ������
-- 3.�������������� ������ ��� ���������� �� �����
-- 4.����������� ���� � ����������� ��������
-- 5.��������� ������ �� ����������� ������ �� ������� ������
  procedure upload_to_tables ()
  is
  
  begin
    for rec in (
      select et.field1,
             et.field2,
             et.field3,
             et.field4,
             et.field5,
             et.field6,
             et.field7,
             et.field8,
             et.code_error,
             et.text_error,
             et.row_id,
             et.file_id,
             et.transaction_id
      from exchange_table et 
      join VALIDATED_FILES vf
        on et.file_id = vf.file_id
      where vf.VALIDATED_data is null)
      loop
        if 
          dbms_output.put_line( );
        end if;
      end loop;
      
      cashback.create_result_file();
  
  end upload_to_tables;
  
  procedure get_requests_file ()
  is
  
  begin
  
    cashback.create_result_file();
    -- �������� ������ �� ����������� ������
    delete from exchange_table where ;
    
  end get_cashback_file;
  
  procedure get_cashback_file ()
  is
  
  begin
  
    cashback.create_result_file();
  end get_cashback_file;
  
  procedure get_register ()
  is
  
  begin
    
  end get_cashback_file;
  
begin
  null;
  
end;
/





