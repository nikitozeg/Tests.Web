@CardDailyService
Feature: CardDailyService

@134954 
Scenario Outline: Списание при достаточности средств на карте
	Then User updates records in table 'Cards' on 'yesterday-1d time 00.00.00':
		| ProxyPANCode | CardServiceExpireAt          |
		| <Token>      | *yesterday-1d time 00.00.00* |  

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание карты ePayments не оплачено. Для продления обслуживания, пожалуйста, пополните кошелек на сумму в размере $ 2.9" appears on "USD" card
	Then Memorize eWallet section
	Then Memorize EPACards section
	Given Set StartTime for DB search
	
 	When User download and executes "CardMaintenance.DailyService"
	
	Then User refresh the page
	Then User clicks on CardAndAccounts
	
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid

	Then eWallet updated sections are:
		| USD  | EUR  | RUB  |
		| 0.00 | 0.00 | 0.00 |  
 	Then EPA cards updated sections are:
 		| USD   | EUR  |
 		| -2.90 | 0.00 |   

	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card
	Then Scale "" appears on "USD" card

	# https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-12.%D0%9F%D0%BB%D0%B0%D1%82%D0%B0%D0%B7%D0%B0%D0%BE%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5%D0%BA%D0%B0%D1%80%D1%82%D1%8BePayments
	##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount | Fee         |
 	  | 65              | 0.00   | <Comission> |  
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State     | Details                                     | SenderSystemId | SenderIdentity   | ReceiverSystemId | ReceiverIdentity      | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | Successed | Service fee for ePayments Card 5283****8028 | WaveCrest      | 5283xxxxxxxx8028 | WaveCrest        | 000-<EPS-06Exchanges> | Usd        | Card          | NotRecognized        | <UserId> |  
 
 	  
 	#QAA-550 (details is not checked)
    Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
 	  | Amount      | DestinationId  | Direction | UserId              | CurrencyId | PurseId           | RefundCount |
 	  | <Comission> | CardUnload     | in        | <UserId>            | Usd        | 1<UserPurseId>    | 0           |
 	  | <Comission> | CardServiceFee | out       | <UserId>            | Usd        | 1<UserPurseId>    | 0           |
 	  | <Comission> | CardServiceFee | in        | <SystemPurseUserId> | Usd        | <EPS-06Exchanges> | 0           |              
 	 
 	Then No records in 'LimitRecords'
 
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount      | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Comission> | Usd        | WaveCrest         | true                  |  
 	
 	##############################_Transactions_################################################


	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                         | Amount   |
		| **DD.MM.YY** | Обслуживание карты ePayments | - $ 2.90 |
		| **DD.MM.YY** | Перевод с карты ePayments    | $ 2.90   |
		| **DD.MM.YY** | Корректировка баланса        | - $ 2.90 |   

		
	Given User see statement info for the UserId=<UserId> where DestinationId='CardServiceFee' row № 0 direction='out':
		| Column1      | Column2                                     |
		| Транзакция № | **TPurseTransactionId**                     |
		| Заказ №      | **InvoiceId**                               |
		| Дата         | **dd.MM.yyyy HH:mm**                        |
		| Продукт      | e-Wallet 001-<UserPurseId>                  |
		| Получатель   | 000-<EPS-06Exchanges>                       |
		| Сумма        | $ 2.90                                      |
		| Детали       | Service fee for ePayments Card 5283****8028 |    

	Given User see statement info for the UserId=<UserId> where DestinationId='CardUnload' row № 1 direction='in':
		| Column1      | Column2                                      |
		| Транзакция № | **TPurseTransactionId**                      |
		| Заказ №      | **InvoiceId**                                |
		| Дата         | **dd.MM.yyyy HH:mm**                         |
		| Продукт      | e-Wallet 001-<UserPurseId>                   |
		| Получатель   | 000-<EPS-06Exchanges>                        |
		| Сумма        | $ 2.90                                       |
		| Детали       | Card unload from ePayments Card 5283****8028 |  

	Given User see statement info for ProxyPANCode='<Token>' with last operation row № 2:
		| Column1              | Column2                                                                           |
		| Статус               | Подтверждена                                                                      |
		| Транзакция №         | **TXn_ID**                                                                        |
		| Дата                 | **dd.MM.yyyy HH:mm**                                                              |
		| Продукт              | ePayments Card 5283 **** 8028                                                     |
		| Сумма в валюте карты | $ 2.90                                                                            |
		| Детали               | Balance transferred from PAN 5283****8028 to e-Wallet 001-<UserPurseId> (2.9 USD) |  



	Then User selects records in table 'Notification' where UserId="<UserId>" with "**date**" replacing:
		  | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                    |
		  | Email       | 8        | <User>                                                                                                                                                   | Обслуживание карты ePayments продлено до **date** |
		  | PushAndroid | 8        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                                        |
		  | PushIos     | 8        | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                                        |    
 

