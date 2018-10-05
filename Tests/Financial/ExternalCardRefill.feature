@ExternalCardRefill
Feature: ExternalCardRefill


Scenario Outline: ФИЗ RUB (Воронеж) (конвертация USD-RUB)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Отдаваемая сумма' set to '<Amount>'
	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  | ₽ 500.00       |
		| Максимальная сумма перевода: | ₽ 75 000.00    |
		| Комиссия:                    | 13%min $ 3.50 |  
	Then Currency rate placeholder appears
	Given User clicks on "Далее"
	
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | VISA, x3678             |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Курс обмена       | $ 1.00 = ₽ **rateWM**   |
		| Получаемая сумма  | ₽ **amount * rate**     |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |  
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 | 
	
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 61              | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | BankVoronezh     | 4244 36** **** 3678 | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | out       | <SystemPurseUserId> | Rub        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	  | 50                | RefillExternalCardFromPurseProviderCommission | out       | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 50				  | Rub        | BankVoronezh      | false                 |
	  | **amount * rate** | Rub        | BankVoronezh      | false                 |  

	   ##############################_Transactions_################################################

	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  

		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                                                               |
		| Заказ №      | **InvoiceId**                                                                                                                         |
		#EPA-6699| Внешний ID   | **ExternalTransactionId**                                                                                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                  |
		| Продукт      | e-Wallet <PurseId>                                                                                                                    |
		| Получатель   | 4244 36** **** 3678                                                                                                                   |
		| Сумма        | $ <Comission>                                                                                                                         |
		| Детали       | Commission for outgoing payment to sided bank card VISA, x3678. Amount transferred to card: ₽**amount * rate**, Rate: $1 = ₽**rate**. |  
	
		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                                                                                |
		| Транзакция № | **TPurseTransactionId**                                                                                                |
		| Заказ №      | **InvoiceId**                                                                                                          |
		#EPA-6699| Внешний ID   | **ExternalTransactionId**                                                                                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                   |
		| Продукт      | e-Wallet <PurseId>                                                                                                     |
		| Получатель   | 4244 36** **** 3678                                                                                                    |
		| Сумма        | $ <Amount>                                                                                                             |
		| Детали       | Outgoing payment to sided bank card VISA, x3678. Amount transferred to card: ₽**amount * rate**, Rate: $1 = ₽**rate**. |   
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>																																					 | -                              |
     | Email       | 6        | refillvoronezhcard@qa.swiftcom.uk                                                                                                                        | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |     

 
 @135426
   @RefillExternalCardFromPurse_BankQiwi_OFF
	  Examples:
   | PANReceiver      | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 4244362761063678 | 10.00  | 3.50      | 13.50           | +70045254888 | a5a34987-6189-4a4c-8229-d9f2ac0ad001 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1697822     | 001-697822 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  

   
Scenario Outline: БИЗ RUB (Воронеж) (конвертация USD-RUB)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Номер банковской карты' set to '<PANReceiver>'
	
	Then 'Владелец' set to 'nik ivanov'

	Then 'Отдаваемая сумма' set to '<Amount>'
	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)
	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  | ₽ 500.00       |
		| Максимальная сумма перевода: | ₽ 75 000.00    |
		| Комиссия:                    | 13%min $ 3.50 |  
	Then Currency rate placeholder appears

	
	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | <CardInfo>             |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Курс обмена       | $ 1.00 = ₽ **rateWM**     |
		| Получаемая сумма  | ₽ **amount * rate**     |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  | 
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
		Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 |  
	
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 61              | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | BankVoronezh     | <MaskedPan> | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | out       | <SystemPurseUserId> | Rub        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	  | 50                | RefillExternalCardFromPurseProviderCommission | out       | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 50				  | Rub        | BankVoronezh      | false                 |
	  | **amount * rate** | Rub        | BankVoronezh      | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  

