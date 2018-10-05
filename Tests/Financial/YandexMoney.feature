@YandexMoney
Feature: YandexMoney
		Sending to Yandex money

		
  Scenario Outline: Перевод YM физик (без конвертации)
# Тестовые кошельки для тестирования
# 410039303350 — кошелек заблокирован (зачисления на счет запрещены)
# 4100322407607 — корректный номер (зачисление успешно пройдет)
# 410039303807 — неверная контрольная сумма
# Обратить внимание на статус задачи https://jira.swiftcom.uk/browse/SD-2260, из-за неё фэйлится шаг 9

    Then User updates TransactionConfirmationType="<ConfirmationCode>" for UserId="<UserId>" in table 'TUsers'

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На кошелек Яндекс.Деньги"
#STEP 2
	Then Section 'Amount including fees' is: ₽ 0.00 (Комиссия: ₽ 0.00)
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | ₽ 1.00       |
		| Максимальная сумма перевода: | ₽ 60 000.00  |
		| Максимальная дневная сумма:  | ₽ 300 000.00 |
		| Максимальная месячная сумма: | ₽ 600 000.00 |
		| Количество операций в день:  | 99           |
		| Комиссия:                    | 2%           |

	 Given 'Со счета' selector is "RUB" and contains:
     	| Options |
     	| USD     |
     	| EUR     |
     	| RUB     |

#STEP 4
	Then 'Номер кошелька Яндекс.Деньги' set to '<YandexMoneyWallet>'
	Then 'Отдаваемая сумма' set to '<Amount>'	
	Then 'Детали (обязательно)' details set to '<Details>'
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

#Step 6
	Given User clicks on "Далее"
	Given User see table
		| Column1                        | Column2                     |
		| Отправитель                    | RUB, e-Wallet <UserPurseId> |
		| Номер кошелька в Яндекс.Деньги | <YandexMoneyWallet>         |
		| Отдаваемая сумма               | ₽ <Amount>                  |
		| Комиссия                       | ₽ <Comission>               |
		| Сумма с комиссией              | ₽ <AmountComission>         |
		| Получаемая сумма               | ₽ <Amount>                  |
		| Детали                         | <Details>                   |      

#Step 8
	Given Set StartTime for DB search
	Given User clicks on "Подтвердить"

#Step 10

	
	Then User type <ConfirmationCode> sent to:
		| OperationType | Recipient       | UserId   | IsUsed |
		| MassPayment   | <CodeRecipient> | <UserId> | false  | 


	Then Memorize eWallet section
	Given Set StartTime for DB search
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	Then Wait for transactions loading
	Then eWallet updated sections are:
		| USD  | EUR  | RUB                |
		| 0.00 | 0.00 | -<AmountComission> |  
	
	Given User clicks on Отчеты menu
#STEP 13
	Given User see transactions list contains:
		| Date         | Name                                | Amount          |
		| **DD.MM.YY** | Комиссия за перевод в Яндекс.Деньги | - ₽ <Comission> |
		| **DD.MM.YY** | Перевод в Яндекс.Деньги             | - ₽ <Amount>    |  
				
    Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                              |
		| Транзакция № | **TPurseTransactionId**                                                                                              |
		| Заказ №      | **InvoiceId**                                                                                                        |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                 |
		| Продукт      | e-Wallet <UserPurseId>                                                                                               |
		| Получатель   | <YandexMoneyWallet>                                                                                                  |
		| Сумма        | ₽ <Comission>                                                                                                        |
		| Детали       | Commission for outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoney' row № 1 direction='out':
		| Column1      | Column2                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                               |
		| Заказ №      | **InvoiceId**                                                                                         |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                  |
		| Продукт      | e-Wallet <UserPurseId>                                                                                |
		| Получатель   | <YandexMoneyWallet>                                                                                   |
		| Сумма        | ₽ <Amount>                                                                                            |
		| Детали       | Outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. |  
	
#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
		 | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
		 | Email       | 6        | <Email>                                                                                                                                                  | Отчет по операции №**Invoice** |
		 | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6M | -                              |
		 | PushIos     | 6        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e0                                                                                         | -                              |  

 
