-- ���������� ���-�� ���������
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'min_sum_cashback', 100, '����������� ����� �������');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'max_sum_cashback', 3000, '������������ ����� �������');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'standart_rate', 0.01, '����������� ������ �������');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'high_rate', 0.05, '���������� ������ �������');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'reporting_date', 10, '���� �������������� �������');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'min_qty_operations', 10, '����������� ���-�� �������� ��� ���������� �������');

commit;

-- ��������� ���-� ������
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20000, '����������� ������ ���������; ���������',-20000);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20001, '���-�� ������� ���� P R �� ������������� ������ � �����',-20001);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20002, '��������� ����������� �����',-1);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20003, '����� �������� ��������� ��������� � �����',-6502);
--
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20004, '�������� �������������� ���������� � ������ ��������',-1);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20005, '����� ��� �������� ����������� �� ���� ������� ������� �������� �������', -20005);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20006, '����� ��������� ��������� ��������� �������', -20006);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20007, '���� �������� �������� � �������� ������', -20007);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20008, '��-� ������� ��������� ��� �������� �� ���������� � ��', 100);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20009, '��-� ���������� ��� ���������� � ��', -1);

commit;


-- ��������� ����-� MCC
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5651,'������ ��� ���� �����',0);
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5912,'������', (select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5411,'���������� ��������, ������������',(select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5200,'������ ��� ����',(select t.param_value from dic_params t where t.param_name = 'high_rate'));

commit;



-- ��������� ����-� Merchant_programms
insert into dic_merchant_programs (program_id, program_name, cashback_rate)
values (dic_seq.nextval, '����������� �������', (select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_merchant_programs (program_id, program_name, cashback_rate)
values (dic_seq.nextval, '���������� �������', (select t.param_value from dic_params t where t.param_name = 'high_rate'));

commit;

-- ��������� ���-� ���� ����������
insert into dic_transaction_types (type_id, type_name)
values (dic_seq.nextval, '�������');
insert into dic_transaction_types (type_id, type_name)
values (dic_seq.nextval, '�������');

commit;

-- ��������� ���-� ���� �������������
insert into dic_client_types (type_id, type_name)
values (dic_seq.nextval, '����������� ����');
insert into dic_client_types (type_id, type_name)
values (dic_seq.nextval, '���������� ����');

commit;

-- ������ ��������
-- 5200
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '�������� ��������', 'kvp1rBMxP23qGpfh0aZ0MDLD0u85iw');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '��� �����������', '6kHIYQUwefB6qYnNqEfGS7xzHZI8lh');

-- 5651
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Oodji', 'J0QNlCQ3aXfYkW3BOgVpM0GlwR2IkL');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Gloria Jeans', 'C1sTqMZiCwv408cF6AJDzS4xJUsUia');

-- 5912
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '������ ������', 'dQczI0TSM5if8yFFEar6aZ8UearTC3');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '��������', 'V87KFDerA30IC42oK0UbPISDoQwP0f');

-- 5411
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '��������', '9K8IpAWdWX5zm4m3MsNrjk9R7dht4w');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, '��������', 'd8aliJU70ZmfX1o2Xo4WBAFPdT07pS');

commit;


-- ������ ��������� ��� ���������
-- ��� ��������� � ��� 5200 '�������� ��������' � '��� �����������' - ������ 0% - ����������
-- ��� ��������� � ��� 5651 'Oodji' � 'Gloria Jeans' - ������ 1%
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Oodji'), 
  (select program_id from dic_merchant_programs where program_name = '����������� �������'));
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Gloria Jeans'), 
  (select program_id from dic_merchant_programs where program_name = '����������� �������'));
-- ��� ��������� � ��� 5411 '��������' � '��������' - ������ 5%  
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = '��������'), 
  (select program_id from dic_merchant_programs where program_name = '���������� �������'));
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = '��������'), 
  (select program_id from dic_merchant_programs where program_name = '���������� �������'));  
  
commit;  

-- ������ �������
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = '���������� ����'));

-- ������ ���������� ����
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'������',
'����',
'��������',
'0001',
'000001'
);

-- ������ �������
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = '���������� ����'));

-- ������ ���������� ����
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'������',
'����',
'��������',
'0002',
'000002'
);

-- ������ �������
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = '���������� ����'));

-- ������ ���������� ����
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'�����',
'�������',
'����������',
'0003',
'000003'
);


-- ������ ����� ��������
-- � ������� 3��. ����
-- � ������� 3��. ����
-- � ������ 3��. ����
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        '9e32295f8225803bb6d5fdfcc0674616a4413c1b',
        1,
        (select person_id from individual_persons where first_name = '������')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'vwjttMyVhQoOEdiCVbD1w15lMRnP024KJWZq37dk',
        0,
        (select person_id from individual_persons where first_name = '������')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        '7WwCLZhrXVikxIds1Pc7802AF3c4ES4WTi3HHfRJ',
        0,
        (select person_id from individual_persons where first_name = '������')
);
-- � ������� 3��. ����
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'oyBPJzqbsctFu2pCjofs9r9RvQEa6XqpaTljsni0',
        1,
        (select person_id from individual_persons where first_name = '������')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'UsM74p2D2ijXYp5RGascAiV7jJXUfh84mLK0ZpNY',
        0,
        (select person_id from individual_persons where first_name = '������')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'UsM74p2D2ijXYp5RGascAiV7jJXUfh84mLK0ZpNU',
        0,
        (select person_id from individual_persons where first_name = '������')
);
-- � ������ 3��. ����
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR094',
        1,
        (select person_id from individual_persons where first_name = '�����')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR095',
        0,
        (select person_id from individual_persons where first_name = '�����')
);
         

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR096',
        0,
        (select person_id from individual_persons where first_name = '�����')
);

commit;

select * from dic_client_types;
select * from dic_errors;
select * from dic_mcc;
select * from dic_merchant_programs;
select * from dic_params;
select * from dic_transaction_types;

select * from cards;
select * from clients;
select * from exchange_table;
select * from individual_persons;
select * from merchants;
select * from merchants_programs;
select * from purchases;
select * from returns;
select * from transactions;
select * from validated_files;                                   