#EPA-6700

        Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                         |
		| Транзакция № | **TPurseTransactionId**                                                                                                                         |
		| Заказ №      | **InvoiceId**                                                                                                                                   |
		# #EPA-6699    | Внешний ID   **ExternalTransactionId** |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                            |
		| Продукт      | e-Wallet <PurseId>                                                                                                                              |
		| Получатель   | <MaskedPan>                                                                                                                                     |
		| Сумма        | $ <Comission>                                                                                                                                   |
		| Детали       | Commission for outgoing payment to sided bank card <CardInfoInStatement>. Amount transferred to card: ₽**amount * rate**, Rate: $1 = ₽**rate**. |                           
#EPA-6700	

        Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                                                                                          |
		| Транзакция № | **TPurseTransactionId**                                                                                                          |
		| Заказ №      | **InvoiceId**                                                                                                                    |
		#| #EPA-6699    | Внешний ID   | **ExternalTransactionId** |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                             |
		| Продукт      | e-Wallet <PurseId>                                                                                                               |
		| Получатель   | <MaskedPan>                                                                                                                      |
		| Сумма        | $ <Amount>                                                                                                                       |
		| Детали       | Outgoing payment to sided bank card <CardInfoInStatement>. Amount transferred to card: ₽**amount * rate**, Rate: $1 = ₽**rate**. |                             
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | iam_a_biz_account@qa.swiftcom.uk                                                                                                                         | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLDfHIt29BT:APA91bT1wbbodcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb450c1c10db847ae57c69f58bb2d947e2                                                                                         | -                              |  

 
 @3191326
 @RefillExternalCardFromPurse_BankQiwi_OFF
Examples:
  | CardInfoInStatement | CardInfo    | MaskedPan           | PANReceiver      | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
  | VISA, x3678         | VISA, x3678 | 4244 36** **** 3678 | 4244362761063678 | 10.00  | 3.50      | 13.50           | +70092363995 | 675852fb-2981-4d66-af20-6d30a562e6b3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1634433     | 001-634433 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |

 @3191327
 @RefillExternalCardFromPurse_BankQiwi_OFF
Examples:
  | CardInfoInStatement | CardInfo    | MaskedPan           | PANReceiver      | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
  | x0002               | МИР, x0002  | 2201 01** **** 0002 | 2201010000000002 | 10.00  | 3.50      | 13.50           | +70092363995 | 675852fb-2981-4d66-af20-6d30a562e6b3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1634433     | 001-634433 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


   @3070474
      @RefillExternalCardFromPurse_BankQiwi_OFF
Scenario Outline: RUB (Воронеж) (без конвертации RUB-RUB)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Со счета' selector set to 'RUB' in eWallet section
	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'

	Then 'Получаемая сумма' selector set to 'RUB'

	Then 'Отдаваемая сумма' set to '<Amount>'
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  | ₽ 500.00       |
		| Максимальная сумма перевода: | ₽ 75 000.00    |
		| Комиссия:                    | 1.2%min ₽ 125 |

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | RUB, e-Wallet <PurseId> |
		| Банковская карта  | x2423                   |
		| Отдаваемая сумма  | ₽ <Amount>              |
		| Комиссия          | ₽ <Comission>           |
		| Сумма с комиссией | ₽ <AmountComission>     |
		| Получаемая сумма  | ₽ <Amount>              |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
		Then eWallet updated sections are:
		| USD  | EUR  | RUB                |
		| 0.00 | 0.00 | -<AmountComission> |   
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 112             | <Amount> | <Comission> |    

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity        | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | BankVoronezh     | 4723 45** **** **** 423 | Rub        | EWallet       | Purse                | <UserId> |    
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |
	  | 50                | RefillExternalCardFromPurseProviderCommission | out       | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Rub        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 50				  | Rub        | BankVoronezh      | false                 |
	  | <Amount>          | Rub        | BankVoronezh      | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - ₽ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - ₽ <Amount>    |  

		
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                         |
		| Транзакция № | **TPurseTransactionId**                                         |
		| Заказ №      | **InvoiceId**                                                   |
		| Внешний ID   | **ExternalTransactionId**                                       |
		| Дата         | **dd.MM.yyyy HH:mm**                                            |
		| Продукт      | e-Wallet <PurseId>                                              |
		| Получатель   | 4723 45** **** **** 423                                         |
		| Сумма        | ₽ <Comission>                                                   |
		| Детали       | Commission for outgoing payment to sided bank card VISA, x 423. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                          |
		| Транзакция № | **TPurseTransactionId**                          |
		| Заказ №      | **InvoiceId**                                    |
		| Внешний ID   | **ExternalTransactionId**                        |
		| Дата         | **dd.MM.yyyy HH:mm**                             |
		| Продукт      | e-Wallet <PurseId>                               |
		| Получатель   | 4723 45** **** **** 423                          |
		| Сумма        | ₽ <Amount>                                       |
		| Детали       | Outgoing payment to sided bank card VISA, x 423. |  
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  

 

	  Examples:
   | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 4723455465464512423 | 500.00 | 125.00    | 625.00          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  



   @2706259
