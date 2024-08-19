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
  procedure create_file (in_fname IN varchar2, in_header IN varchar2, in_last_row IN varchar2, in_cur IN sys_refcursor);
  
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
  
    -- создание файла
  procedure create_file (in_fname IN varchar2, in_header IN varchar2, in_last_row IN varchar2, in_cur IN sys_refcursor)
  is
  v_file      utl_file.file_type;
  v_str       varchar2(2000);
  v_cnt_rows  integer;
  begin
    
    v_file := utl_file.fopen(location     => 'OUT_FILES',
                            filename     => upper(in_fname),
                            open_mode    => 'A');
    
    utl_file.put_line(v_file, in_header);

      loop
        fetch in_cur into v_str;

        exit when in_cur%notfound;
       -- записи в файл
--       dbms_output.put_line(v_str);
        utl_file.put_line(v_file, v_str);

      end loop;
      
   close in_cur;
   
   utl_file.put_line(v_file, in_last_row);
    
   utl_file.fclose(v_file);
    
  end create_file;
  

begin
  null;
end;
/


