@Financial
Feature: Financial

 @135416
  Scenario Outline: Обмен валют EPA-6199

  # На секциях кошелька имеется определенное количество средств
  # Минимальные и максимальные лимиты для перевода установлены

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "Между своими счетами"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Со счета' selector set to 'USD' in eWallet section
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	Then 'На счет' selector set to 'EUR' in eWallet section
	Then Section 'Received amount' is: € 0.00 (Курс обмена: $ 1.00 = € **rate**)
	Then 'Отдаваемая сумма' set to '9.99' and unfocus
	Given User see limits table
		| Column1                        | Column2 |
		| Минимальная отдаваемая сумма:  | $ 10.00 |
		| Максимальная отдаваемая сумма: | нет     |  

	Then Validating message 'Отдаваемая сумма меньше  $ 10.00' appears on MultiForm
	Then 'Отдаваемая сумма' set to '1000001' and unfocus
	Then Validating message 'Отдаваемая сумма превышает баланс' appears on MultiForm
	Then 'Со счета' selector set to 'EUR' in eWallet section
	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)
	 Given 'На счет' selector is "Выберите счет" and contains:
     	| Options              |
    	| Выберите счет        |     
    	| USD                  |
    	| RUB                  |
    	| 5283 **** 3133,  EUR |
	
	 #USD->EUR

	Then 'Со счета' selector set to 'USD' in eWallet section
	Then 'На счет' selector set to 'EUR' in eWallet section
	Then 'Отдаваемая сумма' set to '10.00'
	Then Make screenshot
	Given User clicks on "Далее"
	Given User see table
		| Column1          | Column2                 |
		| Со счета         | USD, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | $ 10.00                 |
		| Получаемая сумма | € **amount * rate**     |  

	Given User clicks on "Назад"
	Then 'Отдаваемая сумма' set to '100.00'
	Then Section 'Received amount' is: € **amount * rate** (Курс обмена: $ 1.00 = € **rate**)
	Given User clicks on "Далее"

	Given User see table
		| Column1          | Column2                 |
		| Со счета         | USD, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | $ 100.00                |
		| Получаемая сумма | € **amount * rate**     |  
	Then Make screenshot
	Given Set StartTime for DB search
	Given User clicks on "Перевести"
	Then Success message "Обмен валют успешно выполнен×" appears
	Then Make screenshot
	Given User see quittance table
		| Column1          | Column2                 |
		| Операция         | Обмен валюты            |
		| Дата             | **yyyy-MM-dd HH:mm**    |
		| Статус           | Успешно                 |
		| Со счета         | USD, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | $ 100.00                |
		| Получаемая сумма | € **amount * rate**     |  
	Given User clicks on "Закрыть"	

  	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount            | DestinationId             | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | 100.00            | CurrencyExchangeUsdAndEur | out       | <UserId>            | Usd        | <UserPurseId>   | 0           |
   	  | 100.00            | CurrencyExchangeUsdAndEur | in        | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |
   	  | **amount * rate** | CurrencyExchangeUsdAndEur | out       | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |
   	  | **amount * rate** | CurrencyExchangeUsdAndEur | in        | <UserId>            | Eur        | <UserPurseId>   | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination      | UserId   | Amount | AmountInUsd   | Product   | ProductType |
	  | Usd        | out       | CurrencyExchange | <UserId> | 100.00 | **Generated** | <PurseId> | Epid        |    

	##############################_Transactions_################################################

	Then Redirected to /#/transfer/
	Then Wait for transactions loading
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                            | Amount              |
		| **DD.MM.YY** | Перевод между секциями кошелька | € **amount * rate** |
		| **DD.MM.YY** | Перевод между секциями кошелька | - $ 100.00          |   
				
	Given User see statement info for the UserId=<UserId> where DestinationId='CurrencyExchangeUsdAndEur' row № 0 direction='in' without invoice:
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                 |
		| Сумма        | € **amount * rate**                                |
		| Детали       | Currency exchange from USD to EUR. Rate = **rate** |  
		
	Given User see statement info for the UserId=<UserId> where DestinationId='CurrencyExchangeUsdAndEur' row № 1 direction='out' without invoice:
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                |
		| Сумма        | $ 100.00                                           |
		| Детали       | Currency exchange from USD to EUR. Rate = **rate** |   
		
    
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TPurseTransactionId** for currency exchange" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                             |
      | Email       | 6        | nikita_UI_financial@qa.swiftcom.uk                                                                                                                       | Отчет по операции № **TPurseTransactionId** for currency exchange |
      | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                                                                 |
      | PushIos     | 6        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                                                                 |  

  #RUB->EUR
  
	Given User clicks on Перевести menu
	Given User clicks on "Между своими счетами"

	Then 'Со счета' selector set to 'RUB' in eWallet section
	Then 'На счет' selector set to 'EUR' in eWallet section
	Then Section 'Received amount' is: € 0.00 (Курс обмена: ₽ 1.00 = € **rate**)

	Then 'Отдаваемая сумма' set to '100.00'

	Given User clicks on "Далее"

	Given User see table
		| Column1          | Column2                 |
		| Со счета         | RUB, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | ₽ 100.00                |
		| Получаемая сумма | € **amount * rate**     |  
	Given Set StartTime for DB search
	Given User clicks on "Перевести"
	Then Success message "Обмен валют успешно выполнен×" appears
	Given User see quittance table
		| Column1          | Column2                 |
		| Операция         | Обмен валюты            |
		| Дата             | **yyyy-MM-dd HH:mm**    |
		| Статус           | Успешно                 |
		| Со счета         | RUB, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | ₽ 100.00                |
		| Получаемая сумма | € **amount * rate**     |  
	Given User clicks on "Закрыть"	
	Then Redirected to /#/transfer/
	Then Wait for transactions loading
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                            | Amount              |
		| **DD.MM.YY** | Перевод между секциями кошелька | € **amount * rate** |
		| **DD.MM.YY** | Перевод между секциями кошелька | - ₽ 100.00          |  
		
	Given User see statement info for the UserId=<UserId> where DestinationId='CurrencyExchangeUsdAndEur' row № 0 direction='in' without invoice:
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                 |
		| Сумма        | € **amount * rate**                                |
		| Детали       | Currency exchange from RUB to EUR. Rate = **rate** |  
		
	Given User see statement info for the UserId=<UserId> where DestinationId='CurrencyExchangeUsdAndEur' row № 1 direction='out' without invoice:
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                |
		| Сумма        | ₽ 100.00                                           |
		| Детали       | Currency exchange from RUB to EUR. Rate = **rate** |   
  
  Examples:
      | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | SystemPurseId |
      | +70092039926 | f751650f-2754-4bc1-bf23-ce78f347764e | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1053655     | 001-053655 | 122122        |  



 @135417
  Scenario Outline: Пополнение карты GPS(Load)
  
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Пополнить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Given 'Со счета' selector is "USD" and contains:
    	| Options              |
    	| USD                  |
    	| EUR                  |
    	| RUB                  |
    	| 5283 **** 3024,  USD |
    	| 5283 **** 8626,  EUR |
    	| Выберите счет        |    
    
    Given 'На счет' selector is "5283 **** 3024,  USD" and contains:
    	| Options              |
    	| Выберите счет        |     
    	| EUR                  |
    	| RUB                  |
	    | 5283 **** 3024,  USD |
    
	Then 'Со счета' selector set to 'RUB'
    Given 'На счет' selector is "Выберите счет" and contains:
    	| Options              |
    	| Выберите счет        |     
    	| USD                  |
    	| EUR                  |
    
	Then 'Со счета' selector set to 'EUR' in eWallet section
    Given 'На счет' selector is "Выберите счет" and contains:
    	| Options              |
    	| Выберите счет        |     
    	| USD                  |
    	| RUB                  |
    	| 5283 **** 8626,  EUR |

	Then 'На счет' selector set to '5283 **** 8626,  EUR' in EPA cards section
    Given User see limits table
    	| Column1                      | Column2    |
    	| Минимальная сумма перевода:  | € 10.00    |
    	| Максимальная сумма перевода: | € 7 778.00 |
    	| Комиссия:                    | 0%         |  
    
	Then 'Сумма' set to '9.99'
	Then 'Сумма с комиссией' value is '9.99'
    Then Validating message 'Сумма перевода меньше  € 10.00' appears on MultiForm
	Then 'Сумма' set to '10000000'
	Then 'Сумма с комиссией' value is '10000000.00'
    Then Validating message 'Сумма с комиссией превышает баланс' appears on MultiForm

	Then 'Сумма с комиссией' set to '50'
    Then Make screenshot
	Given User clicks on "Далее"
	Given Set StartTime for DB search

	Given User see table
		| Column1           | Column2                          |
		| Со счета          | EUR, e-Wallet 001-881126         |
		| На счет           | EUR, ePayments Card 5283****8626 |
		| Сумма             | € 50.00                          |
		| Комиссия          | € 0.00                           |
		| Сумма с комиссией | € 50.00                          |     
	Then Make screenshot
	Given User clicks on "Назад"
	Then 'Сумма' value is '50.00'
	Then 'Сумма с комиссией' value is '50.00'

	Then 'Сумма' set to '<Amount>'
	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                          |
		| Со счета          | EUR, e-Wallet 001-881126         |
		| На счет           | EUR, ePayments Card 5283****8626 |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € 0.00                           |
		| Сумма с комиссией | € <Amount>                       |  
	Then Memorize eWallet section
	Then Memorize EPACards section

	Given User clicks on "Перевести"
	Then Success message "Ваша карта успешно пополнена×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод на карту ePayments       |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | EUR, e-Wallet 001-881126         |
		| На счет           | EUR, ePayments Card 5283****8626 |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € 0.00                           |
		| Сумма с комиссией | € <Amount>                       |    
	Given User clicks on "Закрыть"

	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <UserId>            | Eur        | <UserPurseId>   | 0           |
   	  | <Amount> | CardLoad      | in        | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Eur        | in        | CardLoad    | <UserId> | <Amount> | **Generated** | b217adcb-3111-46df-9513-d6d2fa739ee3 | Ecard       |
	  | Eur        | out       | CardLoad    | <UserId> | <Amount> | **Generated** | 001-881126                           | Epid        |  

	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Eur        | WaveCrest         | false                 |  
	##############################_Transactions_################################################

	Then eWallet updated sections are:
		| USD  | EUR       | RUB  |
		| 0.00 | -<Amount> | 0.00 |   
 	Then EPA cards updated sections are:
 		| USD  | EUR       |
 		| 0.00 | +<Amount> |  
	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                       | Amount       |
		| **DD.MM.YY** | Пополнение карты ePayments | - € <Amount> |
		| **DD.MM.YY** | Пополнение карты ePayments | € <Amount>   |  

	Then User gets record in 'EhiLog' where Token="422090221"
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                         |
     | Email       | 10        | <User>                                                                                                                                                   | Отчет по операции №**TXn_ID** |
     | PushAndroid | 10        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                             |
     | PushIos     | 10        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                             |  

	
     Examples:
      | User                                  | UserId                               | Password     | SystemPurseUserId                    | Amount | UserPurseId | SystemPurseId |
      | sendwireWithSmsConfirm@qa.swiftcom.uk | 72f549ea-7f00-4ff8-aa88-959c0f1cc3d2 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 10.00  | 1881126     | 1100          |  



	  @135418
  Scenario Outline: Вывод средств с карты GPS(Unload) - USD

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Снять" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Given 'Со счета' selector is "5283 **** 2959,  USD" and contains:
    	| Options              |
    	| USD                  |
    	| EUR                  |
    	| RUB                  |
		| 5283 **** 2959,  USD |
    	| 5283 **** 3094,  EUR |
    	| Выберите счет        |    
    
    Given 'На счет' selector is "USD" and contains:
    	| Options       |
    	| Выберите счет |
    	| USD           |  
    
    Given User see limits table
    	| Column1                      | Column2     |
    	| Минимальная сумма перевода:  | $ 10.00     |
    	| Максимальная сумма перевода: | $ 10 000.00 |
    	| Комиссия:                    | $ 1         |  
    Then Make screenshot
    Then 'Сумма' set to '<Amount>'
  	Given User clicks on "Далее"


	Given User see table
		| Column1           | Column2                          |
		| Со счета          | USD, ePayments Card 5283****2959 |
		| На счет           | USD, e-Wallet <PurseId>          |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ <Comission>                    |
		| Сумма с комиссией | $ <AmountWithComission>          |  
	Then Make screenshot
	Given Set StartTime for DB search

	Then Memorize eWallet section
	Then Memorize EPACards section

	Given User clicks on "Перевести"
	Then Success message "Ваш кошелек успешно пополнен×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод с карты ePayments        |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | USD, ePayments Card 5283****2959 |
		| На счет           | USD, e-Wallet <PurseId>          |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ <Comission>                    |
		| Сумма с комиссией | $ <AmountWithComission>          |       
	Given User clicks on "Закрыть"	
	
	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount                | DestinationId        | Direction | UserId      | CurrencyId | PurseId             | RefundCount |
   	  | <AmountWithComission> | CardUnload           | in        | <UserId>    | Usd        | <UserPurseId>       | 0           |
   	  | <Comission>           | CardUnloadCommission | out       | <UserId>    | Usd        | <UserPurseId>       | 0           |
   	  | <Comission>           | CardUnloadCommission | in        | <EPSUserId> | Usd        | <EPS-01Commissions> | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Usd        | out       | CardUnload  | <UserId> | <Amount> | **Generated** | 5b6f6945-0252-482e-b4e1-3baa5da4b291 | Ecard       |
	  | Usd        | in        | CardUnload  | <UserId> | <Amount> | **Generated** | <PurseId>                            | Epid        |  

	#QAA-550 (details is not checked)  
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount                | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <AmountWithComission> | Usd        | WaveCrest         | true                  |  
	##############################_Transactions_################################################


	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TPurseTransactionId**" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                      |
      | Email       | 5        | <User>                                                                                                                                                   | Отчет по операции №**TPurseTransactionId** |
      | PushAndroid | 5        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                                          |
      | PushIos     | 5        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                                          |  

	  	 Then eWallet updated sections are:
		| USD       | EUR  | RUB  |
		| +<Amount> | 0.00 | 0.00 |     
 	Then EPA cards updated sections are:
 		| USD                    | EUR  |
 		| -<AmountWithComission> | 0.00 |  
		Then Redirected to /#/transfer/
	Then Wait for transactions loading
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                              | Amount                    |
		| **DD.MM.YY** | Комиссия за пополнение кошелька с карты ePayments | - $ <Comission>           |
		| **DD.MM.YY** | Перевод с карты ePayments                         | - $ <AmountWithComission> |
		| **DD.MM.YY** | Перевод с карты ePayments                         | $ <AmountWithComission>   |  

	
     Examples:
      | User         | UserId                               | Password     | Amount | Comission | AmountWithComission | UserPurseId | PurseId    | EPSUserId                            | EPS-01Commissions |
      | unloadUSD@qa.swiftcom.uk | 6638e7ee-1a3d-46d7-bf2b-571bb2bf9647      | 72621010Abac | 20.00  | 1.00      | 21.00               | 1164710     | 001-164710 | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 


	   @2704361
  Scenario Outline: Вывод средств с карты GPS(Unload) - EUR

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Снять" "EUR" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)
	
	Given 'Со счета' selector is "5283 **** 3133,  EUR" and contains:
    	| Options              |
    	| USD                  |
    	| EUR                  |
    	| RUB                  |
    	| 5283 **** 9772,  USD |
    	| 5283 **** 3133,  EUR |
    	| Выберите счет        |      
    
    Given 'На счет' selector is "EUR" and contains:
    	| Options       |
    	| Выберите счет |
    	| EUR           |  
    
    Given User see limits table
    	| Column1                      | Column2     |
    	| Минимальная сумма перевода:  | € 10.00     |
    	| Максимальная сумма перевода: | € 7 778.00  |
    	| Комиссия:                    | € 1         |   
    Then Make screenshot
    Then 'Сумма' set to '<Amount>'
  	Given User clicks on "Далее"


	Given User see table
		| Column1           | Column2                          |
		| Со счета          | EUR, ePayments Card 5283****3133 |
		| На счет           | EUR, e-Wallet <PurseId>          |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € <Comission>                    |
		| Сумма с комиссией | € <AmountWithComission>          |  
	Then Make screenshot
	Given Set StartTime for DB search
	Given User clicks on "Перевести"
	Then Success message "Ваш кошелек успешно пополнен×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод с карты ePayments        |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | EUR, ePayments Card 5283****3133 |
		| На счет           | EUR, e-Wallet <PurseId>          |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € <Comission>                    |
		| Сумма с комиссией | € <AmountWithComission>          |     
	Given User clicks on "Закрыть"	
	
	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount                | DestinationId        | Direction | UserId      | CurrencyId | PurseId       | RefundCount |
   	  | <AmountWithComission> | CardUnload           | in        | <UserId>    | Eur        | <UserPurseId> | 0           |
   	  | <Comission>           | CardUnloadCommission | in        | <EPSUserId> | Eur        | 406604        | 0           |
   	  | <Comission>           | CardUnloadCommission | out       | <UserId>    | Eur        | <UserPurseId> | 0           |   

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Eur        | out       | CardUnload  | <UserId> | <Amount> | **Generated** | 0394c5d4-e6e7-4204-8da5-93e239e5625e | Ecard       |
	  | Eur        | in        | CardUnload  | <UserId> | <Amount> | **Generated** | <PurseId>                            | Epid        |  

	#QAA-550 (details is not checked)  
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount                | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <AmountWithComission> | Eur        | WaveCrest         | true                  |  
	##############################_Transactions_################################################

	Then Redirected to /#/transfer/
	Then Wait for transactions loading
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                              | Amount                    |
		| **DD.MM.YY** | Комиссия за пополнение кошелька с карты ePayments | - € <Comission>           |
		| **DD.MM.YY** | Перевод с карты ePayments                         | - € <AmountWithComission> |
		| **DD.MM.YY** | Перевод с карты ePayments                         | € <AmountWithComission>   |   

	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TPurseTransactionId**" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                      |
      | Email       | 5        | nikita_UI_financial@qa.swiftcom.uk                                                                                                                       | Отчет по операции №**TPurseTransactionId** |
      | PushAndroid | 5        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                                          |
      | PushIos     | 5        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                                          |  

     Examples:
      | User         | UserId                               | Password     | Amount | Comission | AmountWithComission | UserPurseId | PurseId    | EPSUserId                            |
      | +70092039926 | f751650f-2754-4bc1-bf23-ce78f347764e | 72621010Abac | 10.00  | 1.00      | 11.00               | 1053655     | 001-053655 | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |   


    
  

	  
	  @433739
  Scenario Outline: Антифрод
  
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Получить menu
	Given User clicks on "С банковской карты"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Given 'На счет' selector is "USD" and contains:
    	| Options              |
    	| USD                  |
    	| EUR                  |
    	| RUB                  |

	Then User fills CardDetails:
		| CardNumber       | CardExpireAt | CVC | CardHolder         |
		| 5413330000000019 | 01/20        | 589 | Firstname LastName |   

	Then 'Сумма' set to '10'
	Then Section 'Amount including fees' is: $ 10.26 (Комиссия: $ 0.26)
    
    Then Make screenshot

	Given User clicks on "Далее"
	Given Set StartTime for DB search

	Given User see table
		| Column1           | Column2                  |
		| На счет           | USD, e-Wallet 001-070590 |
		| Банковская карта  | Mastercard, x0019        |
		| Сумма             | $ 10.00                  |
		| Комиссия          | $ 0.26                   |
		| Сумма с комиссией | $ 10.26                  |  
	Then Make screenshot
	Given User clicks on "Подтвердить"
	
	Then User gets message "Операция отклонена" on Multiform
	Then User gets message "Требуется подтвердить владение картой 5413 33** **** 0019. Пожалуйста, загрузите фотографию карты в меню "Настройки" " on Multiform
	Then User gets message "Проверка карты занимает 1-2 дня. Вы получите уведомление о верификации карты по email." on Multiform

	Given User clicks on "Закрыть"

    Then User selects records in 'FraudOperationCheckLogs' by last FraudOperationLog where UserId="<UserId>":
   	  | ClassName                     | HasRisk | AddedWeight | Error |
   	  | CountryRiskChecker            | true    | 40          |       |
   	  | LevensteinChecker             | true    | 40          |       |
   	  | CardWasUsed                   | true    | 40          |       |
   	  | IpAndCardCountry              | true    | 10          |       |
   	  | UserAndCardCountry            | true    | 30          |       |    
   	  | LastSuccessfulOperationDate   | true    | 10          |       |    

	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver | Title                          |
     | Email       | 10       | <User>   | Отчет по операции №**Invoice** |   

	
	Examples:
      | User                             | UserId                               | Password     | Amount |
      | ui_antifrod_test2@qa.swiftcom.uk | 7947ada5-d6b5-4cdb-86e0-5853fc013425 | 72621010Abac | 10.00  |     


	  
	  
  Scenario Outline: Списание за обслуживание с кошелька
