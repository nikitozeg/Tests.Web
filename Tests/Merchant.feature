@Merchant
Feature: Merchant


Scenario Outline: Мерчант. Оплата с кошелька
	Given Set StartTime for DB search
    Then User proceed payment in Merchant page with user <Email> password 72621010Abac from <paymentSource> with amount=<Amount>

	Then User type SMS sent to:
		| OperationType           | Recipient          | UserId   | IsUsed |
		| PaymentOperationConfirm | <paymentCodePhone> | <UserId> | false  |  
	Given Set StartTime for DB search
	Then Check merchant quittance for amount=<Amount>
	 Given User goes to SignIn page
	Given User signin "Epayments" with "<Email>" password "72621010Abac"

		
  	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 75              | <Amount> | 0.00      |  
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	 | State     | Details                                                                | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	 | Successed | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> | WaveCrest      | <UserPurseId>  | WaveCrest        | 000-749103       | Usd        | EWallet       | Purse                | <UserId> |  

	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount      | DestinationId             | Direction | UserId                               | CurrencyId | PurseId             | RefundCount |
   	  | <Amount>    | MerchantInvoice           | out       | <UserId>                             | Usd        | <ShortUserPurseId>  | 0           |
   	  | <Amount>    | MerchantInvoice           | in        | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | out       | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | in        | <EPSUserId>                          | Usd        | <EPS-01Commissions> | 0           |     
   	 

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId                               | Amount   | AmountInUsd   | Product       | ProductType |
	  | Usd        | out       | Merchant    | <UserId>                             | <Amount> | **Generated** | <UserPurseId> | Epid        |
	  | Usd        | in        | Merchant    | A85CDDF0-B134-4D95-9FAA-A2471231A594 | <Amount> | **Generated** | 000-749103    | Epid        |  

	##############################_Transactions_################################################
	
	Given User clicks on Отчеты menu

	Given User see transactions list contains:
		| Date         | Name                   | Amount    |
		| **DD.MM.YY** | Оплата товаров и услуг | - $ <Amount> |  
				
    Given User see statement info for the UserId=<UserId> where DestinationId='MerchantInvoice' row № 0 direction='out':
		| Column1      | Column2                                                                |
		| Транзакция № | **TPurseTransactionId**                                                |
		| Заказ №      | **InvoiceId**                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
		| Продукт      | e-Wallet <UserPurseId>                                                 |
		| Получатель   | 000-749103                                                             |
		| Сумма        | $ <Amount>                                                             |
		| Детали       | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> |      
	
	Then User selects records in table 'Notification' for UserId="<UserId>"
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                                        |
     | Email       | 7        | <Email>                                                                                                                                                  | Оплата инвойса №Yjinqhsxfv от Fix test grupe |
     | PushAndroid | 13       | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                            |
     | PushIos     | 13       | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                            |  
	Then User selects records in table 'Notification' for UserId="A85CDDF0-B134-4D95-9FAA-A2471231A594"
     | MessageType | Priority | Receiver                   | Title                                        |
     | Email       | 7        | partnertest@qa.swiftcom.uk | Оплата инвойса №Yjinqhsxfv от Fix test grupe |  
	 
	 #С кошелька через Платежный пароль
	@349934
	 Examples:
     | paymentCodePhone | PaymentWay       |  paymentSource | Email                         | Comission | Amount | UserId                               | EPSUserId                            | ShortUserPurseId | UserPurseId | EPS-01Commissions | Details         |
     | 123455           | payment password |e-Wallet      | merchantUItest@qa.swiftcom.uk | 0.30      | 10.00  | baf684f4-04d0-4df8-a175-ebf339e2f2b5 | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 1698519          | 001-698519  | 406604            | this is details |  


	   #С кошелька через СМС
	@3254411
	 Examples:
      | paymentCodePhone | PaymentWay       | paymentSource | Email                               | Comission | Amount | UserId                               | EPSUserId                            | ShortUserPurseId | UserPurseId | EPS-01Commissions | Details         |
      | +70078471786     | SMS code sent to  |  e-Wallet      | merchantBYewalletSMS@qa.swiftcom.uk | 0.30      | 10.00  | 5cb9fcf6-e987-46e7-b89e-5855b146c2b7| 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 1442633          | 001-442633  | 406604            | this is details |  


	