Examples:
	| UserPurseId | User                                  | UserId                               | Password     | Token     |  EPS-06Exchanges | Comission | SystemPurseUserId                    |
	| 995014      | carddailyserviceUItest@qa.swiftcom.uk | 5fac3887-b8aa-41b5-925c-a4bab828d9b6 | 72621010Abac | 170429623 |  121121          | 2.90      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  



	
@3520585 
Scenario Outline: Списание при достаточности средств на карте - без списания 
	Then User updates records in table 'Cards' on 'CurrentDate':
		| ProxyPANCode | CardServiceExpireAt |
		| <Token>      | *CurrentDate*       |  

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание:*currentDate*" with replacing currentDate

	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card
	Then Scale "" appears on "USD" card

	Then Memorize eWallet section
	Then Memorize EPACards section

	Given Set StartTime for DB search
	
 	When User download and executes "CardMaintenance.DailyService"
	
	Then User refresh the page
	Then User clicks on CardAndAccounts
	
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid

	Then eWallet updated sections are:
		| USD  | EUR  | RUB  |
		| 0.00 | 0.00 | 0.00 |     
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |   

	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card 
	Then Scale "" appears on "USD" card 
	
    Then User didn't receive Notifications for UserId="<UserId>"

Examples:
	| User                                  | UserId                               | Password     | Token     |
	| carddailyserviceUItest@qa.swiftcom.uk | 5fac3887-b8aa-41b5-925c-a4bab828d9b6 | 72621010Abac | 170429623 |



	@329216 
Scenario Outline: Списание при достаточности средств на кошельке
	Then User updates records in table 'Cards' on 'yesterday-1d time 00.00.00':
		| ProxyPANCode | CardServiceExpireAt          |
		| <Token>      | *yesterday-1d time 00.00.00* |  

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "EUR" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание карты ePayments не оплачено. Для продления обслуживания, пожалуйста, пополните кошелек на сумму в размере € 2.4" appears on "EUR" card
	
	Then Memorize eWallet section
	Then Memorize EPACards section

	Given Set StartTime for DB search
	
 	When User download and executes "CardMaintenance.DailyService"

	Then User refresh the page
	Then User clicks on CardAndAccounts
	
	Given User clicks on "Обслуживание:" "EUR" 'Epayments Cards' at CardAndAccounts grid

	Then eWallet updated sections are:
		| USD  | EUR   | RUB  |
		| 0.00 | -2.40 | 0.00 |    
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |  

	Then Message "Сумма € 2.4 будет списана автоматически в день окончания обслуживания." appears on "EUR" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на € 300" appears on "EUR" card
	Then Message "Сделано покупок на" appears on "EUR" card
	Then Message "0 / 300 EUR" appears on "EUR" card
	Then Scale "" appears on "EUR" card

	# https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-12.%D0%9F%D0%BB%D0%B0%D1%82%D0%B0%D0%B7%D0%B0%D0%BE%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5%D0%BA%D0%B0%D1%80%D1%82%D1%8BePayments
	##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount | Fee         |
 	  | 66              | 0.00   | <Comission> |    
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State     | Details                                     | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity      | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | Successed | Service fee for ePayments Card 5283****7346 | WaveCrest      | 001-<UserPurseId> | WaveCrest        | 000-<EPS-06Exchanges> | Eur        | Ewallet       | NotRecognized        | <UserId> |  
 
 	  
 	#QAA-550 (details is not checked)
    Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
 	  | Amount      | DestinationId  | Direction | UserId              | CurrencyId | PurseId           | RefundCount |
 	  | <Comission> | CardServiceFee | out       | <UserId>            | Eur        | 1<UserPurseId>    | 0           |
 	  | <Comission> | CardServiceFee | in        | <SystemPurseUserId> | Eur        | <EPS-06Exchanges> | 0           |              
 	 
 	Then No records in 'LimitRecords'
 
 	Then No records in 'TExternalTransactions'
 	##############################_Transactions_################################################

	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                         | Amount   |
		| **DD.MM.YY** | Обслуживание карты ePayments | - € 2.40 |

		
	Given User see statement info for the UserId=<UserId> where DestinationId='CardServiceFee' row № 0 direction='out':
		| Column1      | Column2                                     |
		| Транзакция № | **TPurseTransactionId**                     |
		| Заказ №      | **InvoiceId**                               |
		| Дата         | **dd.MM.yyyy HH:mm**                        |
		| Продукт      | e-Wallet 001-<UserPurseId>                  |
		| Получатель   | 000-<EPS-06Exchanges>                       |
		| Сумма        | € 2.40                                      |
		| Детали       | Service fee for ePayments Card 5283****7346 |    

	Then User selects records in table 'Notification' where UserId="<UserId>" with "**date**" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                    |
      | Email       | 8        | <User>                                                                                                                                                   | Обслуживание карты ePayments продлено до **date** |
      | PushAndroid | 8        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                                        |
      | PushIos     | 8        | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                                        |    
 