#STEP 1 Авторизоваться под пользователем с картой с истёкшим сроком обслуживания

   Then User updates records in table 'Cards' and set CardServicePeriod:
 		| ProxyPANCode | CardServicePeriod   |
 		| <Token>      | <CardServicePeriod> |  

     Then User updates records in table 'Cards' and set CardServicePaid:
  		| ProxyPANCode | CardServicePaid |
  		| <Token>      | NotPaid         |  
 
 	Then User updates records in table 'Cards' on 'yesterday-1d time 00.00.00':
 		| ProxyPANCode | CardServiceExpireAt          |
 		| <Token>      | *yesterday-1d time 00.00.00* |  
 
    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

	Then User clicks on CardAndAccounts
 	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
 	Then Message "Обслуживание:*today-2d*" with replacing today-2d
 	Then Message "Обслуживание карты ePayments не оплачено. Для продления обслуживания, пожалуйста, пополните кошелек на сумму в размере $ 2.9" appears on "USD" card

#STEP 2 С кошелька списывается сумма за оплату обслуживания карты
 	Then Memorize eWallet section

 	Given User clicks on Перевести menu
 	Given User clicks on "Между своими счетами"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	
 	 #RUB->USD
 
 	Then 'Со счета' selector set to 'RUB' in eWallet section
 	Then 'На счет' selector set to 'USD' in eWallet section
 	Then Section 'Received amount' is: $ 0.00 (Курс обмена: ₽ 1.00 = $ **rate**)
 
 	Then 'Получаемая сумма' set to '100.00'
 
 	Given User clicks on "Далее"
 
 	Given Set StartTime for DB search
 
 	Given User see table
 		| Column1          | Column2                         |
 		| Со счета         | RUB, e-Wallet 001-<UserPurseId> |
 		| На счет          | USD, e-Wallet 001-<UserPurseId> |
 		| Курс обмена      | **rate**                        |
 		| Отдаваемая сумма | ₽ **amount / rate**             |
 		| Получаемая сумма | $ 100.00                        |  
 	Given User clicks on "Перевести"
 	Then Success message "Обмен валют успешно выполнен×" appears

 	Given User clicks on "Закрыть"	
 	Then Redirected to /#/transfer/

