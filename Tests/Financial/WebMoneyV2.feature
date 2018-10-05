@WebMoney
Feature: WebMoney

	     
 Scenario Outline: Массовый перевод WebMoney
 	
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	Given User clicks on "В WebMoney"

	Then Section 'Amount including fees' is: 0 $ 0.00 (Комиссия: $ 0.00)
	Given User see limits table at WebMoney mass payment
		| Description                | Min       | Max          | Fee       |
		| USD                        | $ 0.20    | $ 50 000.00  | 2%        |
		| EUR                        | € 0.20    | € 50 000.00  | 2%        |
	Then Placeholder for 'Номер кошелька WebMoney' is 'Z000000000000'
	Given 'Отдаваемая сумма' selector is "USD" and contains:
    	| Options |
    	| USD |
    	| EUR |
    	| RUB | 
	Given 'Получаемая сумма' selector is "USD" and contains:
    	| Options |
    	| USD |
    	| EUR |

#Field validation block

	Given User clicks on "Добавить платеж"
	Then Validating message 'Заполните поле' count is 4
	
	Then 'Номер кошелька WebMoney' set to 'кириллица'
	Then 'Отдаваемая сумма' set to 'кириллица'
	Then 'Получаемая сумма' set to 'кириллица'
	Then 'Детали (обязательно)' details set to 'кириллица'

	Then 'Номер кошелька WebMoney' value is ''
	Then 'Отдаваемая сумма' value is ''
	Then 'Получаемая сумма' value is ''
	Then Validating message 'Были введены недопустимые символы' count is 1

	Then 'Отдаваемая сумма' set to '0.1'
	Then Validating message 'Сумма перевода меньше' appears on MultiForm
	Then Validating message '$ 0.20' appears on MultiForm
	Then 'Отдаваемая сумма' set to '1000000000' and unfocus
    Then Validating message 'Сумма с комиссией превышает баланс' appears on MultiForm
    Then Validating message 'Сумма перевода больше' appears on MultiForm
    Then Validating message '$ 50 000.00' appears on MultiForm

#Upload CSV file	
 	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
	Then File "Sample_file_for_mass_payment_webmoney_negative.csv" uploaded
	Then Alert Message "Строка 1: Система отправителя указана неверно" appears
  	Then File "<UploadFile>" uploaded
	Given User see WM receivers table
		| Number | Recipient     | OutgoingAmount | Fees    | IncomingAmount | Total      | Button  |
		| 1      | Z000000000003 | $ 1 000.00     | $ 20.00 | $ 1 000.00     | $ 1 020.00 | УДАЛИТЬ |
		| 2      | E000000000003 | € 100.00       | € 2.00  | € 100.00       | € 102.00   | УДАЛИТЬ |        
	Then Section 'Amount including fees' is: 2 € 102.00 + $ 1 020.00 (Комиссия: € 2.00 + $ 20.00)

#Delete Recipient #1
	Given User clicks on button "Удалить" in table
	Given User see WM receivers table
		| Number | Recipient     | OutgoingAmount | Fees    | IncomingAmount | Total        | Button  |
		| 1      | E000000000003 | € 100.00       | € 2.00  | € 100.00       | € 102.00     | УДАЛИТЬ |
	Then Section 'Amount including fees' is: 1 € 102.00 (Комиссия: € 2.00)

#Upload CSV file again	
	Then File "<UploadFile>" uploaded
	Then Section 'Amount including fees' is: 2 € 102.00 + $ 1 020.00 (Комиссия: € 2.00 + $ 20.00)

	Given User see WM receivers table
		| Number | Recipient     | OutgoingAmount | Fees    | IncomingAmount | Total      | Button  |
		| 1      | Z000000000003 | $ 1 000.00     | $ 20.00 | $ 1 000.00     | $ 1 020.00 | УДАЛИТЬ |
		| 2      | E000000000003 | € 100.00       | € 2.00  | € 100.00       | € 102.00   | УДАЛИТЬ |  
		