Scenario Outline: (ПриватБанк) (конвертация USD-EUR)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Отдаваемая сумма' set to '<Amount>'

	Then 'Владелец' set to 'nik ivanov'

	Then 'Получаемая сумма' selector set to 'EUR'

	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)

	Given User see limits table
		| Column1                      | Column2    |
		| Минимальная сумма перевода:  | € 10.00    |
		| Максимальная сумма перевода: | € 2 000.00 |
		| Комиссия:                    | 2%         |  
	Then Currency rate placeholder appears

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x1557       |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Курс обмена       | $ 1.00 = € **rateWM**   |
		| Получаемая сумма  | € **amount * rate**     |   
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |

	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
		Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 | 
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 231              | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | PrivateBank     | 5457 08** **** 1557 | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | out       | <SystemPurseUserId> | Eur        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | in        | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **amount * rate** | Eur        | PrivateBank      | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  

		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                     |
		| Транзакция № | **TPurseTransactionId**                                                                                                                     |
		| Заказ №      | **InvoiceId**                                                                                                                               |
		| Внешний ID   | **ExternalTransactionId**                                                                                                                   |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                        |
		| Продукт      | e-Wallet <PurseId>                                                                                                                          |
		| Получатель   | 5457 08** **** 1557                                                                                                                         |
		| Сумма        | $ <Comission>                                                                                                                               |
		| Детали       | Commission for outgoing payment to sided bank card MasterCard, x1557. Amount transferred to card: €**amount * rate**, Rate: $1 = €**rate**. |   
	
		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                                                                                      |
		| Транзакция № | **TPurseTransactionId**                                                                                                      |
		| Заказ №      | **InvoiceId**                                                                                                                |
		| Внешний ID   | **ExternalTransactionId**                                                                                                    |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                         |
		| Продукт      | e-Wallet <PurseId>                                                                                                           |
		| Получатель   | 5457 08** **** 1557                                                                                                          |
		| Сумма        | $ <Amount>                                                                                                                   |
		| Детали       | Outgoing payment to sided bank card MasterCard, x1557. Amount transferred to card: €**amount * rate**, Rate: $1 = €**rate**. |  
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  

 

	  Examples:
   | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 5457 0856 8745 1557 | 100.00 | 2.00      | 102.00          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  

     @3092746