#Step 3 
   	##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount | Fee         |
 	  | 65              | 0.00   | <Comission> |  
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State     | Details                               | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity       | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | Successed | Service fee for ePayments Card <Card> | WaveCrest      | 001-<UserPurseId> | WaveCrest        | 000-<EPA-01Comissions> | Usd        | EWallet       | NotRecognized        | <UserId> |  
 	  
 	#QAA-550 (details is not checked)
    Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
 	  | Amount      | DestinationId  | Direction | UserId              | CurrencyId | PurseId            | RefundCount |
 	  | <Comission> | CardServiceFee | out       | <UserId>            | Usd        | 1<UserPurseId>     | 0           |
 	  | <Comission> | CardServiceFee | in        | <SystemPurseUserId> | Usd        | <EPA-01Comissions> | 0           |        
 	 
 	Then No records in 'LimitRecords'
 
 	Then No records in 'TExternalTransactions'
 	
 	##############################_Transactions_################################################

# С кошелька списывается сумма за оплату обслуживания карты
 	Then eWallet updated USD section is:
		| USD   | 
		| +97.1 | 

#Step 4
 	Then Wait for transactions loading
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                            | Amount                |
 		| **DD.MM.YY** | Обслуживание карты ePayments    | - $ <Comission>       |
 		| **DD.MM.YY** | Перевод между секциями кошелька | $ 100.00              |
 		| **DD.MM.YY** | Перевод между секциями кошелька | - ₽ **amount / rate** |  
 
 	 Given User see statement info for the UserId=<UserId> where DestinationId='CardServiceFee' row № 0 direction='out':
 		| Column1      | Column2                               |
 		| Транзакция № | **TPurseTransactionId**               |
 		| Заказ №      | **InvoiceId**                         |
 		| Дата         | **dd.MM.yyyy HH:mm**                  |
 		| Продукт      | e-Wallet 001-<UserPurseId>            |
 		| Получатель   | 000-<EPA-01Comissions>                |
 		| Сумма        | $ <Comission>                         |
 		| Детали       | Service fee for ePayments Card <Card> |  
 	
