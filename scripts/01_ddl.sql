-- created by Sergey Ermachkov
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

create user cb identified by cb;

ALTER USER cb DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;

grant create session
     , create table
     , create procedure 
     , create sequence
     , create trigger
     , create view
     , create synonym
     , alter session
     , create any directory
to cb;     

-- create directory for download files
create or replace directory in_files as 'C:\cashback_files\in\';
create or replace directory out_files as 'C:\cashback_files\out\';

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

create sequence operations_seq
start with 1
increment by 1
nocache
nocycle;

create sequence merchants_seq
start with 1
increment by 1
nocache
nocycle;

/*create sequence errors_seq
start with 1
increment by 1
nocache
nocycle;*/

create sequence new_file_seq
start with 1
increment by 1
nocache
nocycle;

create sequence in_file_seq
start with 1
increment by 1
nocache
nocycle;

create sequence verifn_seq
start with 1
increment by 1
nocache
nocycle;

create sequence rows_seq
start with 1
increment by 1
nocache
nocycle;

create sequence registries_seq
start with 1
increment by 1
nocache
nocycle;

-- Create table
create table DIC_ERRORS
(
  error_id   NUMBER not null,
  code_error VARCHAR2(100) not null,
  text_error VARCHAR2(200) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table DIC_ERRORS
  is 'Данные о видах ошибок и кодах';
-- Add comments to the columns 
comment on column DIC_ERRORS.code_error
  is 'Код ошибки';
comment on column DIC_ERRORS.text_error
  is 'Текст ошибки';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_ERRORS
  add constraint DIC_ERRORS_PK primary key (ERROR_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_ERRORS
  add constraint DIC_ERRORS_UK unique (CODE_ERROR, TEXT_ERROR)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create table
create table DIC_PARAMS
(
  param_id    NUMBER not null,
  param_name  VARCHAR2(100) not null,
  param_value NUMBER not null,
  description VARCHAR2(255) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table DIC_PARAMS
  is 'Данные о параметрах используемых в системе';
-- Add comments to the columns 
comment on column DIC_PARAMS.param_name
  is 'Имя параметра';
comment on column DIC_PARAMS.param_value
  is 'Значение параметра';
comment on column DIC_PARAMS.description
  is 'Описание параметра';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_PARAMS
  add constraint DIC_PARAMS_PK primary key (PARAM_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_PARAMS
  add constraint DIC_PARAMS_NAME_VALUE_UK unique (PARAM_NAME, PARAM_VALUE)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
  
drop table REGISTRIES;  
  
-- Create table
create table REGISTRIES
(
  reg_id        NUMBER not null,
  reg_month         NUMBER not null,
  reg_year          NUMBER not null,
  reg_file_name VARCHAR2(255) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table REGISTRIES
  is 'Данные о сформированных реестрах';
-- Add comments to the columns 
comment on column REGISTRIES.reg_month
  is 'Месяц за который сформирован реестр';
comment on column REGISTRIES.reg_year
  is 'Год за который сформирован реестр';
comment on column REGISTRIES.reg_file_name
  is 'Имя файла';
-- Create/Recreate primary, unique and foreign key constraints 
alter table REGISTRIES
  add constraint REGISTRIES_PK primary key (REG_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table REGISTRIES
  add constraint REGISTRIES_UK unique (reg_MONTH, reg_YEAR)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create table
create table DIC_TRANSACTION_TYPES
(
  type_id   NUMBER not null,
  type_name VARCHAR2(100) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table DIC_TRANSACTION_TYPES
  is 'Справочник типов транзакций (покупка, возврат)';
-- Add comments to the columns 
comment on column DIC_TRANSACTION_TYPES.type_name
  is 'Тип транзакции покупка, возврат';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_TRANSACTION_TYPES
  add constraint DIC_TRANSACTION_TYPES_PK primary key (TYPE_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_TRANSACTION_TYPES
  add constraint DIC_TRANSACTION_TYPES_UK unique (TYPE_NAME)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create table
create table DIC_MCC
(
  mcc_id          NUMBER not null,
  mcc_code        NUMBER(4) not null,
  with_high_rate  number(1) not null,
  mcc_description VARCHAR2(2000) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table DIC_MCC
  is 'Справочник MCC кодов';
-- Add comments to the columns 
comment on column DIC_MCC.mcc_code
  is 'MCC код';
comment on column DIC_MCC.with_high_rate
  is 'Повышенный кешбэк';  
comment on column DIC_MCC.mcc_description
  is 'Описание вида дейятельности';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_MCC
  add constraint DIC_MCC_PK primary key (MCC_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_MCC
  add constraint DIC_MCC_CODE_UK unique (MCC_CODE)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_MCC
  add constraint DIC_MCC_HIGHRATE_CK CHECK (with_high_rate = 1 OR with_high_rate = 0);  


-- Create table
create table MERCHANTS
(
  merchant_id      NUMBER not null,
  merchant_name    VARCHAR2(255) not null,
  merchant_orig_id VARCHAR2(30) not null,
  with_high_rate   number
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table MERCHANTS
  is 'Партнёры';
-- Add comments to the columns 
comment on column MERCHANTS.merchant_name
  is 'Наименование партнёра';
comment on column MERCHANTS.merchant_orig_id
  is 'Ид-р партнера из файла';
comment on column MERCHANTS.with_high_rate
  is 'Повышенный кешбэк';    
-- Create/Recreate primary, unique and foreign key constraints 
alter table MERCHANTS
  add constraint MERCHANTS_PK primary key (MERCHANT_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MERCHANTS
  add constraint MERCHANTS_NAME_UK unique (MERCHANT_NAME)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MERCHANTS
  add constraint MERCHANTS_ORIGID_UK unique (MERCHANT_ORIG_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;  
alter table MERCHANTS
  add constraint MERCHANTS_HIGHRATE_CK CHECK (with_high_rate = 1 OR with_high_rate = 0);  
  
-- Create table
create table MCC_MERCHANT_EXCLUDED
(
  excluding_id NUMBER not null,
  mcc_id       NUMBER not null,
  merchant_id  NUMBER not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table MCC_MERCHANT_EXCLUDED
  is 'Список исключений mcc и мерчантов';
-- Add comments to the columns 
comment on column MCC_MERCHANT_EXCLUDED.mcc_id
  is 'Ид-р кода mcc';
comment on column MCC_MERCHANT_EXCLUDED.merchant_id
  is 'Ид-р мерчанта';
-- Create/Recreate primary, unique and foreign key constraints 
alter table MCC_MERCHANT_EXCLUDED
  add constraint EXCLUDED_MCC_MERC_PK primary key (EXCLUDING_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MCC_MERCHANT_EXCLUDED
  add constraint EXCLUDED_MCC_MERC_UK unique (MCC_ID, MERCHANT_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MCC_MERCHANT_EXCLUDED
  add constraint EXCLUDED_MCC_FK foreign key (MCC_ID)
  references DIC_MCC (MCC_ID);
alter table MCC_MERCHANT_EXCLUDED
  add constraint EXCLUDED_MERC_FK foreign key (MERCHANT_ID)
  references MERCHANTS (MERCHANT_ID);    



-- Create table
create table DIC_CLIENT_TYPES
(
  type_id   NUMBER not null,
  type_name VARCHAR2(200) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table DIC_CLIENT_TYPES
  is 'Справочник типов клиентов физ., юр.';
-- Add comments to the columns 
comment on column DIC_CLIENT_TYPES.type_name
  is 'Наименование типа клиента';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_CLIENT_TYPES
  add constraint DIC_CLIENTS_TYPE_PK primary key (TYPE_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create table
create table CLIENTS
(
  client_id      NUMBER not null,
  client_type_id NUMBER
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table CLIENTS
  is 'Таблица для хранения данных о клиентах';
-- Add comments to the columns 
comment on column CLIENTS.client_type_id
  is 'Идентификатор типа клиента';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CLIENTS
  add constraint CLIENTS_PK primary key (CLIENT_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table CLIENTS
  add constraint CLIENTS_TYPE_FK foreign key (CLIENT_TYPE_ID)
  references DIC_CLIENT_TYPES (TYPE_ID);
  
drop table documents;
  
create table documents
(
  doc_id        number,
  doc_type      varchar2(30)  not null,
  doc_serial   NUMBER(4)  not null,
  doc_number  NUMBER(6)  not null,
  person_id     number  not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );    
-- Add comments to the table 
comment on table documents
  is 'Документы';  
comment on column documents.doc_serial
  is 'Серия документа';
comment on column documents.doc_number
  is 'Номер документа';
comment on column documents.person_id
  is 'Ид-р клиента';
alter table documents
  add constraint documents_pk primary key (doc_id)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;    
alter table documents
  add constraint documents_uk unique (doc_serial, doc_number)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;  
alter table documents
  add constraint documents_persons_fk foreign key (person_id)
  references individual_persons(person_id);  

--drop table INDIVIDUAL_PERSONS;
-- Create table
create table INDIVIDUAL_PERSONS
(
  person_id    NUMBER not null,
  first_name   VARCHAR2(255) not null,
  last_name    VARCHAR2(255) not null,
  middle_name  VARCHAR2(255) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table INDIVIDUAL_PERSONS
  is 'Физические лица';
-- Add comments to the columns 
comment on column INDIVIDUAL_PERSONS.first_name
  is 'Имя';
comment on column INDIVIDUAL_PERSONS.last_name
  is 'Фамилия';
comment on column INDIVIDUAL_PERSONS.middle_name
  is 'Отчество';
-- Create/Recreate primary, unique and foreign key constraints 
alter table INDIVIDUAL_PERSONS
  add constraint INDIVID_PERSONS_PK primary key (PERSON_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table INDIVIDUAL_PERSONS
  add constraint INDIVID_PERSONS_FK foreign key (PERSON_ID)
  references CLIENTS (CLIENT_ID);


-- Create table
create table CARDS
(
  card_id         NUMBER not null,
  card_crypto_num VARCHAR2(40) not null,
  card_is_main    NUMBER(1) not null,
  client_id       NUMBER not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table CARDS
  is 'Банковские карты клиентов';
-- Add comments to the columns 
comment on column CARDS.card_crypto_num
  is 'SHA1-криптограмма номера карты';
comment on column CARDS.card_is_main
  is 'Главная карта';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CARDS
  add constraint CARDS_PK primary key (CARD_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table CARDS
  add constraint CARDS_CRYPTONUM_UK unique (CARD_CRYPTO_NUM)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table CARDS
  add constraint CARDS_CLIENT_FK foreign key (CLIENT_ID)
  references CLIENTS (CLIENT_ID);
-- Create/Recreate check constraints 
alter table CARDS
  add constraint CARDS_IS_MAIN_CK
  check (card_is_main = 0 or card_is_main = 1);

--drop table VALIDATED_FILES;

-- Create table
create table VALIDATED_FILES
(
  file_id          NUMBER not null,
  merchant_file_id NUMBER,
  download_date    DATE,
  result_file      BLOB,
  result_file_name VARCHAR2(255),
  validated_date    DATE
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table VALIDATED_FILES
  is 'Данные о загруженных файлах';
-- Add comments to the columns 
comment on column VALIDATED_FILES.merchant_file_id
  is 'Ид-р поступившего файла из заголовка';
comment on column VALIDATED_FILES.download_date
  is 'Дата загрузки';
comment on column VALIDATED_FILES.result_file
  is 'Ссылка на файл с результатом';
comment on column VALIDATED_FILES.result_file_name
  is 'Имя файла с результатом';
comment on column VALIDATED_FILES.validated_date
  is 'Дата валидации';
-- Create/Recreate primary, unique and foreign key constraints 
alter table VALIDATED_FILES
  add constraint VALIDATED_FILES_PK primary key (FILE_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table VALIDATED_FILES
  add constraint VALIDATED_FILES_UK unique (MERCHANT_FILE_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;


-- Create table
create table TRANSACTIONS
(
  transaction_id      NUMBER not null,
  transaction_type    NUMBER not null,
  original_transaction_id NUMBER(12) not null,
  merchant_id         NUMBER not null,
  in_file_id          number,
  trans_note         VARCHAR2(2000)
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table TRANSACTIONS
  is 'Данные о транзакциях';
-- Add comments to the columns 
comment on column TRANSACTIONS.transaction_type
  is 'Тип транзакции';
comment on column TRANSACTIONS.original_transaction_id
  is 'Идентификатор транзакции в системе мерчанта';
comment on column TRANSACTIONS.merchant_id
  is 'Ид-р мерчанта';
comment on column TRANSACTIONS.in_file_id
  is 'Ид-р входящего файла';
comment on column TRANSACTIONS.trans_note
  is 'Дополнительное описание';
-- Create/Recreate primary, unique and foreign key constraints 
alter table TRANSACTIONS
  add constraint TRANSACTIONS_PK primary key (TRANSACTION_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table TRANSACTIONS
  add constraint TRANSACTIONS_MERCH_UK unique (original_transaction_id, MERCHANT_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table TRANSACTIONS
  add constraint TRANSACTIONS_MERCH_FK foreign key (MERCHANT_ID)
  references MERCHANTS (MERCHANT_ID);
alter table TRANSACTIONS
  add constraint TRANSACTIONS_TYPE_FK foreign key (TRANSACTION_TYPE)
  references DIC_TRANSACTION_TYPES (TYPE_ID);
alter table TRANSACTIONS
  add constraint TRANSACTIONS_FILEID_FK foreign key (IN_FILE_ID)
  references VALIDATED_FILES (FILE_ID);


-- Create table
create table PURCHASES
(
  purchase_id    NUMBER not null,
  card_id        NUMBER not null,
  purchase_date  DATE not null,
  amount         NUMBER(9,2) not null,
  transaction_id NUMBER not null,
  MCC_ID          NUMBER
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table PURCHASES
  is 'Данные об операциях покупок';
-- Add comments to the columns 
comment on column PURCHASES.card_id
  is 'Ид-р банковской карты';
comment on column PURCHASES.purchase_date
  is 'Дата покупки';
comment on column PURCHASES.amount
  is 'Сумма покупки';
comment on column PURCHASES.MCC_ID
  is 'MCC код';  
comment on column PURCHASES.transaction_id
  is 'Ид-р транзакции';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PURCHASES
  add constraint PURCHASES_PK primary key (PURCHASE_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table PURCHASES
  add constraint PURCHASES_TRANS_ID unique (TRANSACTION_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table PURCHASES
  add constraint PURCHASES_CARDS_FK foreign key (CARD_ID)
  references CARDS (CARD_ID);
alter table PURCHASES
  add constraint PURCHASES_TRANS_ID_FK foreign key (TRANSACTION_ID)
  references TRANSACTIONS (TRANSACTION_ID);
alter table PURCHASES
  add constraint PURCHASES_MCCID_FK foreign key (MCC_ID)
  references DIC_MCC (MCC_ID);  
  
-- Create table
create table RETURNS
(
  return_id      NUMBER not null,
  return_date    DATE not null,
  amount         NUMBER(9,2) not null,
  card_id        NUMBER not null,
  transaction_id NUMBER not null,
  purchase_id    NUMBER not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table RETURNS
  is 'Данные об операциях возврата покупок';
-- Add comments to the columns 
comment on column RETURNS.return_date
  is 'Дата оп-ии возврат';
comment on column RETURNS.amount
  is 'Сумма к возврату';
comment on column RETURNS.card_id
  is 'Ид-р банковской карты';
comment on column RETURNS.transaction_id
  is 'Ид-р транзакции';
comment on column RETURNS.purchase_id
  is 'Ид-р покупки';
-- Create/Recreate primary, unique and foreign key constraints 
alter table RETURNS
  add constraint RETURNS_PK primary key (RETURN_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table RETURNS
  add constraint RETURNS_TRANSID_UK unique (TRANSACTION_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table RETURNS
  add constraint RETURNS_CARDS_FK foreign key (CARD_ID)
  references CARDS (CARD_ID);
alter table RETURNS
  add constraint RETURNS_PURCHASE_FK foreign key (PURCHASE_ID)
  references PURCHASES (PURCHASE_ID);
alter table RETURNS
  add constraint RETURNS_TRANS_FK foreign key (TRANSACTION_ID)
  references TRANSACTIONS (TRANSACTION_ID);  

-- Create table
create table EXCHANGE_TABLE
(
  row_id     NUMBER,
  field1     VARCHAR2(200),
  field2     VARCHAR2(200),
  field3     VARCHAR2(200),
  field4     VARCHAR2(200),
  field5     VARCHAR2(200),
  field6     VARCHAR2(200),
  field7     VARCHAR2(200),
  field8     VARCHAR2(2000),
  code_error VARCHAR2(200),
  text_error VARCHAR2(2000),
  file_id         number,
  transaction_id  number
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table EXCHANGE_TABLE
  is 'Таблица обмена для загрузки данных из файла';
-- Create/Recreate primary, unique and foreign key constraints 
alter table EXCHANGE_TABLE
  add constraint EXCHANGE_TABLE_PK primary key (ROW_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table EXCHANGE_TABLE
  add constraint EXCHANGE_TABLE_FILE_FK foreign key (file_id)
  references validated_files (file_id);
alter table EXCHANGE_TABLE
  add constraint EXCHANGE_TABLE_TR_FK foreign key (transaction_id)
  references TRANSACTIONS (transaction_id);  
  
-- indexes
create index purchases_card_idx on purchases(card_id);
create index returns_purchase_idx on returns(purchase_id);
create index cards_client_idx on cards(client_id);  


BEGIN
  dbms_scheduler.create_job(job_name            =>  'start_register',
                            job_type            => 'PLSQL_BLOCK',
                            job_action          => 'begin cashback.get_register; end;',
                            start_date          => to_date('20.08.2024 08:55:00','dd.mm.yyyy hh24:mi:ss'),
                            repeat_interval     => 'FREQ=MONTHLY;bymonthday=10;byhour=12;byminute=0;bysecond=0',
                            enabled             => TRUE,
                            auto_drop           => FALSE,
                            comments            => 'Job for starting proc get_register');  
END;                            
/