#ADD recipient  manually
	Then 'Номер кошелька WebMoney' set to '000000000003'
	Then 'Отдаваемая сумма' selector set to 'RUB'
	Then Currency rate placeholder appears
	Then 'Отдаваемая сумма' set to '100'
	Then 'Детали (обязательно)' details set to 'asd'
	Given User clicks on "Добавить платеж" on Multiform
	Given User see WM receivers table
		| Number | Recipient     | OutgoingAmount | Fees    | IncomingAmount      | Total      | Button  |
		| 1      | Z000000000003 | $ 1 000.00     | $ 20.00 | $ 1 000.00          | $ 1 020.00 | УДАЛИТЬ |
		| 2      | E000000000003 | € 100.00       | € 2.00  | € 100.00            | € 102.00   | УДАЛИТЬ |
		| 3      | Z000000000003 | ₽ 100.00       | ₽ 2.00  | $ **amount * rate** | ₽ 102.00   | УДАЛИТЬ |  
	Then Section 'Amount including fees' is: 3 € 102.00 + ₽ 102.00 + $ 1 020.00 (Комиссия: € 2.00 + ₽ 2.00 + $ 20.00)

	Given Set StartTime for DB search
	Given User clicks on "Далее"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Given Set StartTime for DB search
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
	Then Wait for transactions loading
	
    Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                           | Amount       |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - $ 20.00    |
		| **DD.MM.YY** | Перевод в Webmoney             | - $ 1 000.00 |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - € 2.00     |
		| **DD.MM.YY** | Перевод в Webmoney             | - € 100.00   |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - ₽ 2.00     |
		| **DD.MM.YY** | Перевод в Webmoney             | - ₽ 100.00   |  
   Then Operator gets first record in WebMoney MassPayments contains '<UserId> Completed 3/3'

   	 ##############################_Transactions_################################################
	Given Check 1 of 3 transaction for last BatchOperationGuid where UserId="<UserId>" and ReceiverIdentity="E000000000003"
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount    | Fee         |
	  | 108             | 100.00    | <Comission> |  

#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details              | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed | Agreement no.3. <Id> | WaveCrest      | 001-<UserPurseId> | WebMoney         | E000000000003    | Eur        | EWallet       | Purse                | <UserId> |  
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount      | DestinationId                 | Direction | UserId      | CurrencyId | PurseId        | RefundCount |
	  | 100.00      | OutgoingTransferToWebmoney    | out       | <UserId>    | Eur        | 1<UserPurseId> | 0           |
	  | 100.00      | OutgoingTransferToWebmoney    | in        | <EPSUserId> | Eur        | 144177         | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <UserId>    | Eur        | 1<UserPurseId> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId> | Eur        | 144177         | 0           |
	  | 100.00      | OutgoingTransferToWebmoney    | out       | <EPSUserId> | Eur        | 144177         | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <EPSUserId> | Eur        | 144177         | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId> | Eur        | 406604         | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                | UserId   | Amount | AmountInUsd   | Product           | ProductType |
	  | Eur        | out       | OutgoingTransferToWebmoney | <UserId> | 100.00 | **Generated** | 001-<UserPurseId> | Epid        |  
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 100.00   | Eur        | WebMoney          | false                 |  
	   ##############################_Transactions_################################################
    
	Then User selects records in table 'Notification' for UserId="<UserId>"
      | MessageType | Priority | Receiver                                                                                                                                                 | Title             |
      | Email       | 6        | <Email>                                                                                                                                                  | Отчет по операции |
      | PushAndroid | 6        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                 |
      | PushIos     | 6        | 44a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                 |  