Examples:
	| UserPurseId | User                                             | UserId                               | Password     | Token     | EPS-06Exchanges | Comission | SystemPurseUserId                    |
	| 385999      | carddailyserviceUItestFromEwallet@qa.swiftcom.uk | 74f3d92e-f67c-4c19-bef2-5242cb1c3e1c | 72621010Abac | 421802315 | 121121          | 2.40      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |     



@3525516 
Scenario Outline: Списание при достаточности средств на кошельке - без списания 
	Then User updates records in table 'Cards' on 'CurrentDate':
		| ProxyPANCode | CardServiceExpireAt |
		| <Token>      | *CurrentDate*       |  

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "EUR" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Сумма € 2.4 будет списана автоматически в день окончания обслуживания." appears on "EUR" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на € 300" appears on "EUR" card
	Then Message "Сделано покупок на" appears on "EUR" card
	Then Message "0 / 300 EUR" appears on "EUR" card
	Then Scale "" appears on "EUR" card

	Then Memorize eWallet section
	Then Memorize EPACards section

	Given Set StartTime for DB search
	
 	When User download and executes "CardMaintenance.DailyService"

	Then User refresh the page
	Then User clicks on CardAndAccounts
	
	Given User clicks on "Обслуживание:" "EUR" 'Epayments Cards' at CardAndAccounts grid

	Then eWallet updated sections are:
		| USD  | EUR  | RUB  |
		| 0.00 | 0.00 | 0.00 |  
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |   

	Then Message "Сумма € 2.4 будет списана автоматически в день окончания обслуживания." appears on "EUR" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на € 300" appears on "EUR" card
	Then Message "Сделано покупок на" appears on "EUR" card
	Then Message "0 / 300 EUR" appears on "EUR" card
	Then Scale "" appears on "EUR" card

    Then User didn't receive Notifications for UserId="<UserId>"

Examples:
	| UserPurseId | User                                             | UserId                               | Password     | Token     |
	| 385999      | carddailyserviceUItestFromEwallet@qa.swiftcom.uk | 74f3d92e-f67c-4c19-bef2-5242cb1c3e1c | 72621010Abac | 421802315 |  


	
@2147332 
Scenario Outline:Уведомления о приближении даты списания средств за обслуживание карты 
	Then User updates records in table 'Cards' on 'CurrentDate+3days':
		| ProxyPANCode | CardServiceExpireAt |
		| <Token>      | *CurrentDate+3days* |   

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card
	Then Scale "" appears on "USD" card

	Then Memorize eWallet section
	Then Memorize EPACards section

	Given Set StartTime for DB search
	
 	#When User download and executes "CardMaintenance.DailyService"

	Then User refresh the page
	Then User clicks on CardAndAccounts
	
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid

	Then eWallet updated sections are:
		| USD  | EUR  | RUB  |
		| 0.00 | 0.00 | 0.00 |  
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |   

	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card
	Then Scale "" appears on "USD" card

	Then User clicks on notification ring with count='1' and see text 'Приближается срок списания платы за обслуживание карты ePayments'
	Then User delete all notification ring and see text 'У вас нет непрочитанных уведомлений'
	Then User selects records in table 'Notification' for UserId="<UserId>"
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                    |
      | Email       | 8        | <User>                                                                                                                                                   | Приближается срок списания платы за обслуживание карты ePayments |
      | PushAndroid | 8        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                                        |
      | PushIos     | 8        | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                                        |    
 
Examples:
	| User                                   | UserId                               | Password     | Token     |
	| 2147332carddailuservice@qa.swiftcom.uk | a812ad9a-7b96-4030-8b3a-a3bb641a9043 | 72621010Abac | 216613436 |  