@2843636
  Examples:
    | CodeRecipient                        | ConfirmationCode | paymentCodePhone | PaymentWay       | Email                                 | AmountComission | Comission | Amount | YandexMoneyWallet | User         | UserId                               | Password     | Details | UserPurseId |
    | 23e54424-d8c6-4f24-afc5-fbe626780629 | SMSCode          | 123455           | payment password | nikita_UI_financial_YM@qa.swiftcom.uk | 10.20           | 0.20      | 10.00  | 410000000000      | +70080294751 | 23e54424-d8c6-4f24-afc5-fbe626780629 | 72621010Abac | Детали  | 001-002542  |  

@3393741
  Examples:
   | CodeRecipient | ConfirmationCode | paymentCodePhone | PaymentWay       | Email                                 | AmountComission | Comission | Amount | YandexMoneyWallet | User         | UserId                               | Password     | Details | UserPurseId |
   | cLCkHIt77RM   | PushCode         | 123455           | payment password | nikita_UI_financial_YM@qa.swiftcom.uk | 10.20           | 0.20      | 10.00  | 410000000000      | +70080294751 | 23e54424-d8c6-4f24-afc5-fbe626780629 | 72621010Abac | Детали  | 001-002542  |  

 

 @433734
  Scenario Outline: Перевод YM физик (конвертация, валидация)
# Тестовые кошельки для тестирования
# 410039303350 — кошелек заблокирован (зачисления на счет запрещены)
# 4100322407607 — корректный номер (зачисление успешно пройдет)
# 410039303807 — неверная контрольная сумма
# Обратить внимание на статус задачи https://jira.swiftcom.uk/browse/SD-2260, из-за неё фэйлится шаг 9
	
	Then User updates TransactionConfirmationType="<ConfirmationCode>" for UserId="<UserId>" in table 'TUsers'

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На кошелек Яндекс.Деньги"
#STEP 2
	Then Section 'Amount including fees' is: ₽ 0.00 (Комиссия: ₽ 0.00)
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | ₽ 1.00       |
		| Максимальная сумма перевода: | ₽ 60 000.00  |
		| Максимальная дневная сумма:  | ₽ 300 000.00 |
		| Максимальная месячная сумма: | ₽ 600 000.00 |
		| Количество операций в день:  | 99            |
		| Комиссия:                    | 2%           |

	 Given 'Со счета' selector is "RUB" and contains:
     	| Options |
     	| USD     |
     	| EUR     |
     	| RUB     |

#STEP 4
	Then 'Номер кошелька Яндекс.Деньги' set to '<YandexMoneyWallet>'
	Then 'Отдаваемая сумма' set to '<Amount>'	
	Then 'Детали (обязательно)' details set to '<Details>'
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)
#Step 5 not implemented: should be separated test

#Step 6
	Given User clicks on "Далее"
	Given User see table
		| Column1                        | Column2                     |
		| Отправитель                    | RUB, e-Wallet <UserPurseId> |
		| Номер кошелька в Яндекс.Деньги | <YandexMoneyWallet>         |
		| Отдаваемая сумма               | ₽ <Amount>                  |
		| Комиссия                       | ₽ <Comission>               |
		| Сумма с комиссией              | ₽ <AmountComission>         |
		| Получаемая сумма               | ₽ <Amount>                  |
		| Детали                         | <Details>                   |  

#Step 7
	Given User clicks on "Назад"
	Then 'Номер кошелька Яндекс.Деньги' value is '<YandexMoneyWallet>'
	Then 'Отдаваемая сумма' value is '<Amount>'
	Then 'Получаемая сумма' value is '<Amount>'
	Then 'Детали (обязательно)' details value is '<Details>'

	Then 'Со счета' selector set to 'USD' in eWallet section
	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)
	Then Currency rate placeholder appears
#Step 8
	Given User clicks on "Далее"
	Given User see table
		| Column1                        | Column2                     |
		| Отправитель                    | USD, e-Wallet <UserPurseId> |
		| Номер кошелька в Яндекс.Деньги | <YandexMoneyWallet>         |
		| Отдаваемая сумма               | $ <Amount>                  |
		| Комиссия                       | $ <Comission>               |
		| Сумма с комиссией              | $ <AmountComission>         |
		| Курс обмена                    | $ 1.00 = ₽ **rateWM**       |
		| Получаемая сумма               | ₽ **amount * rate**         |
		| Детали                         | <Details>                   |   

#Step 9 not implemented: Обратить внимание на статус задачи https://jira.swiftcom.uk/browse/SD-2260, из-за неё фэйлится шаг 9

	Given Set StartTime for DB search
	Given User clicks on "Подтвердить"
	