@135424
  Examples:
     | Id               | UploadFile                                | paymentCodePhone | PaymentWay       | Email                                              | UserPurseId | User         | UserId                               | Password     | Comission | EPSUserId                            |
     | 3495573506653703 | Sample_file_for_mass_payment_webmoney.csv | 123455           | payment password | 808d2f4a46bf88413a76f15166.autotest@qa.swiftcom.uk | 060774      | +70073201807 | 9BF2CBBA-3F00-49FD-A359-6A80D7CDC05D | 72621010Abac | 2.00      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  




 @2866613
 Scenario Outline: Перевод в WebMoney v.2 физ.лицо (валидация, без конвертации)

 #Step 1	
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	Given User clicks on "На кошелек WebMoney"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

 #Step 1	
 #в Информ блоке подтянулись лимиты и комиссии из тарифа
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | $ 0.10       |
		| Максимальная сумма перевода: | $ 2 000.00   |
		| Максимальная дневная сумма:  | $ 20 000.00  |
		| Максимальная месячная сумма: | $ 100 000.00 |
		| Комиссия:                    | 2%           |  

	Then Placeholder for 'Номер кошелька WebMoney' is 'Z000000000000'
	
 #Step 1	
 #Со счета - по умолчанию-USD секция кошелька
	Given 'Со счета' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     | 
    	| RUB     | 

	Given 'Получаемая сумма' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     |  

#Step 2
#валюта суммы с комиссией
	Then 'Со счета' selector set to 'EUR'
	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)

#Step 2
#валюта лимитов на макси/миним суммы равна получаемой сумме. Остальные лимиты остались USD
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | € 0.10       |
		| Максимальная сумма перевода: | € 20 000.00  |
		| Максимальная дневная сумма:  | $ 20 000.00  |
		| Максимальная месячная сумма: | $ 100 000.00 |
		| Комиссия:                    | 2%           |  

#Step 2
#номер кошелька (буква=валюте секции)
	Then Placeholder for 'Номер кошелька WebMoney' is 'E000000000000'

#Step 2 
#валюта отдаваемой суммы
	Then Currency for 'Отдаваемая сумма' is '€'

#Step 2 
#валюта Получаемой суммы
	Given 'Получаемая сумма' selector is "EUR" and contains:
    	| Options |
    	| USD     |
    	| EUR     |  

#Step 3
	Then 'Номер кошелька WebMoney' set to '<WMReceiver>'
	Then 'Детали (обязательно)' details set to '<WMDetails>'
	
	Then 'Получаемая сумма' set to '100'
	Then Section 'Amount including fees' is: € 102.00 (Комиссия: € <Comission>)
	Given User clicks on "Далее"

	Given User see table
		| Column1                 | Column2                         |
		| Отправитель             | EUR, e-Wallet 001-<UserPurseId> |
		| Номер кошелька WebMoney | <WMReceiver>                    |
		| Отдаваемая сумма        | € 100.00                        |
		| Комиссия                | € <Comission>                   |
		| Сумма с комиссией       | € 102.00                        |
		| Получаемая сумма        | € 100.00                        |
		| Детали                  | <WMDetails>                     |  

#Step 4
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"

    Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70045238953 | <UserId> | false  |  
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
	Then Wait for transactions loading
	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

#Step 5
    Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                           | Amount          |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - € <Comission> |
		| **DD.MM.YY** | Перевод в Webmoney             | - € 100.00      |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                         |
		| Транзакция № | **TPurseTransactionId**                                                                                         |
		| Заказ №      | **InvoiceId**                                                                                                   |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                            |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                      |
		| Получатель   | <WMReceiver>                                                                                                    |
		| Сумма        | € <Comission>                                                                                                   |
		| Детали       | Commission for outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMDetails>. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoney' row № 1 direction='out':
		| Column1      | Column2                                                                                          |
		| Транзакция № | **TPurseTransactionId**                                                                          |
		| Заказ №      | **InvoiceId**                                                                                    |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                             |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                       |
		| Получатель   | <WMReceiver>                                                                                     |
		| Сумма        | € 100.00                                                                                         |
		| Детали       | Outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMDetails>. |    

	Then Wait Webmoney invoice successed

    Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | +70045238953                                                                                                                                                   | -                              |
     | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 81954f64ce084e09330cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                              |  