Scenario Outline: (ПриватБанк) (без конвертации EUR-EUR)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"

	Then 'Со счета' selector set to 'EUR' in eWallet section
	Then 'Получаемая сумма' selector set to 'EUR'


	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)
	
	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Отдаваемая сумма' set to '<Amount>'

	Then 'Владелец' set to 'nik ivanov'

	Then Section 'Amount including fees' is: € <AmountComission> (Комиссия: € <Comission>)

	Given User see limits table
		| Column1                      | Column2    |
		| Минимальная сумма перевода:  | € 10.00    |
		| Максимальная сумма перевода: | € 2 000.00 |
		| Комиссия:                    | 2%         |  

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | EUR, e-Wallet <PurseId> |
		| Банковская карта  | VISA, x5641             |
		| Отдаваемая сумма  | € <Amount>              |
		| Комиссия          | € <Comission>           |
		| Сумма с комиссией | € <AmountComission>     |
		| Получаемая сумма  | € <Amount>              |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot
  

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
		Then eWallet updated sections are:
		| USD  | EUR                | RUB  |
		| 0.00 | -<AmountComission> | 0.00 |  
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 232             | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | PrivateBank      | 4149 49** **** 5641 | Eur        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Eur        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Eur        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Eur        | <EPS-01Commissions>           | 0           |
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Eur        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  |<Amount>           | Eur        | PrivateBank       | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - € <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - € <Amount>    |  

		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                         |
		| Транзакция № | **TPurseTransactionId**                                         |
		| Заказ №      | **InvoiceId**                                                   |
		| Внешний ID   | **ExternalTransactionId**                                       |
		| Дата         | **dd.MM.yyyy HH:mm**                                            |
		| Продукт      | e-Wallet <PurseId>                                              |
		| Получатель   | 4149 49** **** 5641                                             |
		| Сумма        | € <Comission>                                                   |
		| Детали       | Commission for outgoing payment to sided bank card VISA, x5641. |  
	
		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                          |
		| Транзакция № | **TPurseTransactionId**                          |
		| Заказ №      | **InvoiceId**                                    |
		| Внешний ID   | **ExternalTransactionId**                        |
		| Дата         | **dd.MM.yyyy HH:mm**                             |
		| Продукт      | e-Wallet <PurseId>                               |
		| Получатель   | 4149 49** **** 5641                              |
		| Сумма        | € <Amount>                                       |
		| Детали       | Outgoing payment to sided bank card VISA, x5641. |  
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  

 

Examples:
   | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 4149 4934 4367 5641 | 100.00 | 2.00      | 102.00          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


     @135427
   @RefillExternalCardFromPurse_BankQiwi_OFF

Scenario Outline: (Rietumu) (конвертация USD-EUR)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Отдаваемая сумма' set to '<Amount>'


	Then 'Получаемая сумма' selector set to 'EUR'

	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  | € 10.00        |
		| Максимальная сумма перевода: | € 2 000.00     |
		| Комиссия:                    | 2.9%min $ 3.50 |   
	Then Currency rate placeholder appears

	Given User clicks on "Далее"
	Given Set StartTime for DB search

	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x4223             |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Курс обмена       | $ 1.00 = € **rateWM**   |
		| Получаемая сумма  | € **amount * rate**     |  
		
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Given Set StartTime for DB search
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

		Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 |  

	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 123              | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | Rietumu          | 5459 91** **** 4223 | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | out       | <SystemPurseUserId> | Eur        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | in        | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Eur        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **amount * rate** | Eur        | Rietumu           | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  
		
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                                                               |
		| Заказ №      | **InvoiceId**                                                                                                                         |
		| Внешний ID   | **ExternalTransactionId**                                                                                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                  |
		| Продукт      | e-Wallet <PurseId>                                                                                                                    |
		| Получатель   | 5459 91** **** 4223                                                                                                                  |
		| Сумма        | $ <Comission>                                                                                                                         |
		| Детали       | Commission for outgoing payment to sided bank card MasterCard, x4223. Amount transferred to card: €**amount * rate**, Rate: $1 = €**rate**. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                                                                                |
		| Транзакция № | **TPurseTransactionId**                                                                                                |
		| Заказ №      | **InvoiceId**                                                                                                          |
		| Внешний ID   | **ExternalTransactionId**                                                                                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                   |
		| Продукт      | e-Wallet <PurseId>                                                                                                     |
		| Получатель   | 5459 91** **** 4223                                                                                                    |
		| Сумма        | $ <Amount>                                                                                                             |
		| Детали       | Outgoing payment to sided bank card MasterCard, x4223. Amount transferred to card: €**amount * rate**, Rate: $1 = €**rate**. |   
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
   # | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  

# Ретума не работает с этой кратой пока что 
#	  Examples:
#  | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
#  | 4228 8100 0000 0000 | 100.00 | 3.50      | 103.50          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  

Examples:
  | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
  | 5459 9172 6685 4223 | 100.00 | 3.50      | 103.50          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  

