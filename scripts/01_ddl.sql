-- created by Sergey Ermachkov

-- create directory for download files
create or replace directory files as 'C:\cashback\';

-- sequences
create sequence dic_seq
start with 1
increment by 1
nocache
nocycle;

create sequence clients_seq
start with 1
increment by 1
nocache
nocycle;

create sequence cards_seq
start with 1
increment by 1
nocache
nocycle;

create sequence transactions_seq
start with 1
increment by 1
nocache
nocycle;

create sequence merchants_seq
start with 1
increment by 1
nocache
nocycle;

create sequence errors_seq
start with 1
increment by 1
nocache
nocycle;

create sequence files_seq
start with 1
increment by 1
nocache
nocycle;

-- tables
create table cb.dic_mcc (
mcc_id               number,
mcc_code             number not null,
mcc_description      varchar2(200) not null,
constraint mcc_pk primary key (mcc_id)
);

create table cb.merchants (


);


create table cb.dic_transaction_type ();

create table cb.merchatns_programm ();


-- таблица для хранения транзакций
create table cb.transactions(
  
);

-- таблица для хранения приходов
create table cb.trans_add(
  row_type         varchar2(1),
  card_crypto      varchar2(100),
  trans_merc_id    number,
  trans_date       varchar2(100),
  sum_prise        number,
  merchant_id      number,
  mcc_code         varchar2(100),
  describe         varchar2(2000)  
);

-- таблица для хранения возвратов
create table db.trans_del(
  row_type         varchar2(1),
  card_crypto      varchar2(100),
  trans_merc_id    number,
  trans_date       varchar2(100),
  sum_prise        number,
  merchant_id      number,
  mcc_code         varchar2(100),
  describe         varchar2(2000)  
);

-- таблица для загрузки данных из файла с транзакциями
create table cb.exchange(
  field1    varchar2(1),
  field2    varchar2(100),
  field3    number,
  field4    varchar2(100),
  field5    number,
  field6    number,
  field7    varchar2(100),
  field8    varchar2(2000),
  code_error number,
  text_error varchar2(200)
);

-- таблица для учёта проверенных файлов
create table cb.verified_files (
  verified_id        number,
  file_id            cb.exchange.field1%type,
  result_file_name   varchar2(255),
  verified_data      date
);