#Step 6 , 7 - not implemented yet because of https://jira.swiftcom.uk/browse/SD-3045
 
 Examples:
     | WMReceiver    | UserPurseId | User                               | UserId                               | Password     | Comission | EPSUserId                            | EPS-02TemporaryStoragePurse | SystemPurseUserId                    | EPS-06Exchanges | EPS-01Commissions | WMDetails             |
     | E000000000003 | 198632      | webmoneyUIsendByFiz@qa.swiftcom.uk | 5da1dc55-198c-4ad3-b4fc-c9917efab251 | 72621010Abac | 2.00      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 144177                      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 122122          | 406604            | .,&-' №#()[]%$€@!»«\/ |  



 @615888
 Scenario Outline: Перевод в WebMoney v.2 физ.лицо (конвертация, комиссия)
 
 #STEP 1	
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	Given User clicks on "На кошелек WebMoney"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | $ 0.10       |
		| Максимальная сумма перевода: | $ 2 000.00   |
		| Максимальная дневная сумма:  | $ 20 000.00  |
		| Максимальная месячная сумма: | $ 100 000.00 |
		| Комиссия:                    | 2%           |  

 #STEP 2
	Then 'Получаемая сумма' selector set to 'EUR'
	Then 'Номер кошелька WebMoney' set to '000000000003'
	Then 'Отдаваемая сумма' set to '100'
	Then Currency rate placeholder appears
	Then 'Детали (обязательно)' details set to '<WMdetails>'
	Then 'Получаемая сумма' value is '100.00' multiplied by rate

	Then Section 'Amount including fees' is: $ 102.00 (Комиссия: $ <Comission>)
	Given User clicks on "Далее"

	Given User see table
		| Column1                 | Column2                         |
		| Отправитель             | USD, e-Wallet 001-<UserPurseId> |
		| Номер кошелька WebMoney | <WMReceiver>                    |
		| Отдаваемая сумма        | $ 100.00                        |
		| Комиссия                | $ <Comission>                   |
		| Сумма с комиссией       | $ 102.00                        |
		| Курс обмена             | $ 1.00 = € **rateWM**           |
		| Получаемая сумма        | € **amount * rate**             |
		| Детали                  | <WMdetails>                     |  

#STEP 3
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"
 	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70045238953 | <UserId> | false  |  

#STEP 4
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
	Then Wait for transactions loading
	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

#STEP 5
    Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                           | Amount          |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - $ <Comission> |
		| **DD.MM.YY** | Перевод в Webmoney             | - $ 100.00      |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                   |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                   |
		| Заказ №      | **InvoiceId**                                                                                                                                                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                      |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                                                                                                |
		| Получатель   | <WMReceiver>                                                                                                                                                                              |
		| Сумма        | $ <Comission>                                                                                                                                                                             |
		| Детали       | Commission for outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. Amount transferred to WebMoney: €**amount * rate**, Rate: $1 = €**rate**. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoney' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                    |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                    |
		| Заказ №      | **InvoiceId**                                                                                                                                                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                       |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                                                                                 |
		| Получатель   | <WMReceiver>                                                                                                                                                               |
		| Сумма        | $ 100.00                                                                                                                                                                   |
		| Детали       | Outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. Amount transferred to WebMoney: €**amount * rate**, Rate: $1 = €**rate**. |   

		Then Wait Webmoney invoice successed

#STEP 6
#https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.3.%D0%92%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D0%B8%D0%B5%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%BD%D1%8B%D0%B5%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B
   	 
	 ##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount    | Fee         |
	  | 107             | 100.00    | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details     | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed | <WMdetails> | WaveCrest      | 001-<UserPurseId> | WebMoney         | <WMReceiver>     | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount      | DestinationId                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | 100.00      | OutgoingTransferToWebmoney    | out       | <UserId>            | Usd        | 1<UserPurseId>                | 0           |
	  | 100.00      | OutgoingTransferToWebmoney    | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <UserId>            | Usd        | 1<UserPurseId>                | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | 100.00      | CurrencyExchangeUsdAndEur     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | 100.00      | CurrencyExchangeUsdAndEur     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount**  | CurrencyExchangeUsdAndEur     | out       | <SystemPurseUserId> | Eur        | <EPS-06Exchanges>             | 0           |
	  | **amount**  | CurrencyExchangeUsdAndEur     | in        | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount**  | OutgoingTransferToWebmoney    | out       | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                | UserId   | Amount            | AmountInUsd   | Product           | ProductType |
	  | Eur        | out       | OutgoingTransferToWebmoney | <UserId> | **amount / rate** | **Generated** | 001-<UserPurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **amount / rate** | Eur        | WebMoney          | false                 |   

	   ##############################_Transactions_################################################

