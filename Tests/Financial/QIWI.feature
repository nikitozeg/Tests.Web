@QIWI
Feature: QIWI
		Sending to QIWI

		@2814956
  Scenario Outline: Валидация Массовый перевод QIWI (без конвертации)

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "В Visa QIWI Wallet"
#STEP 1
	
	Then Section 'Amount including fees' is: 0 $ 0.00 (Комиссия: $ 0.00)
	Given User see limits table at WebMoney mass payment
		| Description | Min    | Max          | Fee |
		| USD         | $ 0.20 | $ 3 500.00   | 2%  |
		| EUR         | € 0.20 | € 3 500.00   | 2%  |
		| RUB         | ₽ 1.00 | ₽ 250 000.00 | 2%  |  
	Then Placeholder for 'Номер кошелька Qiwi' is '+'
	Given 'Отдаваемая сумма' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     |
    	| RUB     |   
	Given 'Получаемая сумма' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     |
    	| RUB     |   

#STEP 2
	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
	Then File "QIWI-wrong-Ewallet.csv" uploaded
	Then Alert Message "Строка 1: Кошелек не найден" appears
	Then File "QIWI-501.csv" uploaded
	Then Alert Message "Максимальное количество платежей не должно превышать 500 за один перевод" appears

#STEP 3
	Then 'Номер кошелька Qiwi' set to '<QIWI>'
	Then 'Отдаваемая сумма' selector set to 'USD'
	Then 'Отдаваемая сумма' set to '500'
	Given User clicks on "Добавить платеж" on Multiform
	Given User see VISA QIWI Wallet receivers table
		| Number | Recipient | OutgoingAmount | Fees    | IncomingAmount | Total    | Button  |
		| 1      | <QIWI>    | $ 500.00       | $ 10.00 | $ 500.00       | $ 510.00 | УДАЛИТЬ |

	Then 'Номер кошелька Qiwi' set to '<QIWI>'
	Then 'Отдаваемая сумма' selector set to 'RUB'
	Then Currency rate placeholder appears
	Then 'Отдаваемая сумма' set to '1000'
	Given User clicks on "Добавить платеж" on Multiform
	Given User see VISA QIWI Wallet receivers table
		| Number | Recipient | OutgoingAmount | Fees    | IncomingAmount      | Total      | Button  |
		| 1      | <QIWI>    | $ 500.00       | $ 10.00 | $ 500.00            | $ 510.00   | УДАЛИТЬ |
		| 2      | <QIWI>    | ₽ 1 000.00     | ₽ 20.00 | $ **amount * rate** | ₽ 1 020.00 | УДАЛИТЬ |  
	Then Section 'Amount including fees' is: 2 ₽ 1 020.00 + $ 510.00 (Комиссия: ₽ 20.00 + $ 10.00)

#STEP 4
	#Delete Recipient #1
	 Given User clicks on button "Удалить" in table
	 Given User see VISA QIWI Wallet receivers table
		| Number | Recipient | OutgoingAmount | Fees    | IncomingAmount      | Total      | Button  |
		| 1      | <QIWI>    | ₽ 1 000.00     | ₽ 20.00 | $ **amount * rate** | ₽ 1 020.00 | УДАЛИТЬ |  
	Then Section 'Amount including fees' is: 1 ₽ 1 020.00 (Комиссия: ₽ 20.00)

#STEP 5
	Given User clicks on "Добавить платеж" on Multiform
	Then Validating message 'Заполните поле' count is 3

	Given Set StartTime for DB search
#STEP 6
	Given User clicks on "Далее"
    Then User type SMS sent to:
		| OperationType | Recipient     | UserId   | IsUsed |
		| MassPayment   | +709890900054 | <UserId> | false  |  

#STEP 7
	Given User clicks on "Назад"
	Given User see VISA QIWI Wallet receivers table
		| Number | Recipient | OutgoingAmount | Fees    | IncomingAmount      | Total      | Button  |
		| 1      | <QIWI>    | ₽ 1 000.00     | ₽ 20.00 | $ **amount * rate** | ₽ 1 020.00 | УДАЛИТЬ |  
