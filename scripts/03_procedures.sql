/*create or replace procedure create_file () 
is

begin
  
end create_file;
*/

create or replace package cb.fileIO
is
  -- выводит доступные директории
  procedure gen_utl_file_dir_entries;
  
  -- читает строку из файла
  procedure get_nextline (
    file_in in utl_file.file_type
   ,line_out out varchar2
   ,eof_out  out boolean);
  
end fileIO;

create or replace package body cb.fileIO
is
-- процедура выводящая доступные директориии
  procedure gen_utl_file_dir_entries
  is
  begin
    for rec in (select * from all_directories)
      loop
        dbms_output.put_line ('UTL_FILE_DIR = ' || rec.directory_path);
      end loop;
  end gen_utl_file_dir_entries;

-- процедура для чтения файла
  procedure get_nextline (
    file_in in utl_file.file_type
   ,line_out out varchar2
   ,eof_out  out boolean)
  is
  begin
    utl_file.get_line (file_in, line_out);
    eof_out := false;
  exception 
    when no_data_found
    then
      line_out := null;
      eof_out  := true;     
  end get_nextline;  
  

begin
  null;
end;

-- пакет процедур для системы cashback
create or replace package cb.cashback
is
   -- функция возвращающая запись для вставки в таблицу обмена
  function get_value_from_str (str in varchar2) return cb.exchange%rowtype;
  
  -- читает файл и загружает в таблицу обмена
  procedure load_exchange_table (file_name in varchar2);
end cashback;
/

create or replace package body cb.cashback
is
  function get_value_from_str (str in varchar2) return cb.exchange%rowtype
  is
    dmtr   varchar2(1) := ';';
    v_part   varchar2(200);
    curr_pos number := 1;
    text_l   number := length(str);
    part_l    number;
    rec cb.exchange%rowtype; 
    cnt_field number := 0;
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
          exit when curr_pos = 0 or curr_pos = text_l;
        end loop;
        rec.code_error := null;
        rec.text_error := null;    
   -- end if;
    return rec;
  end get_value_from_str;

  procedure load_exchange_table (file_name in varchar2)
  is
   l_file utl_file.file_type;
   l_line varchar2(1000);
   l_eof  boolean;
   rec_exch cb.exchange%rowtype;
  begin
    l_file := utl_file.fopen('FILES',file_name,'R');

    loop
      fileIO.get_nextline(l_file, l_line, l_eof);

      exit when l_eof;
      if l_line is not null
      then       
          rec_exch := cashback.get_value_from_str(l_line);
          insert into cb.exchange values rec_exch;
      end if;

    end loop;
    utl_file.fclose(l_file);
    commit;
  end load_exchange_table;
begin
  null;
end;