#Статус карты по обслуживанию сервиса Paid, дата истечения срока продлена на 1 месяц
 	Then User clicks on CardAndAccounts
 	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
 	Then Message "Обслуживание:30.07.18" with replacing on current month
 	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
 
#Step 5 https://confluence.swiftcom.uk/pages/viewpage.action?pageId=23989777#id-%D0%A4%D0%B8%D0%BD%D0%B0%D0%BD%D1%81%D0%BE%D0%B2%D1%8B%D0%B5%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D0%B8-card_epa_service6.8.%D0%9E%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5%D0%BA%D0%B0%D1%80%D1%82%D1%8B
 
 	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TPurseTransactionId** for currency exchange and date" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                                      |
      | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции № **TPurseTransactionId** for currency exchange and date |
      | PushAndroid | 6        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                                                                          |
      | PushIos     | 6        | 81954f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                                                                          |
      | Email       | 8        | <User>                                                                                                                                                   | Обслуживание карты ePayments продлено до 30.xx.2018                        |
      | PushAndroid | 8        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                                                                          |
      | PushIos     | 8        | 81954f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e2                                                                                         | -                                                                          |   
 	 
# Ежемесячное обслуживание (TCards.CardServicePeriod =0)
@2949602
 Examples:
  | Card         | CardServicePeriod | User                            | UserId                               | Password     | Amount | Token     | UserPurseId | Comission | EPA-01Comissions | SystemPurseUserId                    |
  | 5283****9658 | false             | spisanie_za_obsl@qa.swiftcom.uk | 20b9a472-8eb5-417c-8d8e-918a5443715a | 72621010Abac | 100.00 | 107085023 | 871452      | 2.90      | 121121           | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  

# Годовое обслуживание (TCards.CardServicePeriod =1)
@433736
 Examples:
  | Card         | CardServicePeriod | User                            | UserId                               | Password     | Amount | Token     | UserPurseId | Comission | EPA-01Comissions | SystemPurseUserId                    |
  | 5283****9658 | true              | spisanie_za_obsl@qa.swiftcom.uk | 20b9a472-8eb5-417c-8d8e-918a5443715a | 72621010Abac | 100.00 | 107085023 | 871452      | 2.90      | 121121           | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |   


  
 @433738 