Scenario Outline: Мерчант. Оплата с карты с balance adjustment
	Given Set StartTime for DB search
    Then User proceed payment in Merchant page with user <Email> password 72621010Abac from <paymentSource> with amount=<Amount>
	
	Then User type SMS sent to:
		| OperationType           | Recipient          | UserId   | IsUsed |
		| PaymentOperationConfirm | <paymentCodePhone> | <UserId> | false  |  
	 Then Wait because of different server time
	Given Set StartTime for DB search
	
      Then Wait because of different server time
	Then Check merchant quittance for amount=<Amount> 

    Given User goes to SignIn page
	Given User signin "Epayments" with "<Email>" password "72621010Abac"

		
  	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 75              | <Amount> | 0.00      |  
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	 | State     | Details                                                                | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	 | Successed | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> | WaveCrest      | <SenderIdentity>  | WaveCrest        | 000-749103       | Usd        | Card       | Purse                | <UserId> |  

	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount      | DestinationId             | Direction | UserId                               | CurrencyId | PurseId             | RefundCount |
   	  | <Amount>    | CardUnload		        | in       | <UserId>                              | Usd        | <ShortUserPurseId>  | 0           |
   	  | <Amount>    | MerchantInvoice           | out       | <UserId>                             | Usd        | <ShortUserPurseId>  | 0           |
   	  | <Amount>    | MerchantInvoice           | in        | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | out       | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | in        | <EPSUserId>                          | Usd        | <EPS-01Commissions> | 0           |     
   	 

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId                               | Amount   | AmountInUsd   | Product    | ProductType |
	  | Usd        | out       | Merchant    | <UserId>                             | <Amount> | **Generated** | <Product>  | Ecard       |
	  | Usd        | in        | Merchant    | A85CDDF0-B134-4D95-9FAA-A2471231A594 | <Amount> | **Generated** | 000-749103 | Epid        |  

	  #QAA-550 (details is not checked) 
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Usd        | WaveCrest       | true                 |    
	##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu

	Given User see transactions list contains:
		| Date         | Name                      | Amount       |
		| **DD.MM.YY** | Оплата товаров и услуг    | - $ <Amount> |
		| **DD.MM.YY** | Перевод с карты ePayments | $ <Amount>   |
		| **DD.MM.YY** | Корректировка баланса     | - $ <Amount> |  
				
    Given User see statement info for the UserId=<UserId> where DestinationId='MerchantInvoice' row № 0 direction='out':
		| Column1      | Column2                                                                |
		| Транзакция № | **TPurseTransactionId**                                                |
		| Заказ №      | **InvoiceId**                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
		| Продукт      | e-Wallet <UserPurseId>                                                 |
		| Получатель   | 000-749103                                                             |
		| Сумма        | $ <Amount>                                                             |
		| Детали       | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> |      
	
	  Given User see statement info for the UserId=<UserId> where DestinationId='CardUnload' row № 1 direction='in':
		| Column1      | Column2                                                                |
		| Транзакция № | **TPurseTransactionId**                                                |
		| Заказ №      | **InvoiceId**                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
		| Продукт      | e-Wallet <UserPurseId>                                                 |
		| Получатель   | 000-749103                                                             |
		| Сумма        | $ <Amount>                                                             |
		| Детали       | Card unload from ePayments Card <MaskedPan>							 | 

		
        Given User see statement info for ProxyPANCode='<ProxyPANCode>' with last operation row № 2:
		| Column1              | Column2                                                                  |
		| Статус               | Подтверждена                                                             |
		| Транзакция №         | **TXn_ID**                                                               |
		| Дата                 | **dd.MM.yyyy HH:mm**                                                     |
		| Продукт              | ePayments Card <MaskedPan2>                                                   |
		| Сумма в валюте карты | $ <Amount>                                                               |
		| Детали               | Balance transferred from PAN <MaskedPan> to e-Wallet <UserPurseId> (5 USD) |  

	Then User selects records in table 'Notification' for UserId="<UserId>"
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                                        |
     | Email       | 7        | <Email>                                                                                                                                                  | Оплата инвойса №Yjinqhsxfv от Fix test grupe |
     | PushAndroid | 13        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                            |
     | PushIos     | 13        | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                            |  
 
	Then User selects records in table 'Notification' for UserId="A85CDDF0-B134-4D95-9FAA-A2471231A594"
     | MessageType | Priority | Receiver                   | Title                                        |
     | Email       | 7        | partnertest@qa.swiftcom.uk | Оплата инвойса №Yjinqhsxfv от Fix test grupe |   

	#С карты через Платежный пароль
	 @349933
	 Examples:
	   | paymentCodePhone | PaymentWay       | SenderIdentity   | MaskedPan    | MaskedPan2     | ProxyPANCode | paymentSource    | Email                            | Comission | Amount | UserId                               | EPSUserId                            | ShortUserPurseId | UserPurseId | EPS-01Commissions | Details         | Product                              |
	   | 123455           | payment password | 5283xxxxxxxx4050 | 5283****4050 | 5283 **** 4050 | 146735655    | e-Payments Card: | merchantPayByCard@qa.swiftcom.uk | 0.15      | 5.00   | 98bf8ee1-9730-4d61-8742-84ea38f7568f | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 1306584          | 001-306584  | 406604            | this is details | 01ca90dc-98bd-43e8-af90-00240be61c7b |   
 
 
	 #С карты через СМС
	 @3408050
	Examples:
	   | paymentCodePhone | PaymentWay       | SenderIdentity   | MaskedPan    | MaskedPan2     | ProxyPANCode | paymentSource    | Email                          | Comission | Amount | UserId                               | EPSUserId                            | ShortUserPurseId | UserPurseId | EPS-01Commissions | Details         | Product                              |
	   | +70035725809     | SMS code sent to | 5283xxxxxxxx5985 | 5283****5985 | 5283 **** 5985 | 146689242    | e-Payments Card: | merchantSMScard@qa.swiftcom.uk | 0.15      | 5.00   | d15cc2ba-0821-4aa9-a197-14462d1682a4 | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 1509221          | 001-509221  | 406604            | this is details | a942cb00-e980-47fc-a6bc-536e36fe36d5 |  




   	