#Step 10
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Then Memorize eWallet section
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform

	Then Make screenshot
	
	# Transaction Catalogue 2.3.6.
  	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 136             | <Amount> | <Comission> |  
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	 | State     | Details   | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	 | Successed | <Details> | WaveCrest      | <UserPurseId>  | YandexMoney      | <YandexMoneyWallet> | Usd        | EWallet       | Purse                | <UserId> |  

	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount            | DestinationId                    | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
   	  | <Amount>          | OutgoingTransferToYandexMoney    | out       | <UserId>            | Usd        | 1<ShortUserPurseId>           | 0           |
   	  | <Amount>          | OutgoingTransferToYandexMoney    | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | <Comission>       | OutgoingTransferToYandexMoneyFee | out       | <UserId>            | Usd        | 1<ShortUserPurseId>           | 0           |
   	  | <Comission>       | OutgoingTransferToYandexMoneyFee | in        | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | <Amount>          | CurrencyExchangeUsdAndEur        | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | <Amount>          | CurrencyExchangeUsdAndEur        | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges>             | 0           |
   	  | **amount * rate** | CurrencyExchangeUsdAndEur        | out       | <SystemPurseUserId> | Rub        | <EPS-06Exchanges>             | 0           |
   	  | **amount * rate** | CurrencyExchangeUsdAndEur        | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | **amount * rate** | OutgoingTransferToYandexMoney    | out       | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | <Comission>       | OutgoingTransferToYandexMoneyFee | out       | <EPSUserId>         | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
   	  | <Comission>       | OutgoingTransferToYandexMoneyFee | in        | <EPSUserId>         | Usd        | <EPS-01Commissions>           | 0           |             

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                   | UserId   | Amount            | AmountInUsd   | Product       | ProductType |
	  | Rub        | out       | OutgoingTransferToYandexMoney | <UserId> | **amount * rate** | **Generated** | <UserPurseId> | Epid        |     

	#QAA-550 (details is not checked) 
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **amount * rate** | Rub        | YandexMoney       | false                 |    

	##############################_Transactions_################################################
	
	Then eWallet updated sections are:
		| USD                | EUR  | RUB  |
		| -<AmountComission> | 0.00 | 0.00 |  

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	Then Wait for transactions loading
	
	Given User clicks on Отчеты menu
#STEP 13
	Given User see transactions list contains:
		| Date         | Name                                | Amount     |
		| **DD.MM.YY** | Комиссия за перевод в Яндекс.Деньги | - $ 2.00   |
		| **DD.MM.YY** | Перевод в Яндекс.Деньги             | - $ 100.00 |  
				
    Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoneyFee' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                             |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                             |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                       |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                |
		| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                              |
		| Получатель   | <YandexMoneyWallet>                                                                                                                                                                                 |
		| Сумма        | $ <Comission>                                                                                                                                                                                       |
		| Детали       | Commission for outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. Amount transferred to Yandex.Money: ₽**amount ** rate**, Rate: $1 = ₽**rate**. |  
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoney' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                                   |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                   |
		| Заказ №      | **InvoiceId**                                                                                                                                                                             |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                      |
		| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                    |
		| Получатель   | <YandexMoneyWallet>                                                                                                                                                                       |
		| Сумма        | $ <Amount>                                                                                                                                                                                |
		| Детали       | Outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. Amount transferred to Yandex.Money: ₽**amount ** rate**, Rate: $1 = ₽**rate**. |   
	
#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Sms         | 13       | <User>                                                                                                                                                   | -                              |
     | Email       | 6        | nikita_UI_financial_YM@qa.swiftcom.uk                                                                                                                    | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6M | -                              |
     | PushIos     | 6        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e0                                                                                         | -                              |  

 
  
  Examples:
     | ConfirmationCode | AmountComission | Comission | Amount | YandexMoneyWallet | User         | UserId                               | Password     | EPSUserId                            | ShortUserPurseId | UserPurseId | SystemPurseId | SystemPurseUserId                    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | Details |
     | SMSCode          | 102.00          | 2.00      | 100.00 | 410000000000      | +70080294751 | 23e54424-d8c6-4f24-afc5-fbe626780629 | 72621010Abac | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 002542           | 001-002542  | 122122        | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 144177                      | 122122          | 406604            | Детали  |  


	 		
  Scenario Outline: Массовый перевод Yandex Money - биз