Scenario Outline: Пополнение с внешней банковской карты

	#Step 1
	Given User goes to SignIn page
	Given User signin "Epayments" with "0609guzel@qa.swiftcom.uk" password "Qwerty@0609"
	Given User see Account Page
	Given User clicks on Получить menu
	
	#Step 2
	Given User clicks on "С банковской карты"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Given 'На счет' selector is "USD" and contains:
    	| Options              |
    	| USD                  |
    	| EUR                  |
    	| RUB                  |
		
	#Step 3	
	Then User fills CardDetails:
		| CardNumber | CardExpireAt | CVC | CardHolder         |
		| <CardPAN>  | 01/20        | 589 | Firstname LastName |  

	Then 'Сумма' set to '<Amount>'
	Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ 0.26)
    Then Make screenshot

	Given User clicks on "Далее"
	Given Set StartTime for DB search

	Given User see table
		| Column1           | Column2                 |
		| На счет           | USD, e-Wallet <PurseId> |
		| Банковская карта  | Mastercard, x0019       |
		| Сумма             | $ <Amount>              |
		| Комиссия          | $ <Comission>           |
		| Сумма с комиссией | $ <AmountComission>     |    
	Then Make screenshot
	Given User clicks on "Подтвердить"

	#Step 4/5
    Then User proceed payment on MasterCard side with entering secure code
	Then User gets message "Обработка платежа займет несколько минут" on Multiform
	Then User gets message "Перевод принят, средства зачислены на баланс кошелька" on Multiform
    Then User redirected to account page

	#Step 6
	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                                           | Amount   |
 		| **DD.MM.YY** | Комиссия за входящий платеж с банковской карты | - $ 0.26 |
 		| **DD.MM.YY** | Входящий платеж с банковской карты             | $ 10.26  |    

	Given User see statement info for the UserId=<UserId> where DestinationId='RefillPurseFromExternalCardCommission' row № 0 direction='out':
 		| Column1      | Column2                                                                |
 		| Транзакция № | **TPurseTransactionId**                                                |
 		| Заказ №      | **InvoiceId**                                                          |
 		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
 		| Продукт      | e-Wallet <PurseId>                                                     |
 		| Получатель   | <PurseId>                                                              |
 		| Сумма        | $ <Comission>                                                          |
 		| Детали       | Commission for incoming payment from sided bank card MasterCard, x0019 |   

    Given User see statement info for the UserId=<UserId> where DestinationId='RefillPurseFromExternalCard' row № 1 direction='in':
 		| Column1      | Column2                                                  |
 		| Транзакция № | **TPurseTransactionId**                                  |
 		| Заказ №      | **InvoiceId**                                            |
 		| Дата         | **dd.MM.yyyy HH:mm**                                     |
 		| Продукт      | e-Wallet <PurseId>                                       |
 		| Получатель   | <PurseId>                                                |
 		| Сумма        | $ <AmountComission>                                      |
 		| Детали       | Incoming payment from sided bank card MasterCard, x0019. | 
			

	#Step 7

	#1.1.1 https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059
	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 51              | <Amount> | <Comission> |  

	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details                                                             | SenderSystemId | SenderIdentity      | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed | Add funds to e-wallet 000-454286 with bank card 5413 33** **** 0019 | Rietumu        | 5413 33** **** 0019 | WaveCrest        | <PurseId>        | Usd        | BankCard      | Purse                | <UserId> |    
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount            | DestinationId                         | Direction | UserId      | CurrencyId | PurseId                       | RefundCount |
	  | <AmountComission> | RefillPurseFromExternalCard           | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <AmountComission> | RefillPurseFromExternalCard           | out       | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
	  | <AmountComission> | RefillPurseFromExternalCard           | in        | <UserId>    | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillPurseFromExternalCardCommission | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
	  | <Comission>       | RefillPurseFromExternalCardCommission | in        | <EPSUserId> | Usd        | <EPS-01Commissions>			 | 0           |  
	 
	#EPA-6073
	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination                 | UserId   | Amount            | AmountInUsd   | Product   | ProductType |
	  | Usd        | in        | IncomingPaymentFromSidedBankCard | <UserId> | <AmountComission> | **Generated** | 000-454286 | Epid        |    
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount            | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <AmountComission> | Usd        | Rietumu           | true                  |  

	   ##############################_Transactions_################################################

	#STEP 8/9   
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                          |
     | Email       | 10       | 0609guzel@qa.swiftcom.uk                                                                                                                                 | Отчет по операции №**Invoice** |
     | PushAndroid | 10       | ftxRvwJltHs:APA91bHOt4NzBDRdxgNBd-e_QR_8f_7zD_HmnQh-OUMqKcGXatigFHVPQudsDS01EBd9Vu9ITOyUY_ZyzTbCDhK5EhTKbphwCtTQIGiRJMwZWZxkUZ3lAqSdoiGHJu9uY47YsPqBdWrX | -                              |
     | PushIos     | 10       | df9ead6dd3e79e617fa527eb570ecdbd89f560c1e9a0d6ccb94043ea866ce05c                                                                                         | -                              |  


 Examples:

   | CardPAN          | Amount | Comission | AmountComission | UserId                               | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 5413330000000019 | 10.00  | 0.26      | 10.26           | 356d33bd-e126-440c-9b9a-fe3fb1a27314 | 454286      | 000-454286 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  




    @135431
  Scenario Outline: Криптовалюта(котировки)

  # На секциях кошелька имеется определенное количество средств
  # Минимальные и максимальные лимиты для перевода установлены

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "На криптовалютный кошелек"

	Given 'Со счета' selector is "USD" and contains:
    	| Options       |
    	| USD           |  
    	| EUR           |  
    

	Then Section 'Amount including fees' contains: '0 BTC (Курс обмена: 1 BTC =' and 'Комиссия сети:' for BTC
	Then 'Получатель' selector set to 'EURS'
	Then Section 'Amount including fees' contains: '0 EURS (Курс обмена: 1 EURS =' and 'Комиссия сети:' for EURS

	Then 'Получатель' selector set to 'BTG'
	Then Section 'Amount including fees' contains: '0 BTG (Курс обмена: 1 BTG =' and 'Комиссия сети:' for BTG

	Then 'Получатель' selector set to 'BCH'
	Then Section 'Amount including fees' contains: '0 BCH (Курс обмена: 1 BCH =' and 'Комиссия сети:' for BCH
	
	Then 'Получатель' selector set to 'ETH'
	Then Section 'Amount including fees' contains: '0 ETH (Курс обмена: 1 ETH =' and 'Комиссия сети:' for ETH

	Then 'Получатель' selector set to 'USDT'
	Then Section 'Amount including fees' contains: '0 USDT (Курс обмена: 1 USDT =' and 'Комиссия сети:' for USDT

	Then 'Получатель' selector set to 'LTC'
	Then Section 'Amount including fees' contains: '0 LTC (Курс обмена: 1 LTC =' and 'Комиссия сети:' for LTC

	Then 'Со счета' selector set to 'EUR'

	Then 'Получатель' selector set to 'BTC'
	Then Section 'Amount including fees' contains: '0 BTC (Курс обмена: 1 BTC =' and 'Комиссия сети:' for BTC
	
	Then 'Получатель' selector set to 'EURS'
	Then Section 'Amount including fees' contains: '0 EURS (Курс обмена: 1 EURS =' and 'Комиссия сети:' for EURS

	Then 'Получатель' selector set to 'BTG'
	Then Section 'Amount including fees' contains: '0 BTG (Курс обмена: 1 BTG =' and 'Комиссия сети:' for BTG

	Then 'Получатель' selector set to 'BCH'
	Then Section 'Amount including fees' contains: '0 BCH (Курс обмена: 1 BCH =' and 'Комиссия сети:' for BCH

	Then 'Получатель' selector set to 'ETH'
	Then Section 'Amount including fees' contains: '0 ETH (Курс обмена: 1 ETH =' and 'Комиссия сети:' for ETH

	Then 'Получатель' selector set to 'USDT'
	Then Section 'Amount including fees' contains: '0 USDT (Курс обмена: 1 USDT =' and 'Комиссия сети:' for USDT

	Then 'Получатель' selector set to 'LTC'
	Then Section 'Amount including fees' contains: '0 LTC (Курс обмена: 1 LTC =' and 'Комиссия сети:' for LTC


  Examples:
      | User         | Password     | 
      | +70092039926 |  72621010Abac| 



	   @688031
  Scenario Outline: Зависший CardLoad (CloseCardLoad) - EUR
  
  #Step 1
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Пополнить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	Then 'Со счета' selector set to 'EUR' in eWallet section

	Then 'На счет' selector set to '5283 **** 6603,  EUR' in EPA cards section
    Given User see limits table
    	| Column1                      | Column2    |
    	| Минимальная сумма перевода:  | € 10.00    |
    	| Максимальная сумма перевода: | € 7 778.00 |
    	| Комиссия:                    | 0%         |  
    Given Set StartTime for DB search
	Then 'Сумма' set to '<Amount>'
	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                          |
		| Со счета          | EUR, e-Wallet 001-792991         |
		| На счет           | EUR, ePayments Card 5283****6603 |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € 0.00                           |
		| Сумма с комиссией | € <Amount>                       |  
	Then Memorize eWallet section
	Then Memorize EPACards section

	Given User clicks on "Перевести"
	Then Success message "Ваша карта успешно пополнена×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод на карту ePayments       |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | EUR, e-Wallet 001-792991         |
		| На счет           | EUR, ePayments Card 5283****6603 |
		| Сумма             | € <Amount>                       |
		| Комиссия          | € 0.00                           |
		| Сумма с комиссией | € <Amount>                       |    
	Given User clicks on "Закрыть"

	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <UserId>            | Eur        | <UserPurseId>   | 0           |
   	  | <Amount> | CardLoad      | in        | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Eur        | in        | CardLoad    | <UserId> | <Amount> | **Generated** | e47a1fad-dc74-4614-ab4d-a706d5e7392c | Ecard       |
	  | Eur        | out       | CardLoad    | <UserId> | <Amount> | **Generated** | 001-792991                           | Epid        |  

	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Eur        | WaveCrest         | false                 |  
	##############################_Transactions_################################################

	Then eWallet updated sections are:
		| USD  | EUR       | RUB  |
		| 0.00 | -<Amount> | 0.00 |   

	Then Redirected to /#/transfer/

	Then User gets record in 'EhiLog' where Token="421775597"
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                         |
     | Email       | 10       | <User>                                                                                                                                                   | Отчет по операции №**TXn_ID** |
     | PushAndroid | 10       | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                             |
     | PushIos     | 10       | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                             |  
	 Given Set StartTime for DB search
	 #Step 2-3-4
	 Then Mark cardload as failed
	
	 #Step 5-6
     Then Operator pushed on CloseCardLoad

	 #Step 6
	 Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Eur        | <SystemPurseId> | 0           |    
	 
	 Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Eur        | WaveCrest         | false                 |
	    
	Then CardLoad status is true
	
	Then User didn't receive Notifications for UserId="<UserId>"

     Examples:
      | User                        | UserId                               | Password     | SystemPurseUserId                    | Amount | UserPurseId | SystemPurseId |
      | cardloaduser@qa.swiftcom.uk | 515e8853-c1bf-4ec8-8299-19f7fce2bfd3 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 10.00  | 1792991     | 1100          |  




	  	   @3597456
  Scenario Outline: Зависший CardLoad (Refund) - USD
  
  #Step 1
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Пополнить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
		    
	Then 'Со счета' selector set to 'USD' in eWallet section

	Then 'На счет' selector set to '5283 **** 1112,  USD' in EPA cards section
    Given User see limits table
    	| Column1                      | Column2    |
    	| Минимальная сумма перевода:  | $ 10.00    |
    	| Максимальная сумма перевода: | $ 15 000.00 |
    	| Комиссия:                    | 0%         |  
    Given Set StartTime for DB search
	Then 'Сумма' set to '<Amount>'
	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                          |
		| Со счета          | USD, e-Wallet 001-347229         |
		| На счет           | USD, ePayments Card 5283****1112 |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ 0.00                           |
		| Сумма с комиссией | $ <Amount>                       |  
	Then Memorize eWallet section
	Then Memorize EPACards section

	Given User clicks on "Перевести"
	Then Success message "Ваша карта успешно пополнена×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод на карту ePayments       |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | USD, e-Wallet 001-347229         |
		| На счет           | USD, ePayments Card 5283****1112 |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ 0.00                           |
		| Сумма с комиссией | $ <Amount>                       |    
	Given User clicks on "Закрыть"

	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <UserId>            | Usd        | <UserPurseId>   | 0           |
   	  | <Amount> | CardLoad      | in        | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Usd        | in        | CardLoad    | <UserId> | <Amount> | **Generated** | c362b556-f1d5-4b2e-a783-ff05008e47da | Ecard       |
	  | Usd        | out       | CardLoad    | <UserId> | <Amount> | **Generated** | 001-347229                           | Epid        |  

	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Usd        | WaveCrest         | false                 |  
	##############################_Transactions_################################################

	Then eWallet updated sections are:
		| USD       | EUR  | RUB  |
		| -<Amount> | 0.00 | 0.00 |     
 
	Then Redirected to /#/transfer/

	Then User gets record in 'EhiLog' where Token="204266834"
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                         |
     | Email       | 10        | <User>                                                                                                                                                   | Отчет по операции №**TXn_ID** |
     | PushAndroid | 10        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                             |
     | PushIos     | 10        | 5b9226dd520a42fdb72a4f8029fd8f216d6fbceed9154cb6be28ef21282e6283                                                                                        | -                             |  
	Given Set StartTime for DB search