Scenario Outline: Мерчант. Оплата с карты подтверждение PUSH с CardUnload
	Given Set StartTime for DB search
    Then User proceed payment in Merchant page with user <Email> password 72621010Abac from <paymentSource> with amount=<Amount>
	
	Then User type PushCode sent to:
		| OperationType           | Recipient          | UserId   | IsUsed |
		| PaymentOperationConfirm | <paymentCodePhone> | <UserId> | false  |  
	 Then Wait because of different server time
	Given Set StartTime for DB search
	
	Then Check merchant quittance for amount=<Amount> 

    Given User goes to SignIn page
	Given User signin "Epayments" with "<Email>" password "72621010Abac"

		
  	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 75              | <Amount> | 0.00      |  
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	 | State     | Details                                                                | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	 | Successed | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> | WaveCrest      | <SenderIdentity>  | WaveCrest        | 000-749103       | Usd        | Card       | Purse                | <UserId> |  

	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
   	  | Amount      | DestinationId             | Direction | UserId                               | CurrencyId | PurseId             | RefundCount |
   	  | <Amount>    | CardUnload				  | in       | <UserId>                             | Usd        | <ShortUserPurseId>  | 0           |
   	  | <Amount>    | MerchantInvoice           | out       | <UserId>                             | Usd        | <ShortUserPurseId>  | 0           |
   	  | <Amount>    | MerchantInvoice           | in        | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | out       | A85CDDF0-B134-4D95-9FAA-A2471231A594 | Usd        | 749103              | 0           |
   	  | <Comission> | MerchantServiceCommission | in        | <EPSUserId>                          | Usd        | <EPS-01Commissions> | 0           |     
   	 

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination | UserId                               | Amount   | AmountInUsd   | Product    | ProductType |
	  | Usd        | out       | Merchant    | <UserId>                             | <Amount> | **Generated** | <Product>  | Ecard       |
	  | Usd        | in        | Merchant    | A85CDDF0-B134-4D95-9FAA-A2471231A594 | <Amount> | **Generated** | 000-749103 | Epid        |  

	  #QAA-550 (details is not checked) 
	 #Ext.transation is not checked because of [EPA-6127]
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount   | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <Amount> | Usd        | WaveCrest       | true                 |    
	##############################_Transactions_################################################

	
	Given User clicks on Отчеты menu

	Given User see transactions list contains:
		| Date         | Name                      | Amount       |
		| **DD.MM.YY** | Оплата товаров и услуг    | - $ <Amount> |
		| **DD.MM.YY** | Перевод с карты ePayments | $ <Amount>   |
				
    Given User see statement info for the UserId=<UserId> where DestinationId='MerchantInvoice' row № 0 direction='out':
		| Column1      | Column2                                                                |
		| Транзакция № | **TPurseTransactionId**                                                |
		| Заказ №      | **InvoiceId**                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
		| Продукт      | e-Wallet <UserPurseId>                                                 |
		| Получатель   | 000-749103                                                             |
		| Сумма        | $ <Amount>                                                             |
		| Детали       | Payment for invoice Yjinqhsxfv from Fix test grupe. Details: <Details> |      
	
	  Given User see statement info for the UserId=<UserId> where DestinationId='CardUnload' row № 1 direction='in':
		| Column1      | Column2                                                                |
		| Транзакция № | **TPurseTransactionId**                                                |
		| Заказ №      | **InvoiceId**                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                   |
		| Продукт      | e-Wallet <UserPurseId>                                                 |
		| Получатель   | 000-749103                                                             |
		| Сумма        | $ <Amount>                                                             |
		| Детали       | Card unload from ePayments Card <MaskedPan>							 | 


	Then User selects records in table 'Notification' for UserId="<UserId>"
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                                        |
     | Email       | 7        | <Email>                                                                                                                                                  | Оплата инвойса №Yjinqhsxfv от Fix test grupe |
     | PushAndroid | 13       | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -                                            |
     | PushIos     | 13       | 98a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -                                            |  
 
	Then User selects records in table 'Notification' for UserId="A85CDDF0-B134-4D95-9FAA-A2471231A594"
     | MessageType | Priority | Receiver                   | Title                                        |
     | Email       | 7        | partnertest@qa.swiftcom.uk | Оплата инвойса №Yjinqhsxfv от Fix test grupe |   


		 #С карты через PUSH
	 @3459409
	Examples:
    | paymentCodePhone                     | PaymentWay | SenderIdentity   | MaskedPan    | MaskedPan2     | ProxyPANCode | paymentSource    | Email                                 | Comission | Amount | UserId                               | EPSUserId                            | ShortUserPurseId | UserPurseId | EPS-01Commissions | Details         | Product                              |
    | ACAD9156-4BF3-426F-A730-2E84822C7CC0 | PUSH code  | 5283xxxxxxxx6653 | 5283****6653 | 5283 **** 6653 | 167715278    | e-Payments Card: | merchantFromCardByPush@qa.swiftcom.uk | 0.30      | 10.01  | 2af80ae0-768e-4750-8766-04b87a034ab7 | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 1880879          | 001-880879  | 406604            | this is details | dfb95fa2-9267-4f44-a92b-059679110f0e |   

	