#STEP 8	
	Then EPA-6393
	Given Set StartTime for DB search
	Given User clicks on "Далее"
    Then User type SMS sent to:
		| OperationType | Recipient     | UserId   | IsUsed |
		| MassPayment   | +709890900054 | <UserId> | false  |  
	Given User clicks on "Оплатить"

	Then User gets message "Обработка платежей завершена" on Multiform
	Then User gets message "Выполнено 1 из 1" on Multiform
	Then User gets message "Отправлено платежей: 1" on Multiform
	Then User gets message "Не отправлено платежей: 0" on Multiform

  	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                       | Amount       |
		| **DD.MM.YY** | Комиссия за перевод в QIWI | - ₽ 20.00    |
		| **DD.MM.YY** | Перевод в QIWI             | - ₽ 1 000.00 |    
				
    Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToQiwiFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                       |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                       |
		| Заказ №      | **InvoiceId**                                                                                                                                                 |
		| Внешний ID   | **ExternalTransactionId**                                                                                                                                     |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                          |
		| Продукт      | e-Wallet <UserPurseId>                                                                                                                                        |
		| Получатель   | <QIWI>                                                                                                                                                        |
		| Сумма        | ₽ <Comission>                                                                                                                                                 |
		| Детали       | Commission for outgoing payment to Visa Qiwi Wallet <QIWI> from e-Wallet <UserPurseId>. Amount transferred to Qiwi: $**amount * rate**, Rate: ₽1 = $**rate**. |         
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToQiwi' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                        |
		| Транзакция № | **TPurseTransactionId**                                                                                                                        |
		| Заказ №      | **InvoiceId**                                                                                                                                  |
		| Внешний ID   | **ExternalTransactionId**                                                                                                                      |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                           |
		| Продукт      | e-Wallet <UserPurseId>                                                                                                                         |
		| Получатель   | <QIWI>                                                                                                                                         |
		| Сумма        | ₽ <Amount>                                                                                                                                     |
		| Детали       | Outgoing payment to Visa Qiwi Wallet <QIWI> from e-Wallet <UserPurseId>. Amount transferred to Qiwi: $**amount * rate**, Rate: ₽1 = $**rate**. |  
	

  Examples:
   | AmountComission | Comission | Amount   | QIWI         | User                      | UserId                               | Password | UserPurseId |
   | 1020.00         | 20.00     | 1 000.00 | 700000000000 | irentest76@qa.swiftcom.uk | 2EA47F03-143D-4F9F-9643-DA4A6E56B1EC | 123123Aaa | 000-952812  |   



@433735
 Scenario Outline: Массовый перевод QIWI
#  Тестовый пользователь: irentest76@qa.swiftcom.uk - 123123Aaa
# Тестовые кошельки Эмулятора Киви (ссылка на полную документацию: https://confluence.swiftcom.uk/pages/viewpage.action?pageId=17992653
# Кошелек	Ошибка	Описание
# 70000000015	13	ошибка повтори через минуту
# 70000000012	300	неизвестная ошибка
# 70000000013	150	ошибка авторизации
# 70000000014	339	ограничение по IP
# 70000000215	215	Вернет на запросе проведения платежа, что платеж уже существует
# 71000000215	Всегда вернет что транзакция существует на статус перевода	
# 70000000017	Вернет на статус что транзакция пендинг, на след.запрос вернет что нет такой транзакции

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "В Visa QIWI Wallet"
	Then Section 'Amount including fees' is: 0 $ 0.00 (Комиссия: $ 0.00)

	#STEP 3
	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
	Then File "QIWI-3.csv" uploaded
	Given User see VISA QIWI Wallet receivers table
		| Number | Recipient    | OutgoingAmount | Fees   | IncomingAmount | Total   | Button  |
		| 1      | 700000000001 | $ 3.00         | $ 0.06 | $ 3.00         | $ 3.06  | УДАЛИТЬ |
		| 2      | 700000000001 | € 10.00        | € 0.20 | € 10.00        | € 10.20 | УДАЛИТЬ |  

	Then Section 'Amount including fees' is: 2 € 10.20 + $ 3.06 (Комиссия: € 0.20 + $ 0.06)
	
	Then 'Номер кошелька Qiwi' set to '<QIWI>'
	Then 'Отдаваемая сумма' selector set to 'RUB'
	Then Currency rate placeholder appears
	Then 'Отдаваемая сумма' set to '1000'
	Given User clicks on "Добавить платеж" on Multiform
	Given User see VISA QIWI Wallet receivers table
		| Number | Recipient    | OutgoingAmount | Fees    | IncomingAmount      | Total      | Button  |
		| 1      | 700000000001 | $ 3.00         | $ 0.06  | $ 3.00              | $ 3.06     | УДАЛИТЬ |
		| 2      | 700000000001 | € 10.00        | € 0.20  | € 10.00             | € 10.20    | УДАЛИТЬ |
		| 3      | <QIWI>       | ₽ 1 000.00     | ₽ 20.00 | $ **amount * rate** | ₽ 1 020.00 | УДАЛИТЬ |  

	Given Set StartTime for DB search
