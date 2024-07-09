/*create table cb.exchange(
  field1    varchar2(1),
  field2    varchar2(100),
  field3    number,
  field4    varchar2(100),
  field5    number,
  field6    number,
  field7    varchar2(100),
  field8    varchar2(2000)
)
organization external(
  type oracle_loader
  default directory files
  
  access parameters 
  (
    records delimited by newline
    fields terminated by ';'
    
  )
  location ('transactions.csv')
)
reject limit unlimited;*/

-- block for read file
/*declare
 l_file utl_file.file_type;
 l_line varchar2(1000);
 l_eof  boolean;
 v_path varchar2(100) := 'transactions.csv';
begin
  l_file := utl_file.fopen('FILES',v_path,'R');

  loop
    fileIO.get_nextline(l_file, l_line, l_eof);
    exit when l_eof;
    dbms_output.put_line(l_line);
  end loop;
end;*/

--H;1234;20240601101500;
--'P;9e32295f 8225803b b6d5fdfc c0674616 a4413c1b;000101062024;20240601101500;100000;1;0742;describe;'

-- block for parse str
/*declare
  str    varchar2(200) := 'H;1234;20240601101500;';
  dmtr   varchar2(1) := ';';
  v_part   varchar2(200);
  curr_pos number := 1;
  text_l   number := length(str);
  part_l    number;
begin
  dbms_output.put_line(text_l);
  --for i in 1..8
    loop
      --v_part := coalesce(regexp_substr(str,'([A-z0-9]+\s*)+',curr_pos),' ');
      v_part := regexp_substr(str,'([A-z0-9]+\s*)+',curr_pos);
      dbms_output.put_line(v_part);

      
      part_l := length(coalesce(v_part,' '));
      
      curr_pos := instr(str,dmtr,curr_pos + part_l);
      dbms_output.put_line(part_l);
      dbms_output.put_line(curr_pos);
      exit when curr_pos = 0 or curr_pos = text_l;
    end loop;
end;*/

truncate table cb.exchange;

declare
-- v_temp varchar2(100);
 v_temp cb.exchange%rowtype;
begin
  cashback.load_exchange_table('transactions.csv');
 /* v_temp := cashback.get_value_from_str ('T;2;1;;;;;;');
  dbms_output.put_line(v_temp.field1);
  dbms_output.put_line(v_temp.field2);
  dbms_output.put_line(v_temp.field3);
  dbms_output.put_line(v_temp.field4);
  dbms_output.put_line(v_temp.field5);
  dbms_output.put_line(v_temp.field6);
  dbms_output.put_line(v_temp.field7);
  dbms_output.put_line(v_temp.field8);
  dbms_output.put_line(v_temp.code_error);
  dbms_output.put_line(v_temp.text_error);*/
end;
/

select * from cb.exchange;