#5459917266854223

      @3092764
Scenario Outline: (Rietumu) (без конвертации USD-USD)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Отдаваемая сумма' set to '<Amount>'

	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  | $ 10.00        |
		| Максимальная сумма перевода: | $ 2 000.00     |
		| Комиссия:                    | 2.9%min $ 3.50 |  

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x1577       |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Получаемая сумма  | $ <Amount>              |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
		Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 | 
	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 123             | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | Rietumu          | 5460 43** **** 1577 | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  |<Amount>           | Usd        | Rietumu      | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  

		
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                               |
		| Транзакция № | **TPurseTransactionId**                                               |
		| Заказ №      | **InvoiceId**                                                         |
		| Внешний ID   | **ExternalTransactionId**                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                  |
		| Продукт      | e-Wallet <PurseId>                                                    |
		| Получатель   | 5460 43** **** 1577                                                   |
		| Сумма        | $ <Comission>                                                         |
		| Детали       | Commission for outgoing payment to sided bank card MasterCard, x1577. |   
	
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                |
		| Транзакция № | **TPurseTransactionId**                                |
		| Заказ №      | **InvoiceId**                                          |
		| Внешний ID   | **ExternalTransactionId**                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                   |
		| Продукт      | e-Wallet <PurseId>                                     |
		| Получатель   | 5460 43** **** 1577                                    |
		| Сумма        | $ <Amount>                                             |
		| Детали       | Outgoing payment to sided bank card MasterCard, x1577. |  
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  

 

	  Examples:
   | PANReceiver      | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 5460431001821577 | 100.00 | 3.50      | 103.50          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  



        @1720172

Scenario Outline: (QIWI) (конвертация USD-RUB)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Отдаваемая сумма' set to '<Amount>'

	Then 'Получаемая сумма' selector set to 'RUB'

	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  |₽ 500.00       |
		| Максимальная сумма перевода: |₽ 75 000.00    |
		| Комиссия:                    | 2.9%min $ 3.50 |  
	Then Currency rate placeholder appears

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | USD, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x2411             |
		| Отдаваемая сумма  | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |
		| Курс обмена       | $ 1.00 = ₽ **rateWM**     |
		| Получаемая сумма  | ₽ **amount * rate**     |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

		Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 |  

	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 155              | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | BankQiwi         | 5106 21** **** 2411 | Usd        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | CurrencyExchangeUsdAndEur                     | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | out       | <SystemPurseUserId> | Rub        | <EPS-06Exchanges>             | 0           |
	  | **amount * rate** | CurrencyExchangeUsdAndEur                     | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | **amount * rate** | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |
	  | 0.025             | RefillExternalCardFromPurseProviderCommission | out       | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 0.025             | Rub        | BankQiwi          | false                 |
	  | **amount * rate** | Rub        | BankQiwi          | false                 |  

	   ##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ <Amount>    |  

		
Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                      |
		| Транзакция № | **TPurseTransactionId**                                                                                                                      |
		| Заказ №      | **InvoiceId**                                                                                                                                |
		| Внешний ID   | **ExternalTransactionId**                                                                                                                    |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                         |
		| Продукт      | e-Wallet <PurseId>                                                                                                                           |
		| Получатель   | 5106 21** **** 2411                                                                                                                          |
		| Сумма        | $ <Comission>                                                                                                                                |
		| Детали       | Commission for outgoing payment to sided bank card MasterCard, x2411. Amount transferred to card: ₽**amount ** rate**, Rate: $1 = ₽**rate**. |  
	
		Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                                                                                       |
		| Транзакция № | **TPurseTransactionId**                                                                                                       |
		| Заказ №      | **InvoiceId**                                                                                                                 |
		| Внешний ID   | **ExternalTransactionId**                                                                                                     |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                          |
		| Продукт      | e-Wallet <PurseId>                                                                                                            |
		| Получатель   | 5106 21** **** 2411                                                                                                           |
		| Сумма        | $ <Amount>                                                                                                                    |
		| Детали       | Outgoing payment to sided bank card MasterCard, x2411. Amount transferred to card: ₽**amount ** rate**, Rate: $1 = ₽**rate**. |   
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  


	  Examples:
   | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 5106 2110 1481 2411 | 100.00 | 3.50      | 103.50          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


           @3094727