#STEP 4
	Given User clicks on "Далее"
	Then User type SMS sent to:
		| OperationType | Recipient     | UserId   | IsUsed |
		| MassPayment   | +709890900054 | <UserId> | false  |  
#STEP 5
	Given User clicks on "Оплатить"

	Then User gets message "Обработка платежей завершена" on Multiform
	Then User gets message "Выполнено 3 из 3" on Multiform
	Then User gets message "Отправлено платежей: 3" on Multiform
	Then User gets message "Не отправлено платежей: 0" on Multiform

#STEP 6
	#2.3.11 https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.3.%D0%92%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D0%B8%D0%B5%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%BD%D1%8B%D0%B5%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B
	 ##############################_Transactions_################################################
	Given Check 1 of 3 transaction for last BatchOperationGuid where UserId="<UserId>" and ReceiverIdentity="700000000000"
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 135             | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <UserPurseId>  | Qiwi             | <QIWI>           | Rub        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId             | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | OutgoingTransferToQiwi    | out       | <UserId>            | Rub        | <PurseId>                     | 0           |
	  | <Amount>          | OutgoingTransferToQiwi    | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | OutgoingTransferToQiwiFee | out       | <UserId>            | Rub        | <PurseId>                     | 0           |
	  | <Comission>       | OutgoingTransferToQiwiFee | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur | in        | <SystemPurseUserId> | Rub        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur | out       | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | OutgoingTransferToQiwi    | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | OutgoingTransferToQiwiFee | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | OutgoingTransferToQiwiFee | in        | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination            | UserId   | Amount            | AmountInUsd   | Product       | ProductType |
	  | Usd        | out       | OutgoingTransferToQiwi | <UserId> | **amount * rate** | **Generated** | <UserPurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **amount * rate** | Usd        | Qiwi              | false                 |  

	   ##############################_Transactions_################################################

 #STEP 7   
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
    | MessageType | Priority | Receiver                                                                                                                                                 | Title             |
    | Sms         | 13       | +709890900054                                                                                                                                                   | -                 |
    | Email       | 6        | irentest76@qa.swiftcom.uk                                                                                                                                | Отчет по операции |
    | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7D | -                 |
    | PushIos     | 6        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e1                                                                                         | -                 |  


  Examples:
   | AmountComission | Comission | Amount  | QIWI         | User                      | UserId                               | EPSUserId                            | SystemPurseUserId                    | Password | UserPurseId | PurseId | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions |
   | 1020.00         | 20.00     | 1000.00 | 700000000000 | irentest76@qa.swiftcom.uk | 2EA47F03-143D-4F9F-9643-DA4A6E56B1EC | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 123123Aaa | 000-952812  | 952812  | 144177                      | 122122          | 406604            |  

