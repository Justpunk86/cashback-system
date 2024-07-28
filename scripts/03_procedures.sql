create or replace package fileIO
is
  -- выводит доступные директории
  procedure gen_utl_file_dir_entries;
  
  -- читает строку из файла
  procedure get_nextline (
    file_in in utl_file.file_type
   ,line_out out varchar2
   ,eof_out  out boolean);
   
  -- создание файла
--  procedure create_file (
  
end fileIO;
/

create or replace package body fileIO
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

-- процедура для чтения строки из файла
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
/

create or replace procedure raise_sqlcode (sql_code IN pls_integer)
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
/