#Step 2-3-4
	Then Mark cardload as failed
	Given Set StartTime for DB search

#Step 5-6
     Then Operator pushed on Refund transactions

#Step 6
	 Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Usd        | <SystemPurseId> | 1           |
   	  | <Amount> | CardLoad      | in        | <UserId>			   | Usd        | <UserPurseId>   | 1           |      
	 Then No records in 'LimitRecords'
	 Then No new records in 'TExternalTransactions'
	 Given User clicks on Отчеты menu
	 Given User see transactions list contains:
		| Date         | Name                       | Amount     |
		| **DD.MM.YY** | Пополнение карты ePayments | $ <Amount> |  

	Then CardLoad status is true
	Then eWallet updated sections are:
		| USD    | EUR  | RUB  |
		| +10.00 | 0.00 | 0.00 |    
	
	Then User selects records in table 'Notification' for UserId="<UserId>"
     | MessageType | Priority | Receiver                                                                                                                                                 | Title |
     | PushAndroid | 10       | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -     |
     | PushIos     | 10       | 5b9226dd520a42fdb72a4f8029fd8f216d6fbceed9154cb6be28ef21282e6283                                                                                         | -     |  


     Examples:
      | User                           | UserId                               | Password     | SystemPurseUserId                    | Amount | UserPurseId | SystemPurseId |
      | cardloadrefunda@qa.swiftcom.uk | 6a40a71a-60c8-4bab-89f6-f9cb1eea697d | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 10.00  | 1347229     | 1100          |    



	  	   @3597457
  Scenario Outline: Зависший CardLoad (Reload Funds) - USD
  
  #Step 1
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Then User clicks on CardAndAccounts
	Given User clicks on "Пополнить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	
	    
	Then 'Со счета' selector set to 'USD' in eWallet section

	Then 'На счет' selector set to '5283 **** 4117,  USD' in EPA cards section
    Given User see limits table
    	| Column1                      | Column2    |
    	| Минимальная сумма перевода:  | $ 10.00    |
    	| Максимальная сумма перевода: | $ 15 000.00 |
    	| Комиссия:                    | 0%         |  
    Given Set StartTime for DB search
	Then 'Сумма' set to '<Amount>'
	Given User clicks on "Далее"
	Given User see table
		| Column1           | Column2                          |
		| Со счета          | USD, e-Wallet 001-056555         |
		| На счет           | USD, ePayments Card 5283****4117 |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ 0.00                           |
		| Сумма с комиссией | $ <Amount>                       |  
	Then Memorize eWallet section

	Given User clicks on "Перевести"
	Then Success message "Ваша карта успешно пополнена×" appears
	Given User see quittance table
		| Column1           | Column2                          |
		| Операция          | Перевод на карту ePayments       |
		| Дата              | **yyyy-MM-dd HH:mm**             |
		| Статус            | Успешно                          |
		| Со счета          | USD, e-Wallet 001-056555         |
		| На счет           | USD, ePayments Card 5283****4117 |
		| Сумма             | $ <Amount>                       |
		| Комиссия          | $ 0.00                           |
		| Сумма с комиссией | $ <Amount>                       |    
	Given User clicks on "Закрыть"

	##############################_Transactions_################################################
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <UserId>            | Usd        | <UserPurseId>   | 0           |
   	  | <Amount> | CardLoad      | in        | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |    

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId   | Amount   | AmountInUsd   | Product                              | ProductType |
	  | Usd        | in        | CardLoad    | <UserId> | <Amount> | **Generated** | 5e4e1434-05cf-4190-ab13-36d4558e947d | Ecard       |
	  | Usd        | out       | CardLoad    | <UserId> | <Amount> | **Generated** | 001-056555                           | Epid        |  

	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Usd        | WaveCrest         | false                 |  
	##############################_Transactions_################################################

	Then eWallet updated sections are:
		| USD       | EUR  | RUB  |
		| -<Amount> | 0.00 | 0.00 |     
 
	Then Redirected to /#/transfer/

	Then User gets record in 'EhiLog' where Token="204209067"
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                         |
     | Email       | 10        | <User>                                                                                                                                                   | Отчет по операции №**TXn_ID** |
     | PushAndroid | 10        | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                             |
     | PushIos     | 10        | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                             |  
	  Given Set StartTime for DB search
#Step 2-3-4
	Then Mark cardload as failed
	Given Set StartTime for DB search

#Step 5-6
     Then Operator pushed on Reload Funds

