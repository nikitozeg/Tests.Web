@Financial_production
Feature: Financial

 @3459425
  Scenario Outline: Обмен валют 

  # На секциях кошелька имеется определенное количество средств
  # Минимальные и максимальные лимиты для перевода установлены

    Given User goes to SignIn page
	Given User signin production "Epayments" with "<User>"
	Given User see Account Page
	
	Given User clicks on Перевести menu
	Given User clicks on "Между своими счетами"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	
 	Then 'Со счета' selector set to 'USD' in eWallet section
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Then 'На счет' selector set to 'EUR' in eWallet section
 	Then Section 'Received amount' is: € 0.00 (Курс обмена: $ 1.00 = € **rate**)
 	Then 'Отдаваемая сумма' set to '0.09' and unfocus
 	Given User see limits table
 		| Column1                        | Column2 |
 		| Минимальная отдаваемая сумма:  | $ 0.10 |
 		| Максимальная отдаваемая сумма: | нет     |  
 
 	Then Validating message 'Отдаваемая сумма меньше  $ 0.10' appears on MultiForm
 	Then 'Отдаваемая сумма' set to '1000001' and unfocus
 	Then Validating message 'Отдаваемая сумма превышает баланс' appears on MultiForm
 	Then 'Со счета' selector set to 'EUR' in eWallet section
 	Then Section 'Amount including fees' is: € 0.00 (Комиссия: € 0.00)
 	 Given 'На счет' selector is "Выберите счет" and contains:
      	| Options              |
     	| Выберите счет        |     
     	| USD                  |
     	| RUB                  |
 		| 5283 **** 6884,  EUR |

 #USD->EUR
 
 	Then 'Со счета' selector set to 'USD' in eWallet section
 	Then 'На счет' selector set to 'EUR' in eWallet section
 	Then 'Отдаваемая сумма' set to '1.00'
 	Then Make screenshot
 	Given User clicks on "Далее"
 	Given User see table
 		| Column1          | Column2                 |
 		| Со счета         | USD, e-Wallet <PurseId> |
 		| На счет          | EUR, e-Wallet <PurseId> |
 		| Курс обмена      | **rate**                |
 		| Отдаваемая сумма | $ 1.00                  |
 		| Получаемая сумма | € **amount * rate**     |   
 
 	Given User clicks on "Назад"
 	Then Section 'Received amount' is: € **amount * rate** (Курс обмена: $ 1.00 = € **rate**)
 	Given User clicks on "Далее"
 
 	Given User see table
 		| Column1          | Column2                 |
 		| Со счета         | USD, e-Wallet <PurseId> |
 		| На счет          | EUR, e-Wallet <PurseId> |
 		| Курс обмена      | **rate**                |
 		| Отдаваемая сумма | $ 1.00                  |
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
 		| Отдаваемая сумма | $ 1.00                  |
 		| Получаемая сумма | € **amount * rate**     | 
		
 	Given User clicks on "Закрыть"	
 	Then Redirected to /#/transfer/
 	Then Wait for transactions loading
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                            | Amount              |
 		| **DD.MM.YY** | Перевод между секциями кошелька | € **amount * rate** |
 		| **DD.MM.YY** | Перевод между секциями кошелька | - $ 1.00            |     
 					
 	Given User see statement info for production user where DestinationId='CurrencyExchangeUsdAndEur' row № 0 direction='in':
			| Column1      | Column2                                            |
			| Транзакция № | **TPurseTransactionId**                            |
			| Дата         | **dd.MM.yyyy HH:mm**                               |
			| Продукт      | e-Wallet <PurseId>                                 |
			| Сумма        | € **amount * rate**                                |
			| Детали       | Currency exchange from USD to EUR. Rate = **rate** |    
 		
     Given User see statement info for production user where DestinationId='CurrencyExchangeUsdAndEur' row № 1 direction='out':
			| Column1      | Column2                                            |
			| Транзакция № | **TPurseTransactionId**                            |
			| Дата         | **dd.MM.yyyy HH:mm**                               |
			| Продукт      | e-Wallet <PurseId>                                 |
			| Сумма        | $ 1.00                                             |
			| Детали       | Currency exchange from USD to EUR. Rate = **rate** |    

#  #RUB->EUR
  
	Given User clicks on Перевести menu
	Given User clicks on "Между своими счетами"

	Then 'Со счета' selector set to 'RUB' in eWallet section
	Then 'На счет' selector set to 'EUR' in eWallet section
	Then Section 'Received amount' is: € 0.00 (Курс обмена: ₽ 1.00 = € **rate**)

	Then 'Отдаваемая сумма' set to '10.00'
	Given User clicks on "Далее"

	Given User see table
		| Column1          | Column2                 |
		| Со счета         | RUB, e-Wallet <PurseId> |
		| На счет          | EUR, e-Wallet <PurseId> |
		| Курс обмена      | **rate**                |
		| Отдаваемая сумма | ₽ 10.00                 |
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
		| Отдаваемая сумма | ₽ 10.00                 |
		| Получаемая сумма | € **amount * rate**     |  

	Given User clicks on "Закрыть"	
	Then Redirected to /#/transfer/
	Then Wait for transactions loading

	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                            | Amount              |
		| **DD.MM.YY** | Перевод между секциями кошелька | € **amount * rate** |
		| **DD.MM.YY** | Перевод между секциями кошелька | - ₽ 10.00           |   
		
			
    Given User see statement info for production user where DestinationId='CurrencyExchangeUsdAndEur' row № 0 direction='in':
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                 |
		| Сумма        | € **amount * rate**                                |
		| Детали       | Currency exchange from RUB to EUR. Rate = **rate** |  
		
    Given User see statement info for production user where DestinationId='CurrencyExchangeUsdAndEur' row № 1 direction='out':
		| Column1      | Column2                                            |
		| Транзакция № | **TPurseTransactionId**                            |
		| Дата         | **dd.MM.yyyy HH:mm**                               |
		| Продукт      | e-Wallet <PurseId>                                 |
		| Сумма        | ₽ 10.00                                            |
		| Детали       | Currency exchange from RUB to EUR. Rate = **rate** |    
  
  Examples:
      | User                |  PurseId    |
      | sazykin.y@yandex.ru |  000-658262 |  


