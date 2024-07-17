-- created by Sergey Ermachkov

-- create directory for download files
create or replace directory files as 'C:\cashback_files\';

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

-- Create table
create table DIC_USER_TYPES
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
comment on table DIC_USER_TYPES
  is 'Справочник типов клиентов физ., юр.';
-- Add comments to the columns 
comment on column DIC_USER_TYPES.type_name
  is 'Наименование типа клиента';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_USER_TYPES
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
  references DIC_USER_TYPES (TYPE_ID);

-- Create table
create table INDIVIDUAL_PERSONS
(
  person_id    NUMBER not null,
  first_name   VARCHAR2(255) not null,
  last_name    VARCHAR2(255) not null,
  middle_name  VARCHAR2(255) not null,
  passport_sn  NUMBER(4) not null,
  passport_num NUMBER(6) not null
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
comment on column INDIVIDUAL_PERSONS.passport_sn
  is 'Серия паспорта';
comment on column INDIVIDUAL_PERSONS.passport_num
  is 'Номер паспорта';
-- Create/Recreate primary, unique and foreign key constraints 
alter table INDIVIDUAL_PERSONS
  add constraint INDIVID_PERSONS_PK primary key (PERSON_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table INDIVIDUAL_PERSONS
  add constraint INDIVID_PERSONS_UK unique (PASSPORT_SN, PASSPORT_NUM)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table INDIVIDUAL_PERSONS
  add constraint INDIVID_PERSONS_FK foreign key (PERSON_ID)
  references CLIENTS (CLIENT_ID);

-- Create table
create table DIC_MERCHANT_PROGRAMMS
(
  programm_id   NUMBER not null,
  programm_name VARCHAR2(255) not null,
  cashback_rate NUMBER(1,2) not null
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
comment on table DIC_MERCHANT_PROGRAMMS
  is 'Справочник партнёрских программ';
-- Add comments to the columns 
comment on column DIC_MERCHANT_PROGRAMMS.programm_name
  is 'Название программы';
comment on column DIC_MERCHANT_PROGRAMMS.cashback_rate
  is 'Процент кэшбэка';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DIC_MERCHANT_PROGRAMMS
  add constraint DIC_MERCH_PROG_PK primary key (PROGRAMM_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table DIC_MERCHANT_PROGRAMMS
  add constraint DIC_MERCH_PROG_UK unique (PROGRAMM_NAME)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create table
create table MERCHANTS
(
  merchant_id      NUMBER not null,
  merchant_name    VARCHAR2(255) not null,
  merchant_orig_id VARCHAR2(30) not null
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

-- Create table
create table MERCHANTS_PROGRAMMS
(
  mp_id       NUMBER not null,
  merchant_id NUMBER not null,
  programm_id NUMBER not null
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
comment on table MERCHANTS_PROGRAMMS
  is 'Связь программ и партнёров';
-- Add comments to the columns 
comment on column MERCHANTS_PROGRAMMS.merchant_id
  is 'Ид. партнёра';
comment on column MERCHANTS_PROGRAMMS.programm_id
  is 'Ид. программы';
-- Create/Recreate primary, unique and foreign key constraints 
alter table MERCHANTS_PROGRAMMS
  add constraint MERCHANT_PROG_PK primary key (MP_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MERCHANTS_PROGRAMMS
  add constraint MERCHANT_PROG_UK unique (MERCHANT_ID, PROGRAMM_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table MERCHANTS_PROGRAMMS
  add constraint MERCHANT_MERCH_FK foreign key (MERCHANT_ID)
  references MERCHANTS (MERCHANT_ID);
alter table MERCHANTS_PROGRAMMS
  add constraint MERCHANT_PROG_FK foreign key (PROGRAMM_ID)
  references DIC_MERCHANT_PROGRAMMS (PROGRAMM_ID);

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

-- Create table
create table RETURNS
(
  return_id      NUMBER not null,
  return_data    DATE not null,
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
comment on column RETURNS.return_data
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
create table TRANSACTIONS
(
  transaction_id      NUMBER not null,
  transaction_type    NUMBER not null,
  transaction_merc_id NUMBER(12) not null,
  merchant_id         NUMBER not null,
  mcc_id              NUMBER not null,
  description         VARCHAR2(2000)
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
comment on column TRANSACTIONS.transaction_merc_id
  is 'Идентификатор транзакции в системе мерчанта';
comment on column TRANSACTIONS.merchant_id
  is 'Ид-р мерчанта';
comment on column TRANSACTIONS.mcc_id
  is 'Ид-р MCC кода';
comment on column TRANSACTIONS.description
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
  add constraint TRANSACTIONS_MERCH_UK unique (TRANSACTION_MERC_ID, MERCHANT_ID)
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

-- Create table
create table EXCHANGE_TABLE
(
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
  row_id     NUMBER not null
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

-- Create table
create table PURCHASES
(
  purchase_id    NUMBER not null,
  card_id        NUMBER not null,
  purchase_data  DATE not null,
  amount         NUMBER(9,2) not null,
  transaction_id NUMBER not null
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
comment on column PURCHASES.purchase_data
  is 'Дата покупки';
comment on column PURCHASES.amount
  is 'Сумма покупки';
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
create table VERIFIED_FILES
(
  verified_id      NUMBER not null,
  merchant_file_id VARCHAR2(12) not null,
  result_file      BFILE not null,
  verified_data    DATE not null
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
comment on table VERIFIED_FILES
  is 'Данные об обработанных ранее файлах';
-- Add comments to the columns 
comment on column VERIFIED_FILES.merchant_file_id
  is 'Ид-р файла в системе мерчанта';
comment on column VERIFIED_FILES.result_file
  is 'Ссылка на файл с резульататми';
comment on column VERIFIED_FILES.verified_data
  is 'Дата обработки файла';
-- Create/Recreate primary, unique and foreign key constraints 
alter table VERIFIED_FILES
  add constraint VERIFIED_PK primary key (VERIFIED_ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;
alter table VERIFIED_FILES
  add constraint VERIFIED_MERCHID_UK unique (MERCHANT_FILE_ID)
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