#STEP 7
   Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | +70045238953                                                                                                                                             | -                              |
     | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 81954f64ce084e09330cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                              |  

  Examples:
     | WMReceiver    | UserPurseId | User                               | UserId                               | Password     | Comission | EPSUserId                            | EPS-02TemporaryStoragePurse | SystemPurseUserId                    | EPS-06Exchanges | EPS-01Commissions | WMdetails   |
     | E000000000003 | 198632      | webmoneyUIsendByFiz@qa.swiftcom.uk | 5da1dc55-198c-4ad3-b4fc-c9917efab251 | 72621010Abac | 2.00      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 144177                      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 122122          | 406604            | WMdetails |  



	 @615889
	 @After_delete_payment_templates
 Scenario Outline: Шаблон: перевод в WM v.2 по новому шаблону
 
# STEP 1	  
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	
	Given User clicks on "На кошелек WebMoney"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Получаемая сумма' selector set to 'EUR'
	Then 'Номер кошелька WebMoney' set to '000000000003'
	Then 'Отдаваемая сумма' set to '100'
	Then Currency rate placeholder appears
	Then 'Получаемая сумма' value is '100.00' multiplied by rate
	
	Then 'Детали (обязательно)' details set to '<WMdetails>'
	
	Then Section 'Amount including fees' is: $ 102.00 (Комиссия: $ <Comission>)
	Given User clicks on "Далее"
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"

  	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70045238953 | <UserId> | false  |  
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
	Then Wait Webmoney invoice successed
	
	Then Wait for transactions loading
	Given User clicks on "Создать шаблон"

# STEP 2
	Then 'Название шаблона' set to '????'
	Given User clicks on "Сохранить"
	Then Validating message 'Были введены недопустимые символы' count is 1

	Then 'Название шаблона' set to 'ШаблонВМ'
	Given User clicks on "Сохранить"
	Then User gets message "Шаблон успешно сохранен" on Multiform
	Given User closes multiform by clicking on "Закрыть"

	Given User clicks on Перевести menu
	Given User clicks on "Показать все"

# STEP 3	
     Given User clicks on edit
	 Given User sets new template name "Новый шаблон"
	 Given User clicks on save
 	Then Alert Message "Шаблон успешно изменен" appears
	Given User clicks on "Закрыть"

# STEP 4
	Given User clicks on "Новый шаблон"

# STEP 5
	Then Currency rate placeholder appears
	Then Section 'Amount including fees' is $ **Amount with fee** (Комиссия: $ **Fee**) multiplied by rate with fee 2%

	Then 'Со счета' selector is 'USD' and disabled

	Then 'Номер кошелька WebMoney' value is 'E000000000003' and disabled
	
	Then 'Получаемая сумма' selector is 'EUR' and disabled

	Then 'Получаемая сумма' value should be the same when template was saved

# STEP 6
	Then 'Детали (обязательно)' details set to '<WMdetails>'

	Given User clicks on "Далее"

	Given User see table
		| Column1                 | Column2                         |
		| Отправитель             | USD, e-Wallet 001-<UserPurseId> |
		| Номер кошелька WebMoney | <WMReceiver>                    |
		| Отдаваемая сумма        | $ **OutgoingAmount**            |
		| Комиссия                | $ 2.00                       |
		| Сумма с комиссией       | $ **amount + fee**              |
		| Курс обмена             | $ 1.00 = € **rateWM**           |
		| Получаемая сумма        | € **amount * rate**             |
		| Детали                  | <WMdetails>                     |   

	Given User clicks on "Подтвердить"
	Given Set StartTime for DB search
    Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70045238953 | <UserId> | false  |
	Given User clicks on "Оплатить"

	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
    Given Button "Создать шаблон" is not exist

	Given User closes multiform by clicking on "Закрыть"

	Then Redirected to /#/transfer/

    Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                           | Amount                 |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - $ **fee**            |
		| **DD.MM.YY** | Перевод в Webmoney             | - $ **OutgoingAmount** |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                   |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                   |
		| Заказ №      | **InvoiceId**                                                                                                                                                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                      |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                                                                                                |
		| Получатель   | <WMReceiver>                                                                                                                                                                              |
		| Сумма        | $ <Comission>                                                                                                                                                                             |
		| Детали       | Commission for outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. Amount transferred to WebMoney: €**amount * rate**, Rate: $1 = €**rate**. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoney' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                    |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                    |
		| Заказ №      | **InvoiceId**                                                                                                                                                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                       |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                                                                                 |
		| Получатель   | <WMReceiver>                                                                                                                                                               |
		| Сумма        | $ 100.00                                                                                                                                                                   |
		| Детали       | Outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. Amount transferred to WebMoney: €**amount * rate**, Rate: $1 = €**rate**. |  

	Then Wait Webmoney invoice successed