Scenario Outline: (QIWI) (без конвертации RUB-RUB)

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На банковскую карту"
	Given User clicks on "На банковскую карту"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Со счета' selector set to 'RUB' in eWallet section
	Then 'Номер банковской карты' set to '<PANReceiver>'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Получаемая сумма' selector set to 'RUB'

	Then 'Отдаваемая сумма' set to '<Amount>'
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

	Given User see limits table
		| Column1                      | Column2        |
		| Минимальная сумма перевода:  |₽ 500.00       |
		| Максимальная сумма перевода: |₽ 75 000.00    |
		| Комиссия:                    | 1.2%min ₽ 125 |  

	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                 |
		| Отправитель       | RUB, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x2411             |
		| Отдаваемая сумма  | ₽ <Amount>              |
		| Комиссия          | ₽ <Comission>           |
		| Сумма с комиссией | ₽ <AmountComission>     |
		| Получаемая сумма  | ₽ <Amount>      |  
		
	Given Set StartTime for DB search
	Given User clicks on button "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

		Then eWallet updated sections are:
		| USD  | EUR  | RUB                |
		| 0.00 | 0.00 | -<AmountComission> |  

	#2.1.2. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-2.1.%D0%9D%D0%B0%D1%81%D1%82%D0%BE%D1%80%D0%BE%D0%BD%D0%BD%D1%8E%D1%8E%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D1%83%D1%8E%D0%BA%D0%B0%D1%80%D1%82%D1%83
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 157             | <Amount> | <Comission> |  

	#[EPA-6127] ExternalTransaction should not be 0
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed |         | WaveCrest      | <PurseId>      | BankQiwi          | 5106 21** **** 2411 | Rub        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                                 | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Amount>          | RefillExternalCardFromPurse                   | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <Comission>       | RefillExternalCardFromPurseCommission         | in        | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |
	  | 0.025             | RefillExternalCardFromPurseProviderCommission | out       | <EPSUserId>         | Rub        | <EPS-01Commissions>           | 0           |  
	
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                    | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
	  | Rub        | out       | OutgoingPaymentToSidedBankCard | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  
   
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 0.025             | Rub        | BankQiwi          | false                 |
	  | **amount * rate** | Rub        | BankQiwi          | false                 |  

	   ##############################_Transactions_################################################
	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount          |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - ₽ <Comission> |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - ₽ <Amount>    |  

		
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurseCommission' row № 0 direction='out':
		| Column1      | Column2                                                               |
		| Транзакция № | **TPurseTransactionId**                                               |
		| Заказ №      | **InvoiceId**                                                         |
		| Внешний ID   | **ExternalTransactionId**                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                  |
		| Продукт      | e-Wallet <PurseId>                                                    |
		| Получатель   | 5106 21** **** 2411                                                   |
		| Сумма        | ₽ <Comission>                                                         |
		| Детали       | Commission for outgoing payment to sided bank card MasterCard, x2411. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='RefillExternalCardFromPurse' row № 1 direction='out':
		| Column1      | Column2                                                |
		| Транзакция № | **TPurseTransactionId**                                |
		| Заказ №      | **InvoiceId**                                          |
		| Внешний ID   | **ExternalTransactionId**                              |
		| Дата         | **dd.MM.yyyy HH:mm**                                   |
		| Продукт      | e-Wallet <PurseId>                                     |
		| Получатель   | 5106 21** **** 2411                                    |
		| Сумма        | ₽ <Amount>                                             |
		| Детали       | Outgoing payment to sided bank card MasterCard, x2411. |  
	
	#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | voronezh_bank_card_uitest@qa.swiftcom.uk                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                              |  


	  Examples:
   | PANReceiver         | Amount | Comission | AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 5106 2110 1481 2411 | 500.00 | 125.00    | 625.00          | +70078644084 | 96879579-d3fa-4bfd-9b57-269a357fdaa3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1358862     | 001-358862 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


              @3427092