#   Пользователь Бизнес клиент
# Пользователь зарегистрирован
# На секциях кошелька имеется определенное количество средств
# Минимальные и максимальные лимиты для перевода установлены
# Страница Перевести/В Яндекс.Деньги (Payments and Transfers/To Yandex.Money) открыта
# 
# Для тестирования используются кошельки:
# 
# 410039303350 — кошелек заблокирован (зачисления на счет запрещены)
# 4100322407607 — корректный номер (зачисление успешно пройдет)
# 410039303807 — неверная контрольная сумма

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "В Яндекс.Деньги"

	Then Section 'Amount including fees' is: ₽ 0.00 (Комиссия: ₽ 0.00)

     Given User see limits table at YandexMoney mass payment
		| Description | Min      | Max         | Fee |
		| RUB         | ₽ 100.00 | ₽ 60 000.00 | 2%  |  
	Given 'Отдаваемая сумма' selector is "RUB" and contains:
    	| Options |
    	| RUB | 
    	| USD |
    	| EUR |
	Given 'Получаемая сумма' selector is "RUB" and contains:
    	| Options |
    	| RUB     |  

#STEP 1
 	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
	Then File "Sample_file_for_mass_payment_yandexmoney_negative.csv" uploaded
#STEP 2
	Then Alert Message "Строка 1: Кошелек не найден" appears
  	Then File "Sample_file_for_mass_payment_yandexmoney.csv" uploaded
	Given User see YandexMoney receivers table
		| Number | Recipient       | OutgoingAmount | Fees   | IncomingAmount | Total    | Button  |
		| 1      | 410011234567890 | ₽ 100.00       | ₽ 2.00 | ₽ 100.00       | ₽ 102.00 | УДАЛИТЬ |  

#STEP 3
	Then 'Номер кошелька Яндекс.Деньги' set to '<YandexMoneyWallet>'
	Then 'Отдаваемая сумма' selector set to 'USD'
	Then 'Отдаваемая сумма' set to '<Amount>'	
	Then Currency rate placeholder appears
	Then 'Детали (обязательно)' details set to '<Details>'
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)
#STEP 4
	Given User clicks on "Добавить платеж" on Multiform
	Given User see YandexMoney receivers table
		| Number | Recipient       | OutgoingAmount | Fees   | IncomingAmount      | Total    | Button  |
		| 1      | 410011234567890 | ₽ 100.00       | ₽ 2.00 | ₽ 100.00            | ₽ 102.00 | УДАЛИТЬ |
		| 2      | 410000000000    | $ 100.00       | $ 2.00 | ₽ **amount * rate** | $ 102.00 | УДАЛИТЬ |   

#Step 5
	Given Set StartTime for DB search
	Given User clicks on "Далее"
#Step 6

	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70017652430 | <UserId> | false  |  
	Then Memorize eWallet section

	Given User clicks on "Оплатить"

	Then User gets message "Обработка платежей завершена" on Multiform
	Then User gets message "Выполнено 2 из 2" on Multiform

	Given User see quittance YandexMoney receivers table
	| Number | Recipient       | OutgoingAmount | Fees   | IncomingAmount      | Total    | Button  |
	| 1      | 410000000000    | $ 100.00       | $ 2.00 | ₽ **amount * rate** | $ 102.00 | Успешно |  
	| 2      | 410011234567890 | ₽ 100.00       | ₽ 2.00 | ₽ 100.00            | ₽ 102.00 | Отклонено |

	Then Make screenshot

#Step 7
	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	Then Wait for transactions loading
		Then eWallet updated sections are:
		| USD     | EUR  | RUB  |
		| -102.00 | 0.00 | 0.00 |  
	Given User clicks on Отчеты menu

#STEP 8
	Given User see transactions list contains:
		| Date         | Name                                | Amount     |
		| **DD.MM.YY** | Комиссия за перевод в Яндекс.Деньги | - $ 2.00   |
		| **DD.MM.YY** | Перевод в Яндекс.Деньги             | - $ 100.00 |  

#STEP 9  
    Then User selects records in table 'Notification' for UserId="<UserId>"
      | MessageType | Priority | Receiver                                                                                                                                                 | Title             |
      | Sms         | 13       | +70017652430                                                                                                                                             | -                 |
      | Email       | 6        | <Email>                                                                                                                                                  | Отчет по операции |
      | PushAndroid | 6        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguaxcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                 |
      | PushIos     | 6        | 44a554d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                 |  


  @3336939
  Examples:
        | Email                          | AmountComission | Comission | Amount | YandexMoneyWallet | User                           | UserId                               | Password     | Details |
        | sendtoYMbizmass@qa.swiftcom.uk | 102.00          | 2.00      | 100.00 | 410000000000      | sendtoYMbizmass@qa.swiftcom.uk | 81971728-ec4c-418a-b751-54f17c699d1c | 72621010Abac | Детали  |     