#Step 6
	 Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount   | DestinationId | Direction | UserId              | CurrencyId | PurseId         | RefundCount |
   	  | <Amount> | CardLoad      | out       | <SystemPurseUserId> | Usd        | <SystemPurseId> | 0           |
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Usd        | WaveCrest         | false                 | 
	    
  	Given User clicks on Отчеты menu
	Then Wait because of different server time
	Given User see transactions list contains:
		| Date         | Name                       | Amount       |
		| **DD.MM.YY** | Пополнение карты ePayments | $ <Amount>   |
		| **DD.MM.YY** | Пополнение карты ePayments | - $ <Amount> |
		| **DD.MM.YY** | Пополнение карты ePayments | $ <Amount>   |   

	Then CardLoad status is true
  
	
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                         |
     | Email       | 10       | <User>                                                                                                                                                   | Отчет по операции №**TXn_ID** |
     | PushAndroid | 10       | cLCkHIt77Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzdkk7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPY59W6kz-38FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra6N | -                             |
     | PushIos     | 10       | 81944f64ce084e09720cd74a746708cb450c1c10db847ae57c69f58aa2d947e9                                                                                         | -                             |  


     Examples:
      | User                               | UserId                               | Password     | SystemPurseUserId                    | Amount | UserPurseId | SystemPurseId |
      | reloadFundscardload@qa.swiftcom.uk | d483f05a-d214-4978-b073-8f410cf5e808 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 10.00  | 1056555     | 1100          |    



Scenario Outline: Списание за обслуживание с карты
#STEP 1 Авторизоваться под пользователем с картой с истёкшим сроком обслуживания

   Then User updates records in table 'Cards' and set CardServicePeriod:
 		| ProxyPANCode | CardServicePeriod   |
 		| <Token>      | <CardServicePeriod> |  

     Then User updates records in table 'Cards' and set CardServicePaid:
  		| ProxyPANCode | CardServicePaid |
  		| <Token>      | NotPaid         |  

 	Then User updates records in table 'Cards' on 'yesterday-1d time 00.00.00':
		| ProxyPANCode | CardServiceExpireAt           |
		| <Token>      | *yesterday-1d time 00.00.00* |  

     Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

		Then User clicks on CardAndAccounts
 	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
 	Then Message "Обслуживание:*today-2d*" with replacing today-2d
 	Then Message "Обслуживание карты ePayments не оплачено. Для продления обслуживания, пожалуйста, пополните кошелек на сумму в размере $ 2.9" appears on "USD" card

#STEP 2 С кошелька списывается сумма за оплату обслуживания карты
 	Then Memorize eWallet section
 	Then Memorize EPACards section
	 	Given Set StartTime for DB search

 	 Then Partner load on Token = <Token>
	 Then Wait for transactions loading

#Step 3 
   	##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount | Fee         |
 	  | 65              | 0.00   | <Comission> |  
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State     | Details                               | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity       | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | Successed | Service fee for ePayments Card <Card> | WaveCrest      | 5283xxxxxxxx0207  | WaveCrest        | 000-<EPA-01Comissions> | Usd        | Card          | NotRecognized        | <UserId> |  
 
 	  
 	#QAA-550 (details is not checked)
    Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
 	  | Amount      | DestinationId  | Direction | UserId              | CurrencyId | PurseId            | RefundCount |
 	  | <Comission> | CardUnload     | in        | <UserId>            | Usd        | <UserPurseId>      | 0           |
 	  | <Comission> | CardServiceFee | out       | <UserId>            | Usd        | <UserPurseId>      | 0           |
 	  | <Comission> | CardServiceFee | in        | <SystemPurseUserId> | Usd        | <EPA-01Comissions> | 0           |   
 	 
 	Then No records in 'LimitRecords'
 

	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount      | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Comission> | Usd        | WaveCrest         | true                 |   
 	
 	##############################_Transactions_################################################

# С карты списывается сумма за оплату обслуживания карты
	Then User refresh the page
 

#Step 4
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                             | Amount          |
 		| **DD.MM.YY** | Обслуживание карты ePayments     | - $ <Comission> |

 #	Then eWallet updated sections are:
 #        | USD  | EUR  | RUB  |
 #        | 0.00 | 0.00 | 0.00 |  
 	Then EPA cards updated sections are:
 		| USD    | EUR  |
 		| +97.10 | 0.00 |  
 
     Given User see statement info for the UserId=<UserId> where DestinationId='CardServiceFee' row № 0 direction='out':
 		| Column1      | Column2                               |
 		| Транзакция № | **TPurseTransactionId**               |
 		| Заказ №      | **InvoiceId**                         |
 		| Дата         | **dd.MM.yyyy HH:mm**                  |
 		| Продукт      | e-Wallet 001-108542			       |
 		| Получатель   | 000-<EPA-01Comissions>                |
 		| Сумма        | $ <Comission>                         |
 		| Детали       | Service fee for ePayments Card <Card> |  
 	
#Статус карты по обслуживанию сервиса Paid, дата истечения срока продлена на 1 месяц
 	Then User clicks on CardAndAccounts
 	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
 	Then Message "Обслуживание:30.06.18" with replacing month
 	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
 
#Step 5 https://confluence.swiftcom.uk/pages/viewpage.action?pageId=23989777#id-%D0%A4%D0%B8%D0%BD%D0%B0%D0%BD%D1%81%D0%BE%D0%B2%D1%8B%D0%B5%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D0%B8-card_epa_service6.8.%D0%9E%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5%D0%BA%D0%B0%D1%80%D1%82%D1%8B
 
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**date**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                                             |
     | Email       | 10       | <User>                                                                                                                                                   | -                                                 |
     | PushAndroid | 6        | cLCkHIt61Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                                                 |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d947e2                                                                                         | -                                                 |
     | Email       | 8        | <User>                                                                                                                                                   | Обслуживание карты ePayments продлено до **date** |
     | PushAndroid | 8        | cLCkHIt61Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                                                 |
     | PushIos     | 8        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d947e2                                                                                         | -                                                 |  
 	 
# Ежемесячное обслуживание (TCards.CardServicePeriod =0)
@433737
 Examples:
  | Card         | CardServicePeriod | User                                    | UserId                               | Password     | Amount | Token     | UserPurseId | Comission | EPA-01Comissions | SystemPurseUserId                    |
  | 5283****0207 | false             | spisanie_za_obsl_s_karty@qa.swiftcom.uk | 977d6c33-e74a-436c-9b7e-b9fc6e2f6b69 | 72621010Abac | 100.00 | 110537447 | 1108542      | 2.90      | 121121           | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  

# Годовое обслуживание (TCards.CardServicePeriod =1)
@3663175
 Examples:
  | Card         | CardServicePeriod | User								       | UserId                               | Password     | Amount | Token     | UserPurseId | Comission | EPA-01Comissions | SystemPurseUserId                    |
  | 5283****0207 | true              | spisanie_za_obsl_s_karty@qa.swiftcom.uk | 977d6c33-e74a-436c-9b7e-b9fc6e2f6b69 | 72621010Abac | 100.00  | 110537447 | 1108542      | 2.90      | 121121           | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  

#  #(недост. баланс на карте и достаточный на кошельке)
# @3663176
#  Examples:
#   | Card         | CardServicePeriod | User								       | UserId                               | Password     | Amount | Token     | UserPurseId | Comission | EPA-01Comissions | SystemPurseUserId                    |
#   | 5283****9923 | true              | spisanie_obsl_skarty@qa.swiftcom.uk     | 4f7cc066-c5d0-4ec8-9991-d2022e172842 | 72621010Abacc | 100.00  | 209708270 | 1863705      | 2.90      | 121121           | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  


@3414976
Scenario Outline: Вывод средств на мобильные телефоны
		Given User goes to SignIn page
		Given User signin "Epayments" with "<User>" password "<Password>"
		Given User see Account Page
	
		Given User clicks on Перевести menu
		Given User clicks on "На мобильный телефон"
		Then Section 'Amount including fees' is: ₽ 0.00 (Комиссия: ₽ 0.00)