Scenario Outline: Массовый перевод на банковскую карту 

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "Выплаты на банковские карты ваших клиентов"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	#STEP 1,2
	#Upload CSV file	
 	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
	Then File "Sample_file for mass payment external card negative.csv" uploaded
	Then Alert Message "Строка 1: Получатель указан неверно" appears
		
	Then File "Sample_file for mass payment external card.csv" uploaded
	Given User see ExternalCard receivers table
		| Number | Recipient                     | OutgoingAmount | Fees       | IncomingAmount | Total      | Button  |
		| 1      | 5460431001821577 John Smith   | $ 1 000.00     | $ 29.00    | $ 1 000.00     | $ 1 029.00 | УДАЛИТЬ |
		| 2      | 5106211014812411 Pascal Heyer | ₽ 1 000.00     | ₽ 125.00   | ₽ 1 000.00       | ₽ 1 125.00 | УДАЛИТЬ |          
	Then Section 'Amount including fees' is: 2 ₽ 1 125.00 + $ 1 029.00 (Комиссия: ₽ 125.00 + $ 29.00)
	
	Given User clicks on button "Удалить" in table
	#STEP 3
	Then Section 'Amount including fees' is: ₽ 1 125.00 (Комиссия: ₽ 125.00)
	Then 'Номер банковской карты' set to '5460431001821577'
	Then 'Владелец' set to 'nik ivanov'
	Then 'Получаемая сумма' selector set to 'USD'
	Then 'Отдаваемая сумма' selector set to 'USD'

	Then 'Отдаваемая сумма' set to '1000'
	
	#STEP 4
	Given User clicks on "Добавить платеж" on Multiform
	Then Section 'Amount including fees' is: 2 ₽ 1 125.00 + $ 1 029.00 (Комиссия: ₽ 125.00 + $ 29.00)

     Given User see limits table at YandexMoney mass payment
		| Description | Min      | Max         | Fee            |
		| USD         | $ 10.00  | $ 2 000.00  | 2.9%min $ 3.50 |
		| EUR         | € 10.00  | € 2 000.00  | 2.9%min € 3    |
		| RUB         | ₽ 500.00 | ₽ 75 000.00 | 2.9%min ₽ 125  |     
	Given Set StartTime for DB search
	Then Memorize eWallet section
		
	#STEP 5
	Given User clicks on "Далее"

	#STEP 6
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70083432685 | <UserId> | false  |  
			
	Given User clicks on "Оплатить"

	Then User gets message "Обработка платежей завершена" on Multiform
	Then User gets message "Выполнено 2 из 2" on Multiform
	Then User gets message "Отправлено платежей: 2" on Multiform
	Then User gets message "Не отправлено платежей: 0" on Multiform

	Then Make screenshot
	
	#Step 7
	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/

	Then eWallet updated sections are:
		| USD      | EUR  | RUB      |
		| -1029.00 | 0.00 | -1125.00 |    

	#STEP 8 
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                            | Amount       |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - $ 29.00    |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - $ 1 000.00 |
		| **DD.MM.YY** | Комиссия за перевод на внешнюю банковскую карту | - ₽ 125.00   |
		| **DD.MM.YY** | Перевод на внешнюю банковскую карту             | - ₽ 1 000.00 |  

	Then User selects records in table 'Notification' for UserId="<UserId>"
     | MessageType | Priority | Receiver                                                                                                                                                 | Title             |
     | Sms         | 13       | +70083432685                                                                                                                                                  | -                 |
     | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции |
     | PushAndroid | 6        | cLCkHIt27Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-27FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                 |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d926e2                                                                                         | -                 |  


	  Examples:
   | PANReceiver         |  User                                   | UserId                               | Password     | 
   | 5106 2110 1481 2411 |  externalCardmassPayment@qa.swiftcom.uk | e5105d3d-bb22-426b-b715-c3c56a12649f | 72621010Abac |