# STEP 7		  
   Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
		 | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
		 | Sms         | 13       | +70045238953                                                                                                                                             | -                              |
		 | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice** |
		 | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
		 | PushIos     | 6        | 81954f64ce084e09330cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                              |  

	Then User selects records in table 'MassPaymentTemplates' for UserId="<UserId>":
		  | Name         | LastPaymentDate | PaymentsCount | ProviderName | UserId   |
		  | Новый шаблон | **now**         | 1             | webmoney     | <UserId> |  

  Examples:
     | WMReceiver    | UserPurseId | User                               | UserId                               | Password     | Comission | EPSUserId                            | WMdetails |
     | E000000000003 | 198632      | webmoneyUIsendByFiz@qa.swiftcom.uk | 5da1dc55-198c-4ad3-b4fc-c9917efab251 | 72621010Abac | 2.00      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | WMdetails |  



	 @2882471
 Scenario Outline: Шаблон: перевод в WM v.2 по старому шаблону v1

	Given Reset PaymentsCount in table 'MassPaymentTemplates' where TemplateId="299"

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	Given User clicks on "Шаблон вм в 1"
	
	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)

# со счета,номер кошелька ВМ - серые, неизменяемые
	Then 'Со счета' selector is 'EUR' and disabled

	Then 'Номер кошелька WebMoney' value is '<WMReceiver>' and disabled

# получаемая сумма - валюта не изменяемая
	Then 'Получаемая сумма' selector is 'EUR' and disabled

#в полях отдаваемая,получаемая сумма НЕ отображается сумма перевода
	Then 'Отдаваемая сумма' value is ''
	Then 'Получаемая сумма' value is ''

	Then 'Отдаваемая сумма' set to '100'

	Then 'Детали (обязательно)' details set to '<WMdetails>'

	Given User clicks on "Далее"

	Given User see table
		| Column1                 | Column2                         |
		| Отправитель             | EUR, e-Wallet 001-<UserPurseId> |
		| Номер кошелька WebMoney | <WMReceiver>                    |
		| Отдаваемая сумма        | € **OutgoingAmount**            |
		| Комиссия                | € <Comission>                   |
		| Сумма с комиссией       | € 102.00                        |
		| Получаемая сумма        | € **OutgoingAmount**            |
		| Детали                  | <WMdetails>                     |  
	Given Set StartTime for DB search
	
	Given User clicks on "Подтвердить"

	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70092210139 | <UserId> | false  |
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж принят в обработку. Его выполнение займет несколько минут, после чего вы получите уведомление по e-mail о результатах" on Multiform
	
	Given User closes multiform by clicking on "Закрыть"

#Проверить уведомления,транзакции,инвойс
	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                           | Amount                 |
		| **DD.MM.YY** | Комиссия за перевод в Webmoney | - € <Comission>        |
		| **DD.MM.YY** | Перевод в Webmoney             | - € **OutgoingAmount** |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                         |
		| Транзакция № | **TPurseTransactionId**                                                                                         |
		| Заказ №      | **InvoiceId**                                                                                                   |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                            |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                                      |
		| Получатель   | <WMReceiver>                                                                                                    |
		| Сумма        | € <Comission>                                                                                                   |
		| Детали       | Commission for outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToWebmoney' row № 1 direction='out':
		| Column1      | Column2                                                                                          |
		| Транзакция № | **TPurseTransactionId**                                                                          |
		| Заказ №      | **InvoiceId**                                                                                    |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                             |
		| Продукт      | e-Wallet 001-<UserPurseId>                                                                       |
		| Получатель   | <WMReceiver>                                                                                     |
		| Сумма        | € 100.00                                                                                         |
		| Детали       | Outgoing payment to WebMoney <WMReceiver> from e-Wallet 001-<UserPurseId>. Details: <WMdetails>. |  

	Then Wait Webmoney invoice successed

