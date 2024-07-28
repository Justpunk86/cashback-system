-- наполнение спр-ка Параметры
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'min_sum_cashback', 100, 'Минимальная сумма кешбэка');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'max_sum_cashback', 3000, 'Максимальная сумма кешбэка');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'standart_rate', 0.01, 'Стандартный размер кешбэка');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'high_rate', 0.05, 'Повышенный размер кешбэка');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'reporting_date', 10, 'Дата предоставления реестра');
insert into dic_params (param_id,param_name,param_value,description)
values (dic_seq.nextval, 'min_qty_operations', 10, 'Минимальное кол-во операций для начисления кешбэка');

commit;

-- наполняем спр-к ошибок
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20000, 'Отсутствует записи Заголовок; Хвостовик',-20000);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20001, 'Кол-во записей типа P R не соответствует данным в файле',-20001);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20002, 'Повторное поступление файла',-1);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20003, 'Длина значения превышает указанный в файле',-6502);
--
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20004, 'Дубликат идентификатора транзакции в рамках мерчанта',-1);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20005, 'Карта для возврата принадлежит не тому клиенту который совершал покупку', -20005);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20006, 'Сумма возвратов превышает стоимость покупки', -20006);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20007, 'Дата операции попадает в закрытый период', -20007);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20008, 'Ид-р покупки указанный для возврата не существует в БД', 100);
insert into dic_errors(error_id, code_error, text_error,sql_code_val)
values(dic_seq.nextval, -20009, 'Ид-р транзакции уже существует в БД', -1);

commit;


-- наполняем спра-к MCC
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5651,'Одежда для всей семьи',0);
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5912,'Аптеки', (select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5411,'Бакалейные магазины, супермаркеты',(select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_mcc (mcc_id, mcc_code, mcc_description,cashback_rate) values (dic_seq.nextval, 5200,'Товары для дома',(select t.param_value from dic_params t where t.param_name = 'high_rate'));

commit;



-- наполняем спра-к Merchant_programms
insert into dic_merchant_programs (program_id, program_name, cashback_rate)
values (dic_seq.nextval, 'Стандартный возврат', (select t.param_value from dic_params t where t.param_name = 'standart_rate'));
insert into dic_merchant_programs (program_id, program_name, cashback_rate)
values (dic_seq.nextval, 'Повышенный возврат', (select t.param_value from dic_params t where t.param_name = 'high_rate'));

commit;

-- наполняем спр-к Типы транзакций
insert into dic_transaction_types (type_id, type_name)
values (dic_seq.nextval, 'Покупка');
insert into dic_transaction_types (type_id, type_name)
values (dic_seq.nextval, 'Возврат');

commit;

-- наполняем спр-к Типы пользователей
insert into dic_client_types (type_id, type_name)
values (dic_seq.nextval, 'Юридическое лицо');
insert into dic_client_types (type_id, type_name)
values (dic_seq.nextval, 'Физическое лицо');

commit;

-- данные Партнёры
-- 5200
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Галамарт Гринпарк', 'kvp1rBMxP23qGpfh0aZ0MDLD0u85iw');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'ДОМ гипермаркет', '6kHIYQUwefB6qYnNqEfGS7xzHZI8lh');

-- 5651
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Oodji', 'J0QNlCQ3aXfYkW3BOgVpM0GlwR2IkL');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Gloria Jeans', 'C1sTqMZiCwv408cF6AJDzS4xJUsUia');

-- 5912
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Магнит Аптека', 'dQczI0TSM5if8yFFEar6aZ8UearTC3');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Бережная', 'V87KFDerA30IC42oK0UbPISDoQwP0f');

-- 5411
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Светофор', '9K8IpAWdWX5zm4m3MsNrjk9R7dht4w');
insert into merchants (merchant_id, merchant_name, merchant_orig_id)
values (merchants_seq.nextval, 'Вкусвилл', 'd8aliJU70ZmfX1o2Xo4WBAFPdT07pS');

commit;


-- данные Программы для партнёров
-- для партнёров с МСС 5200 'Галамарт Гринпарк' и 'ДОМ гипермаркет' - кешбэк 0% - исключение
-- для партнёров с МСС 5651 'Oodji' и 'Gloria Jeans' - кешбэк 1%
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Oodji'), 
  (select program_id from dic_merchant_programs where program_name = 'Стандартный возврат'));
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Gloria Jeans'), 
  (select program_id from dic_merchant_programs where program_name = 'Стандартный возврат'));
-- для партнёров с МСС 5411 'Светофор' и 'Вкусвилл' - кешбэк 5%  
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Светофор'), 
  (select program_id from dic_merchant_programs where program_name = 'Повышенный возврат'));
insert into merchants_programs (mp_id, merchant_id, program_id)
values(merchprog_seq.nextval, 
  (select t.merchant_id from merchants t where t.merchant_name = 'Вкусвилл'), 
  (select program_id from dic_merchant_programs where program_name = 'Повышенный возврат'));  
  
commit;  

-- данные Клиенты
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = 'Физическое лицо'));

-- данные Физические лица
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'Иванов',
'Иван',
'Иванович',
'0001',
'000001'
);

-- данные Клиенты
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = 'Физическое лицо'));

-- данные Физические лица
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'Петров',
'Петр',
'Петрович',
'0002',
'000002'
);

-- данные Клиенты
insert into clients (client_id, client_type_id)
values (clients_seq.nextval, (select type_id from dic_client_types where type_name = 'Физическое лицо'));

-- данные Физические лица
insert into individual_persons (person_id,
                                first_name,
                                last_name,
                                middle_name,
                                passport_sn,
                                passport_num)
values (clients_seq.currval,
'Алёшин',
'Алексей',
'Алексеевич',
'0003',
'000003'
);


-- данные Карты клиентов
-- у Иванова 3шт. карт
-- у Петрова 3шт. карт
-- у Алёшина 3шт. карт
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        '9e32295f8225803bb6d5fdfcc0674616a4413c1b',
        1,
        (select person_id from individual_persons where first_name = 'Иванов')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'vwjttMyVhQoOEdiCVbD1w15lMRnP024KJWZq37dk',
        0,
        (select person_id from individual_persons where first_name = 'Иванов')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        '7WwCLZhrXVikxIds1Pc7802AF3c4ES4WTi3HHfRJ',
        0,
        (select person_id from individual_persons where first_name = 'Иванов')
);
-- у Петрова 3шт. карт
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'oyBPJzqbsctFu2pCjofs9r9RvQEa6XqpaTljsni0',
        1,
        (select person_id from individual_persons where first_name = 'Петров')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'UsM74p2D2ijXYp5RGascAiV7jJXUfh84mLK0ZpNY',
        0,
        (select person_id from individual_persons where first_name = 'Петров')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'UsM74p2D2ijXYp5RGascAiV7jJXUfh84mLK0ZpNU',
        0,
        (select person_id from individual_persons where first_name = 'Петров')
);
-- у Алёшина 3шт. карт
insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR094',
        1,
        (select person_id from individual_persons where first_name = 'Алёшин')
);

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR095',
        0,
        (select person_id from individual_persons where first_name = 'Алёшин')
);
         

insert into cards (card_id,
                   card_crypto_num,
                   card_is_main,
                   client_id)
values (cards_seq.nextval,
        'a89xm6ZoxkqGE5sDveZhNCKM2k9kYb0B3BXHR096',
        0,
        (select person_id from individual_persons where first_name = 'Алёшин')
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