Scenario Outline: Пополнение через Yandex.Деньги - без конвертации
# Клиент авторизован в личном кабинете
# У клиента есть доступ до операции
# Перейти в раздел Пополнить
# 
# Проверить с конвертацией валют и без

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Получить menu
	Given User clicks on "С кошелька Яндекс.Деньги"
#STEP 2
	Then Section 'Amount including fees' is: ₽ 0.00 (Комиссия: ₽ 0.00)
	Given User see limits table
		| Column1                      | Column2     |
		| Минимальная сумма перевода:  | ₽ 1.00      |
		| Максимальная сумма перевода: | ₽ 60 000.00 |
		| Максимальная дневная сумма:  | $ 1 000.00  |
		| Максимальная месячная сумма: | $ 5 000.00  |
		| Количество операций в день:  | 5           |
		| Комиссия:                    | 2%          |  

	 Given 'На счет' selector is "RUB" and contains:
     	| Options |
     	| USD     |
     	| EUR     |
     	| RUB     |

#STEP 4
	Then 'Получаемая сумма' set to '<Amount>'	
	Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

#Step 6
	Given User clicks on "Далее"
	Given User see table
		| Column1          | Column2                     |
		| На счет          | RUB, e-Wallet <UserPurseId> |
		| Получаемая сумма | ₽ <Amount>                  |
		| Отдаваемая сумма | ₽ <AmountComission>         |
		| Комиссия         | ₽ <Comission>               |  

#Step 8
	Given Set StartTime for DB search
	Given User clicks on "Подтвердить"

#Step 10
    Then User proceed payment in YandexMoney with user sazykin.y@yandex.ru password 4!tJ10VcmD
	Then Memorize eWallet section
	Given Set StartTime for DB search
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

#Step 12
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Make screenshot

	Given User closes multiform by clicking on "Закрыть"
	Then Redirected to /#/transfer/
	Then Wait for transactions loading
		Then eWallet updated sections are:
		| USD  | EUR  | RUB                |
		| 0.00 | 0.00 | -<AmountComission> |  
	
	Given User clicks on Отчеты menu
#STEP 13
	Given User see transactions list contains:
		| Date         | Name                                | Amount          |
		| **DD.MM.YY** | Комиссия за перевод в Яндекс.Деньги | - ₽ <Comission> |
		| **DD.MM.YY** | Перевод в Яндекс.Деньги             | - ₽ <Amount>    |  
				
    Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoneyFee' row № 0:
		| Column1      | Column2                                                                                                              |
		| Транзакция № | **TPurseTransactionId**                                                                                              |
		| Заказ №      | **InvoiceId**                                                                                                        |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                 |
		| Продукт      | e-Wallet <UserPurseId>                                                                                               |
		| Получатель   | <YandexMoneyWallet>                                                                                                  |
		| Сумма        | ₽ <Comission>                                                                                                        |
		| Детали       | Commission for outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. |     
	
	Given User see statement info for the UserId=<UserId> where DestinationId='OutgoingTransferToYandexMoney' row № 1:
		| Column1      | Column2                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                               |
		| Заказ №      | **InvoiceId**                                                                                         |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                  |
		| Продукт      | e-Wallet <UserPurseId>                                                                                |
		| Получатель   | <YandexMoneyWallet>                                                                                   |
		| Сумма        | ₽ <Amount>                                                                                            |
		| Детали       | Outgoing payment to Yandex.Money <YandexMoneyWallet> from e-Wallet <UserPurseId>. Details: <Details>. |  
	
#STEP 14    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Email       | 6        | <Email>                                                                                                                                                  | Отчет по операции №**Invoice** |
     | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6M | -                              |
     | PushIos     | 6        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e0                                                                                         | -                              |  

 
  @552633
  Examples:
      | Email                            | AmountComission | Comission | Amount | YandexMoneyWallet | User         | UserId                               | Password     | Details | UserPurseId |
      | receiveFromYandex@qa.swiftcom.uk | 10.20           | 0.20      | 10.00  | 410000000000      | +70080294751 | 23e54424-d8c6-4f24-afc5-fbe626780629 | 72621010Abac | Детали  | 001-002542  |    



	 
  