#Step1
		Then 'Со счета' selector set to 'RUB' in eWallet section
		Then 'Оператор' selector set to 'MTS'
		Then 'Телефон' set to '<PhoneNumber>'
		Then 'Получаемая сумма' selector set to 'RUB'
		Then 'Отдаваемая сумма' set to '<Amount>'

		Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

		Given User see limits table
		| Column1                       | Column2     |
		| Минимальная сумма перевода:   | ₽ 1.00      |
		| Максимальная сумма перевода:  | ₽ 5 000.00  |
		| Максимальная дневная сумма:   | ₽ 15 000.00 |
		| Максимальная сумма за 30 дн.: | ₽ 60 000.00 |
		| Количество операций в день:   | 5           |
		| Комиссия:                     | 2%          |

#Step2
		Then 'Со счета' selector set to 'EUR' in eWallet section
		Then Section 'Amount including fees' is: € <AmountComission> (Комиссия: € <Comission>)
		Then Currency rate placeholder appears

#Step3
		Then 'Со счета' selector set to 'USD' in eWallet section
		Then Section 'Amount including fees' is: $ <AmountComission> (Комиссия: $ <Comission>)
		Then Currency rate placeholder appears

#Step4
		Then 'Со счета' selector set to 'RUB' in eWallet section
		Then Section 'Amount including fees' is: ₽ <AmountComission> (Комиссия: ₽ <Comission>)

		Given User clicks on "Далее"
		Given User see table
				| Column1           | Column2                 |
				| Отправитель       | RUB, e-Wallet <PurseId> |
				| Получатель        | +7<PhoneNumber>         |
				| Сумма             | ₽ <Amount>              |
				| Комиссия          | ₽ <Comission>           |
				| Сумма с комиссией | ₽ <AmountComission>     |
				| Получаемая сумма  | ₽ <Amount>              |  
		
		Given Set StartTime for DB search

#Step5
		Given User clicks on button "Подтвердить"
		Then User type SMS sent to:
			| OperationType | Recipient | UserId   | IsUsed |
			| MassPayment   | <User>    | <UserId> | false  |

		Then Memorize eWallet section
		Given User clicks on "Оплатить"
		Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
		Then User gets message "Платеж отправлен и находится в обработке. Срок зачисления средств может составлять от нескольких минут до нескольких дней. Вы получите уведомление по e-mail о результатах" on Multiform

#Step6 

		Then Make screenshot
		Given User closes multiform by clicking on "Закрыть"

		Given User clicks on Отчеты menu
		Given User see transactions list contains:
			| Date         | Name                                            | Amount          |
			| **DD.MM.YY** | Комиссия за перевод на счет мобильного телефона | - ₽ <Comission> |
			| **DD.MM.YY** | Перевод на счет мобильного телефона             | - ₽ <Amount>    |  

		Given User see statement info for the UserId=<UserId> where DestinationId='RefillMobileFromPurseFee' row № 0 direction='out':
			| Column1      | Column2                                                                                         |
			| Транзакция № | **TPurseTransactionId**                                                                         |
			| Заказ №      | **InvoiceId**                                                                                   |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                            |
			| Продукт      | e-Wallet <PurseId>                                                                              |
			| Получатель   | +7<PhoneNumber>                                                                                 |
			| Сумма        | ₽ <Comission>                                                                                   |
			| Детали       | Commission for outgoing payment for mobile service MTS +7<PhoneNumber> from e-Wallet <PurseId>. |   
	
		Given User see statement info for the UserId=<UserId> where DestinationId='RefillMobileFromPurse' row № 1 direction='out':
			| Column1      | Column2                                                                                                                |
			| Транзакция № | **TPurseTransactionId**                                                                                                |
			| Заказ №      | **InvoiceId**                                                                                                          |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                   |
			| Продукт      | e-Wallet <PurseId>                                                                                                     |
			| Получатель   | +7<PhoneNumber>                                                                                                        |
			| Сумма        | ₽ <Amount>                                                                                                             |
			| Детали       | Outgoing payment for mobile service MTS +7<PhoneNumber> from e-Wallet <PurseId>.                                       |   

		Then Preparing records in 'InvoicePositions':
			| OperationTypeId | Amount   | Fee         |
			| 227             | <Amount> | <Comission> |  
	
		Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
			| State                         | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity    | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
			| WaitingForAutomaticAdmission  |         | WaveCrest      | <PurseId>      | BankQiwi         | +7<PhoneNumber>     | Rub        | EWallet       | Purse                | <UserId> |  

	   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
			| Amount            | DestinationId                    | Direction | UserId              | CurrencyId | PurseId                       | RefundCount |
			| <Amount>          | RefillMobileFromPurse            | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |
			| <Amount>          | RefillMobileFromPurse            | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
			| <Comission>       | RefillMobileFromPurseFee         | in        | <EPSUserId>         | Rub        | <EPS-02TemporaryStoragePurse> | 0           |
			| <Comission>       | RefillMobileFromPurseFee         | out       | <UserId>            | Rub        | <UserPurseId>                 | 0           |

		Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
			| CurrencyId | Direction | Destination               | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
			| Rub        | out       | RefillMobileFromPurse     | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |  

		Then No records in 'TExternalTransactions'	

Examples:
   | PhoneNumber      | Amount | Comission	| AmountComission | User         | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | PurseId    | EPS-02TemporaryStoragePurse | EPS-06Exchanges | EPS-01Commissions | EPSUserId                            |
   | 0011234567       | 60.00  | 1.20		| 61.20           | +70008971335 | 85f871a2-69e6-406e-a90c-4f642105942a | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1697462     | 001-697462 | 144177                      | 122122          | 406604            | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  



   Scenario Outline: Валидация формы ввода смс кода при подтверждении фин.операции V2
	Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

#Step 1  	
 	Given User clicks on Перевести menu

#Step 2
 	Given User clicks on "Другому человеку"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Then 'Получатель' selector set to 'Телефон'

#Step 3 
 	Then 'Получатель' set to '+70006533256'
 	Then 'Отдаваемая сумма' set to '10.00'
  	Then Section 'Amount including fees' is: $ 11.00 (Комиссия: $ 1.00)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1           | Column2                       |
 		| Со счета          | USD, e-Wallet <SenderPurseId> |
 		| Получатель        | +70006533256                   |
 		| Отдаваемая сумма  | $ 10.00                       |
 		| Комиссия          | $ 1.00                        |
 		| Сумма с комиссией | $ 11.00                       |
 		| Получаемая сумма  | $ 10.00                       |      
 	Given Set StartTime for DB search
 	Given User clicks on "Подтвердить" on Multiform

#Step 4
	Given Button "Оплатить" is Disabled
 	Then User gets message "Отправить код повторно" on Multiform
 	Given User clicks on "Отправить код повторно" on Multiform
 
 #Step 5
 	Then User gets message "Отправить код повторно" on Multiform
 	Given User clicks on "Отправить код повторно" on Multiform
 
 	Then User gets message "Отправить код повторно" on Multiform
 	Given Set StartTime for DB search
 
 	Given User clicks on "Отправить код повторно" on Multiform
 
 	Then User gets message "Отправить код повторно" on Multiform
 	Given User clicks on "Отправить код повторно" on Multiform
 
 	Then Alert Message "Код подтверждения отправлен" appears
    Then User type SMS sent to:
		| OperationType           | Recipient    | UserId   | IsUsed |
		| MassPayment			  | +70006533256 | <UserId> | false  |    


#Step 6
 	Given User clicks on "Оплатить" on Multiform
 	Then User gets message "Платеж успешно отправлен" on Multiform
 	 	                                                        
   	@3286397
Examples:
      | ReceiverPurse | SenderPhone  | Comission | Amount | User                                | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
      | 000-637140    | +70027804391 | 1.00      | 10.00  | v2smsinternalpayment@qa.swiftcom.uk | 7d6d9819-9be1-47cd-8193-a4798274d39f | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-063756    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  
