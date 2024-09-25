
declare
    str         varchar2(2000) := 'P;9e32295f8225803bb6d5fdfcc0674616a4413c1b;202407010002;20240701101501;2000;6kHIYQUwefB6qYnNqEfGS7xzHZI8lh;5200;describe';
    dmtr        varchar2(1) := ';';
    v_part      varchar2(200);
    curr_pos    number := 1;
    rec         exchange_table%rowtype;
    cnt_field   number := 0;
    v_dmtr_pos  number := 1;
    v_part_lenth number;

  begin

      loop
      
          v_dmtr_pos := coalesce(instr(str,dmtr,curr_pos),0);

        if v_dmtr_pos = 0
        then
          v_part := substr(str,curr_pos);   
        else
          v_part_lenth := v_dmtr_pos - curr_pos;
          v_part := substr(str,curr_pos,v_part_lenth);          
        end if;
          
          dbms_output.put_line('v_dmtr_pos = '||v_dmtr_pos||', v_part_lenth = '||v_part_lenth||', curr_pos = '||curr_pos);
          
          dbms_output.put_line(v_part);
          
          cnt_field := cnt_field + 1;

          case cnt_field
            when 1 then rec.field1 := v_part;
            when 2 then rec.field2 := v_part;
            when 3 then rec.field3 := v_part;
            when 4 then rec.field4 := v_part;
            when 5 then rec.field5 := v_part;
            when 6 then rec.field6 := v_part;
            when 7 then rec.field7 := v_part;
            when 8 then rec.field8 := v_part;
          else null;
          end case;
          
          rec.row_id := rows_seq.nextval;
          rec.file_id := null;
          rec.code_error := null;
          rec.text_error := null;
          
          curr_pos := v_dmtr_pos + 1;
          
          exit when v_dmtr_pos = 0;

      end loop;

    --return rec;
  end get_value_from_str;