#В таблице в [PaymentTemplates] проверить,что обновился счетчик
#LastPaymentDate = null Дата последней операции по шаблону-обновился 

	Then User selects records in table 'MassPaymentTemplates' for UserId="<UserId>":
		| Name          | LastPaymentDate | PaymentsCount | ProviderName | UserId   |
		| Шаблон вм в 1 | **now**         | 1             | webmoney     | <UserId> |  
			
	 ##############################_Transactions_################################################

	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount    | Fee         |
	  | 108             | 100.00    | <Comission> |  

#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details     | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed | <WMdetails> | WaveCrest      | 001-<UserPurseId> | WebMoney         | <WMReceiver>     | Eur        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount      | DestinationId                 | Direction | UserId      | CurrencyId | PurseId                       | RefundCount |
	  | 100.00      | OutgoingTransferToWebmoney    | out       | <UserId>    | Eur        | 1<UserPurseId>                | 0           |
	  | 100.00      | OutgoingTransferToWebmoney    | in        | <EPSUserId> | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <UserId>    | Eur        | 1<UserPurseId>                | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId> | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | 100.00      | OutgoingTransferToWebmoney    | out       | <EPSUserId> | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | out       | <EPSUserId> | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission> | OutgoingTransferToWebmoneyFee | in        | <EPSUserId> | Eur        | <EPS-01Commissions>           | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                | UserId   | Amount            | AmountInUsd   | Product           | ProductType |
	  | Eur        | out       | OutgoingTransferToWebmoney | <UserId> | 100.00            | **Generated** | 001-<UserPurseId> | Epid        |  
   
   Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 100.00 | Eur        | WebMoney          | false                 |  

	   ##############################_Transactions_################################################


   Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | +70092210139                                                                                                                                             | -                              |
     | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                              |  


  Examples:
     | WMReceiver    | UserPurseId | User                              | UserId                               | Password     | Comission | WMdetails | EPSUserId                            | EPS-02TemporaryStoragePurse | EPS-01Commissions |
     | E111111111111 | 507115      | wm_v1_old_template@qa.swiftcom.uk | d4228d1d-ea1a-4b0d-9184-eaf4c3ee55fe | 72621010Abac | 2.00      | WMdetails | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 144177                      | 406604            |



	  @3393746
 Scenario Outline: Перевод На свой кошелек WebMoney

 #Step 1	
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Перевести menu
	Given User clicks on "На свой кошелек WebMoney"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия обменного сервиса $ 0.00)

 #в Информ блоке подтянулись лимиты и комиссии из тарифа
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | $ 1.00       |
		| Максимальная сумма перевода: | $ 50 000.00   |

	Then Placeholder for 'Номер кошелька WebMoney' is 'Z000000000000'
	
 #Со счета - по умолчанию-USD секция кошелька
	Given 'Со счета' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     | 


#валюта суммы с комиссией
	Then 'Со счета' selector set to 'EUR'
	Then Section 'Amount including fees' is: € 0.00 (Комиссия обменного сервиса € 0.00)

#валюта лимитов на макси/миним суммы равна получаемой сумме. Остальные лимиты остались USD
	Given User see limits table
			| Column1                      | Column2     |
			| Минимальная сумма перевода:  | € 1.00      |
			| Максимальная сумма перевода: | € 50 000.00 |  
#номер кошелька (буква=валюте секции)
	Then Placeholder for 'Номер кошелька WebMoney' is 'E000000000000'

#Step 3
	Then 'Номер кошелька WebMoney' set to '<WMReceiver>'
	Then 'Сумма' set to '10'
	Then Section 'Amount including fees' is: € 21.00 (Комиссия обменного сервиса € 11.00)
	Given User clicks on "Далее"

	Given User see table
		| Column1                 | Column2                         |
		| Отправитель             | EUR, e-Wallet 000-<UserPurseId> |
		| Номер кошелька WebMoney | <WMReceiver>                    |
		| Сумма					  | € 10.00                        |
		| Комиссия                | € <Comission>                   |
		| Сумма с комиссией       | € 21.00                         |

#Step 4
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"

    Then User type PushCode sent to:
		| OperationType           | Recipient   | UserId   | IsUsed |
		| PaymentOperationConfirm | +0032103100 | <UserId> | false  |    

	Given User clicks on "Перевести"

	Then Success message "Платеж успешно выполнен×" appears
	Then Make screenshot

#https://jira.swiftcom.uk/browse/EPA-6945
#	Given User see quittance table for the UserId=<UserId> where DestinationId='EpaymentsToWebmoney'
#		| Column1           | Column2                 |
#		| Транзакция №      | **TPurseTransactionId** |
#		| Операция          | Перевод на кошелек WebMoney     |
#		| Дата              | **yyyy-MM-dd HH:mm**    |
#		| Статус            | Успешно                 |
#		| Отправитель       | USD, e-Wallet 000-<UserPurseId> |
#	| Номер кошелька WebMoney | <WMReceiver>                    |
#		| Сумма             | € <Amount>                |
#		| Комиссия          | € <Comission>                 |
#		| Сумма с комиссией | € 21.00                 |
	Given User clicks on "Создать шаблон"

	Then 'Название шаблона' set to 'ШаблонВМ'
	Given User clicks on "Сохранить"
	Then User gets message "Шаблон успешно сохранен" on Multiform
	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

#Step 5
    Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                        | Amount    |
		| **DD.MM.YY** | Перевод на кошелек WebMoney | - € 21.00 |    
	
	Given User see statement info for the UserId=<UserId> where DestinationId='EpaymentsToWebmoney' row № 0 direction='out':
		| Column1      | Column2                                                           |
		| Транзакция № | **TPurseTransactionId**                                           |
		| Заказ №      | **InvoiceId**                                                     |
		| Дата         | **dd.MM.yyyy HH:mm**                                              |
		| Продукт      | e-Wallet 000-<UserPurseId>                                        |
		| Получатель   | <WMReceiver>                                                      |
		| Сумма        | € 21.00                                                           |
		| Детали       | Transfer to WebMoney <WMReceiver> from e-Wallet 000-<UserPurseId> |  


  	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 81              | 21.00  | 0.00 |  
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	 | State     | Details      | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	 | Successed | <WMReceiver> | WaveCrest      | 000-<UserPurseId> | HotExchange      | <WMReceiver>     | Eur        | Webmoney      | NotRecognized        | <UserId> |  

	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount | DestinationId       | Direction | UserId                               | CurrencyId | PurseId       | RefundCount |
   	  | 21.00  | EpaymentsToWebmoney | out       | <UserId>                             | Eur        | <UserPurseId> | 0           |
   	  | 21.00  | EpaymentsToWebmoney | in        | 0B7C952E-0FD3-4FAB-BCAB-4185A77C4222 | Eur        | 818062        | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                     | UserId   | Amount | AmountInUsd   | Product           | ProductType |
	  | Eur        | out       | ExchangeFromEpaymentsToWebmoney | <UserId> | 21.00  | **Generated** | 000-<UserPurseId> | Epid        |  

	#QAA-550 (details is not checked) 
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 21.00  | Eur        | WaveCrest         | false                 |  

	##############################_Transactions_################################################

 
 Examples:
     | WMReceiver    | UserPurseId | User                   | UserId                               | Password | Comission | EPSUserId                            | EPS-02TemporaryStoragePurse | SystemPurseUserId                    | EPS-06Exchanges | EPS-01Commissions |
     | E000000000005 | 469432      | 300316q@qa.swiftcom.uk | eb1ee77d-7438-4d31-add7-e934aa833075 | 123123   | 11.00      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 144177                      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 122122          | 406604            | 