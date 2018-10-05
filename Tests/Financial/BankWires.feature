@BankWires
Feature: OutWires
 Bank wires (outgoing)


	  
 Scenario Outline: Rietumu Перевод на банковский счет (исх ваер) через Rietumu. Positive
 
# Пользователь зарегистрирован и имеет доступ в систему, к фин. операциям,
# У пользователя нет сохраненных получателей,
# У пользователя НЕТ активного IBAN,
# Баланс кошелька USD/EUR/RUB > мин. суммы перевода,
# Для роли Permission "SiteOutgoingBankWire" = ВКЛ,
# Для пользователя Restriction "SiteOutgoingBankWire" = ВЫКЛ,
# На стенде включен доступ к переводам в админке, в разделе System Availability, "bankwireoutrietumu" = "Available" (для указанных IP, либо в целом для всех)

    Then User updates TransactionConfirmationType="<ConfirmationCode>" for UserId="<UserId>" in table 'TUsers'

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Given User clicks on Отчеты menu

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

## Validating form checking
	Given 'Кошелек' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     |
    	| RUB     |  
	Given User clicks on "Далее" on Multiform
	Then Validating message 'Заполните поле' count is 2
	Then 'Страна банка' UI selector set to 'Австрия'

	Then 'Отдаваемая сумма' set to '5'
	Then Alert Message "Сумма операции меньше лимита: 50.00 €" appears
    Then Validating message 'Сумма перевода меньше  € 50.00' appears on MultiForm

	Then 'Получаемая сумма' set to '100001'
	Then Alert Message "Сумма операции больше лимита: 100000.00 €" appears

	Then 'Отдаваемая сумма' set to '10000000'
	Then Validating message 'Сумма с комиссией превышает баланс' appears on MultiForm
	Then Make screenshot
## Cyrrilic symbols checking
	Then 'Имя получателя' set to 'кириллица'
	Then 'Фамилия получателя' set to 'кириллица'
	Then 'Город получателя' set to 'кириллица'
	Then 'Адрес получателя' set to 'кириллица'

	Then Validating message 'Поле заполнено неверно' count is 2
	Then 'Город получателя' value is ''
	Then 'Адрес получателя' value is ''

## Form validation check - finished

	Then User refresh the page
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'EUR' in eWallet section
	Then 'Страна банка' UI selector set to 'Австрия'
	Then 'Отдаваемая сумма' set to '1000'
	Given User see limits table
		| Column1                      | Column2                 |
		| Минимальная сумма перевода:  | € 50.00                 |
		| Максимальная сумма перевода: | € 100 000.00            |
		| Комиссия:                    | 0.8%min € 75, max € 125 |  

	Then 'Назначение платежа' details set to 'Details'

	Then 'Название банка' set to 'Austria bank'
	Then 'SWIFT банка получателя' set to 'HSEEAT2K'
	Then 'Номер счета/IBAN' set to 'LV10RTMB00000000000016'
	Then 'Получаемая сумма' value is '1000.00'
	Then Section 'Amount including fees' is: € 1 075.00 (Комиссия: € 75.00)

	Then 'Имя получателя' set to 'Nikita'
	Then 'Фамилия получателя' set to 'Ivanov'
	Then 'Страна получателя' UI selector set to 'Германия'
	Then 'Город получателя' set to 'Receiver's city'
	Then 'Адрес получателя' set to 'Receiver's city Address'
	
	Given User clicks on "Корреспондент"
	Then 'Страна банк-корреспондента' UI selector set to 'Россия'
	Then 'Номер счета корреспондента' set to '123test'
	Then 'SWIFT банк-корреспондента' set to 'swifttest'
	Then 'Название банк-корреспондента' set to ''
	Given User clicks on "Корреспондент"

	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	Given Set StartTime for DB search
	Given User see table
		| Column1            | Column2                                                       |
		| Отправитель        | EUR, e-Wallet <eWallet>                                       |
		| Получатель         | Austria bank, HSEEAT2K, Nikita Ivanov, LV10RTMB00000000000016 |
		| Отдаваемая сумма   | € 1 000.00                                                    |
		| Комиссия           | € 75.00                                                       |
		| Сумма с комиссией  | € 1 075.00                                                    |
		| Получаемая сумма   | € 1 000.00                                                    |
		| Назначение платежа | Details                                                       |  
	Then Make screenshot
		
	Given User clicks on "Подтвердить"
	
	Then User type <ConfirmationCode> sent to:
		| OperationType | Recipient       | UserId   | IsUsed |
		| MassPayment   | <CodeRecipient> | <UserId> | false  | 
	
	Given Set StartTime for DB search
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Then Make screenshot
	Given User clicks on "Закрыть"
	Then Redirected to /#/transfer/
	
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - € 75.00    |
		| **DD.MM.YY** | Банковский перевод                       | - € 1 000.00 |  

	Then Operator edits bank wire for UserId='<UserId>' where WireService='Rietumu' and sends to bank
				
    Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                                           |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                           |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                     |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                              |
		| Продукт      | e-Wallet <eWallet>                                                                                                                                                                                               |
		| Получатель   | HSEEAT2K/LV10RTMB00000000000016                                                                                                                                                                                   |
		| Сумма        | € 75.00                                                                                                                                                                                                           |
		| Детали       | Commission for outgoing bank wire. Beneficiary: Nikita Ivanov, Germany, Receiver's city, Receiver's city Address; Account number: LV10RTMB00000000000016; Bank: Austria bank, HSEEAT2K, Austria; Details: Details |   
		
     Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                                            |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                            |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                      |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                               |
		| Продукт      | e-Wallet <eWallet>                                                                                                                                                                                |
		| Получатель   | HSEEAT2K/LV10RTMB00000000000016                                                                                                                                                                    |
		| Сумма        | € 1 000.00                                                                                                                                                                                         |
		| Детали       | Outgoing bank wire. Beneficiary: Nikita Ivanov, Germany, Receiver's city, Receiver's city Address; Account number: LV10RTMB00000000000016; Bank: Austria bank, HSEEAT2K, Austria; Details: Details |  

	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver | Title                           |
      | Email       | 1        | <email>  | Отчет по операции № **Invoice** |  
  
  @135430
 Examples:
     | CodeRecipient | ConfirmationCode | email                              | eWallet    | Comission | Amount   | User         | UserId                               | Password     |
     | +70092039926  | SMSCode          | nikita_UI_financial@qa.swiftcom.uk | 001-053655 | 75.00     | 1 000.00 | +70092039926 | f751650f-2754-4bc1-bf23-ce78f347764e | 72621010Abac |  
	

	@3393743
  Examples:
   | CodeRecipient | ConfirmationCode | email                          | eWallet    | Comission | Amount   | User         | UserId                               | Password     |
   | cLCkHIt78RM   | PushCode         | payBySMS_YMoney@qa.swiftcom.uk | 001-105639 | 75.00     | 1 000.00 | +70049241782 | a0b37e7d-9faf-4868-a8e1-c90f7a5c406a | 72621010Abac |  



	   @2121040
	   @RietumuSEPA_out_wire
 Scenario Outline: RietumuSEPA Перевод на банковский счет (исх. ваер) через RietumuSEPA. Positive
 
# Пользователь зарегистрирован и имеет доступ в систему, к фин. операциям,
# У пользователя нет сохраненных получателей,
# У пользователя НЕТ активного IBAN,
# Баланс кошелька USD/EUR/RUB > мин. суммы перевода,
# Для роли Permission "SiteOutgoingBankWire" = ВКЛ,
# Для пользователя Restriction "SiteOutgoingBankWire" = ВЫКЛ,
# На стенде включен доступ к переводам в админке, в разделе System Availability, "bankwireoutrietumu" = "Available" (для указанных IP, либо в целом для всех)

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Given User clicks on Отчеты menu

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'EUR' in eWallet section
	Then 'Страна банка' UI selector set to 'Австрия'
	Then 'Отдаваемая сумма' set to '1000'
	Given User see limits table
		| Column1                      | Column2                 |
		| Минимальная сумма перевода:  | € 50.00                 |
		| Максимальная сумма перевода: | € 100 000.00            |
		| Комиссия:                    | € 0.50 |  
		
	Then 'Назначение платежа' details set to 'Details'

	Then 'Название банка' set to 'Austria bank'
	Then 'SWIFT банка получателя' set to 'HSEEAT2K'
	Then 'Номер счета/IBAN' set to 'LV10RTMB00000000000016'
	Then 'Получаемая сумма' value is '1000.00'
	Then Section 'Amount including fees' is: € 1 000.50 (Комиссия: € 0.50)

	Then 'Имя получателя' set to 'Nikita'
	Then 'Фамилия получателя' set to 'Ivanov'
	Then 'Страна получателя' UI selector set to 'Германия'
	Then 'Город получателя' set to 'Receiver's city'
	Then 'Адрес получателя' set to 'Receiver's city Address'

	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	
	Given User see table
		| Column1            | Column2                                                       |
		| Отправитель        | EUR, e-Wallet 001-053655                                      |
		| Получатель         | Austria bank, HSEEAT2K, Nikita Ivanov, LV10RTMB00000000000016 |
		| Отдаваемая сумма   | € 1 000.00                                                    |
		| Комиссия           | € 0.50                                                        |
		| Сумма с комиссией  | € 1 000.50                                                    |
		| Получаемая сумма   | € 1 000.00                                                    |
		| Назначение платежа | Details                                                       |  
		
	Given User clicks on "Подтвердить"
	Given Set StartTime for DB search
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |   
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Given User clicks on "Закрыть"
	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - € 0.50     |
		| **DD.MM.YY** | Банковский перевод                       | - € 1 000.00 |  

	Then Operator edits bank wire for UserId='<UserId>' where WireService='RietumuSEPA' and sends to bank

   Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
			| Column1      | Column2                                                                                                                                                                                                           |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                           |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                                     |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                              |
			| Продукт      | e-Wallet 001-053655                                                                                                                                                                                               |
			| Получатель   | HSEEAT2K/LV10RTMB00000000000016                                                                                                                                                                                   |
			| Сумма        | € 0.50                                                                                                                                                                                                            |
			| Детали       | Commission for outgoing bank wire. Beneficiary: Nikita Ivanov, Germany, Receiver's city, Receiver's city Address; Account number: LV10RTMB00000000000016; Bank: Austria bank, HSEEAT2K, Austria; Details: Details |  
		
    Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
			| Column1      | Column2                                                                                                                                                                                            |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                            |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                      |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                               |
			| Продукт      | e-Wallet 001-053655                                                                                                                                                                                |
			| Получатель   | HSEEAT2K/LV10RTMB00000000000016                                                                                                                                                                    |
			| Сумма        | € 1 000.00                                                                                                                                                                                         |
			| Детали       | Outgoing bank wire. Beneficiary: Nikita Ivanov, Germany, Receiver's city, Receiver's city Address; Account number: LV10RTMB00000000000016; Bank: Austria bank, HSEEAT2K, Austria; Details: Details |  
	
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver                           | Title                           |
      | Sms         | 13       | <User>                             | -                               |
      | Email       | 1        | nikita_UI_financial@qa.swiftcom.uk | Отчет по операции № **Invoice** |  

 Examples:
      | User         | UserId                               | Password     |
      | +70092039926 | f751650f-2754-4bc1-bf23-ce78f347764e | 72621010Abac |  


	  @346867
 Scenario Outline: True Positive (Refund Rietumu) Перевод на банковский счет (исх. ваер). Проверка на санкции.
 
# Пользователь имеет доступ к финансовым операциям,
# Можно брать пользователей-отправителей из Тестовые данные + how to-->Пользователи для проверки исходящих ваеров, у них есть шаблоны для перевода санкционным пользователям-получателям,
# Баланс кошелька USD/EUR/RUB > мин. суммы перевода.
# Примеры санкционных пользователей-получателей: http://hmt-sanctions.s3.amazonaws.com/sanctionsconlist.htm
# Можно производить переводы через любого из провайдеров: Rietumu, Rietumu SEPA, Handels bank

    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Then Memorize eWallet section

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'RUB' in eWallet section
	Then 'Получатель платежа' selector set to 'Sanction fiz bank, ULADZIMIR NAVUMAU, LV10RTMB00000000000016'
	Then 'Отдаваемая сумма' set to '10000'
	Then 'Получаемая сумма' value is '10000.00'

	Given User see limits table
		| Column1                      | Column2                      |
		| Минимальная сумма перевода:  | ₽ 6 000.00                   |
		| Максимальная сумма перевода: | ₽ 6 000 000.00               |
		| Комиссия:                    | 0.8%min ₽ 4 500, max ₽ 7 500 |  

	Then 'Назначение платежа' details set to 'Details'
	Then 'Код валютной операции (VO)' set to '999999'

	Then Section 'Amount including fees' is: ₽ 14 500.00 (Комиссия: ₽ <Comission>)

	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	
	Given User see table
		| Column1            | Column2                                                                |
		| Отправитель        | RUB, e-Wallet 000-<UserPurseId>                                        |
		| Получатель         | Sanction fiz bank, HABALV22, ULADZIMIR NAVUMAU, LV10RTMB00000000000016 |
		| Отдаваемая сумма   | ₽ <Amount>                                                             |
		| Комиссия           | ₽ <Comission>                                                          |
		| Сумма с комиссией  | ₽ 14 500.00                                                            |
		| Получаемая сумма   | ₽ <Amount>                                                             |
		| Назначение платежа | Details                                                                |  
	Then Make screenshot
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"
	Given Set StartTime for DB search
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70001258785 | <UserId> | false  |  

	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status    |  IsConfirmedPep |
 	  | BankWireOut | InProcess |  false		  |
	Then eWallet updated sections are:
		| USD  | EUR  | RUB    |
		| 0.00 | 0.00 | -14500 |   
	Then Make screenshot
		

	Given User clicks on "Закрыть"
	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu

#Step 1
     Then Get Invoice for last wire where UserId='<UserId>'
	 Given User see transactions list contains:
		| Date         | Name                                     | Amount          |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - ₽ <Comission> |
		| **DD.MM.YY** | Банковский перевод                       | - ₽ <Amount>    |  

	Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                               |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                         |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                  |
		| Продукт      | e-Wallet 000-<UserPurseId>                                                                                                                                                                                                                                            |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                                       |
		| Сумма        | ₽ <Comission>                                                                                                                                                                                                                                                            |
		| Детали       | Commission for outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  

	Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                                                                                                |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                   |
		| Продукт      | e-Wallet 000-<UserPurseId>                                                                                                                                                                                                                             |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                        |
		| Сумма        | ₽ <Amount>                                                                                                                                                                                                                                            |
		| Детали       | Outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  


   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 143             | 10000  | 4500 |    
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State          | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | OnVerification | {VO99999}, Details | WaveCrest      | 000-<UserPurseId> | Rietumu          | HABALV22/LV10RTMB00000000000016 | Rub        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount   | DestinationId        | Direction | UserId              | CurrencyId | PurseId       | RefundCount |
	  | 10000.00 | WireOut              | out       | <UserId>            | Rub        | <UserPurseId> | 0           |
	  | 10000.00 | WireOut              | in        | <SystemPurseUserId> | Rub        | 666698        | 0           |
	  | 4500.00  | OutBankWireComission | out       | <UserId>            | Rub        | <UserPurseId> | 0           |
	  | 4500.00  | OutBankWireComission | in        | <SystemPurseUserId> | Rub        | 666698        | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination      | UserId   | Amount    | AmountInUsd   | Product           | ProductType |
	  | Rub        | out       | OutgoingBankWire | <UserId> | 10000.00 | **Generated** | 000-<UserPurseId> | Epid        |   
   	##############################_Transactions_################################################

#Step 3
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireOut |  In process    | false          |  

#Step 4
	#Given Set StartTime for DB search
    Then Send CA true positive callback for reference 'LV10RTMB00000000000016'

	Then User refresh the page
	Given User clicks on Отчеты menu
	Then eWallet updated sections are:
		| USD  | EUR  | RUB    |
		| 0.00 | 0.00 | +14500 |        
	Given User see transactions list contains:
		| Date         | Name                                     | Amount        |
		| **DD.MM.YY** | Банковский перевод                       | ₽ <Amount>    |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | ₽ <Comission> |     
		
	Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 0 direction='in':
		| Column1      | Column2                                                                                                                                                                                                                                                        |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                        |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                  |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                           |
		| Продукт      | e-Wallet 000-294952                                                                                                                                                                                                                                            |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                                |
		| Сумма        | ₽ <Amount>                                                                                                                                                                                                                                                       |
		| Детали       | Refund: Outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  

	Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 1 direction='in':
		| Column1      | Column2                                                                                                                                                                                                                                                                       |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                                       |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                                 |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                          |
		| Продукт      | e-Wallet 000-294952                                                                                                                                                                                                                                                           |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                                               |
		| Сумма        | ₽ <Comission>                                                                                                                                                                                                                                                                       |
		| Детали       | Refund: Commission for outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  


   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 143             | 10000  | 4500 |   
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State    | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Refunded | {VO99999}, Details | WaveCrest      | 000-<UserPurseId> | Rietumu          | HABALV22/LV10RTMB00000000000016 | Rub        | EWallet       | Purse                | <UserId> |    

	  
	#QAA-550 (details is not checked)
   Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
	  | Amount   | DestinationId        | Direction | UserId              | CurrencyId | PurseId       | RefundCount |
	  | 4500.00  | OutBankWireComission | out       | <SystemPurseUserId> | Rub        | 666698        | 1           |
	  | 4500.00  | OutBankWireComission | in        | <UserId>            | Rub        | <UserPurseId> | 1           |
	  | 10000.00 | WireOut              | out       | <SystemPurseUserId> | Rub        | 666698        | 1           |
	  | 10000.00 | WireOut              | in        | <UserId>            | Rub        | <UserPurseId> | 1           |  
	 
	Then No records in 'LimitRecords'

	Then No records in 'TExternalTransactions'
	
	##############################_Transactions_################################################

#Step 5
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireOut | Confirmed      | false          |  
  
  	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver     | Title                           |
      | Sms         | 13       | +70001258785 | -                               |
      | Email       | 1        | <User>       | Отчет по операции № **Invoice** |  

  Examples:
      | User                     | UserId                               | Password  | Amount    | Comission | SystemPurseUserId                    | UserPurseId |
      | sb_ind_CC@qa.swiftcom.uk | a4ac4ef5-c2a7-4d5a-9973-42e73943ec6d | XSW@zaq11 | 10 000.00 | 4 500.00  | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 294952      |  


	  @2566659
 Scenario Outline: False Positive (Rietumu) Перевод на банковский счет (исх. ваер). Проверка на санкции.
 
# Пользователь имеет доступ к финансовым операциям,
# Можно брать пользователей-отправителей из Тестовые данные + how to-->Пользователи для проверки исходящих ваеров, у них есть шаблоны для перевода санкционным пользователям-получателям,
# Баланс кошелька USD/EUR/RUB > мин. суммы перевода.
# Примеры санкционных пользователей-получателей: http://hmt-sanctions.s3.amazonaws.com/sanctionsconlist.htm
# Можно производить переводы через любого из провайдеров: Rietumu, Rietumu SEPA, Handels bank
	
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Then Memorize eWallet section

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'RUB' in eWallet section
	Then 'Получатель платежа' selector set to 'Sanction fiz bank, ULADZIMIR NAVUMAU, LV10RTMB00000000000016'
	Then 'Отдаваемая сумма' set to '10000'
	Then 'Получаемая сумма' value is '10000.00'

	Given User see limits table
		| Column1                      | Column2                      |
		| Минимальная сумма перевода:  | ₽ 6 000.00                   |
		| Максимальная сумма перевода: | ₽ 6 000 000.00               |
		| Комиссия:                    | 0.8%min ₽ 4 500, max ₽ 7 500 |  

	Then 'Назначение платежа' details set to 'Details'
	Then 'Код валютной операции (VO)' set to '999999'

	Then Section 'Amount including fees' is: ₽ 14 500.00 (Комиссия: ₽ 4 500.00)

	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	
	Given User see table
		| Column1            | Column2                                                                |
		| Отправитель        | RUB, e-Wallet 000-<UserPurseId>                                        |
		| Получатель         | Sanction fiz bank, HABALV22, ULADZIMIR NAVUMAU, LV10RTMB00000000000016 |
		| Отдаваемая сумма   | ₽ <Amount>                                                             |
		| Комиссия           | ₽ 4 500.00                                                             |
		| Сумма с комиссией  | ₽ 14 500.00                                                            |
		| Получаемая сумма   | ₽ <Amount>                                                             |
		| Назначение платежа | Details                                                                |  
	Then Make screenshot
	Given Set StartTime for DB search
	Given User clicks on "Подтвердить"
	Given Set StartTime for DB search
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70001258785 | <UserId> | false  |  
	Given User clicks on "Оплатить"
	Given Set StartTime for DB search

	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status    |  IsConfirmedPep |
 	  | BankWireOut | InProcess |  false		  |
	Then eWallet updated sections are:
		| USD  | EUR  | RUB    |
		| 0.00 | 0.00 | -14500 |   
	Then Make screenshot
		
	Given User clicks on "Закрыть"
	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu

#Step 1
     Then Get Invoice for last wire where UserId='<UserId>'
	 Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - ₽ 4 500.00 |
		| **DD.MM.YY** | Банковский перевод                       | - ₽ <Amount> |  
	
   Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
		| Column1      | Column2                                                                                                                                                                                                                                                               |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                               |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                         |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                  |
		| Продукт      | e-Wallet 000-<UserPurseId>                                                                                                                                                                                                                                            |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                                       |
		| Сумма        | ₽ 4 500.00                                                                                                                                                                                                                                                         |
		| Детали       | Commission for outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  

		
	Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
		| Column1      | Column2                                                                                                                                                                                                                                                |
		| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                |
		| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                          |
		| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                   |
		| Продукт      | e-Wallet 000-<UserPurseId>                                                                                                                                                                                                                             |
		| Получатель   | HABALV22/LV10RTMB00000000000016                                                                                                                                                                                                                        |
		| Сумма        | ₽ <Amount>                                                                                                                                                                                                                                            |
		| Детали       | Outgoing bank wire. Beneficiary: ULADZIMIR NAVUMAU, Belarus, Minsk, address1; Account number: LV10RTMB00000000000016; Bank: Sanction fiz bank, HABALV22, Latvia; Correspondent bank: asd, 12312312312, asdasdasd, Austria; Details: {VO99999}, Details |  


   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 143             | 10000  | 4500 |  
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State          | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | OnVerification | {VO99999}, Details | WaveCrest      | 000-<UserPurseId> | Rietumu          | HABALV22/LV10RTMB00000000000016 | Rub        | EWallet       | Purse                | <UserId> |  
	
	
	#QAA-550 (details is not checked)
   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
	  | Amount      | DestinationId        | Direction | UserId              | CurrencyId | PurseId       | RefundCount |
	  | 10000.00    | WireOut              | out       | <UserId>            | Rub        | <UserPurseId> | 0           |
	  | 10000.00    | WireOut              | in        | <SystemPurseUserId> | Rub        | 666698        | 0           |
	  | <Comission> | OutBankWireComission | out       | <UserId>            | Rub        | <UserPurseId> | 0           |
	  | <Comission> | OutBankWireComission | in        | <SystemPurseUserId> | Rub        | 666698        | 0           |  

	#QAA-550 (details is not checked)
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination      | UserId   | Amount   | AmountInUsd   | Product           | ProductType |
	  | Rub        | out       | OutgoingBankWire | <UserId> | 10000.00 | **Generated** | 000-<UserPurseId> | Epid        |  
   	##############################_Transactions_################################################

#Step 3
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireOut |  In process    | false          |  

#Step 4
    Then Send CA false positive callback for reference 'LV10RTMB00000000000016'

	Then User refresh the page
	Given User clicks on Отчеты menu
	Then eWallet updated sections are:
		| USD  | EUR  | RUB  |
		| 0.00 | 0.00 | 0.00 |      
	 Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - ₽ 4 500.00 |
		| **DD.MM.YY** | Банковский перевод                       | - ₽ <Amount> |  

   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 143             | 10000  | 4500 |   
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State                     | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | WaitingForManualAdmission | {VO99999}, Details | WaveCrest      | 000-<UserPurseId> | Rietumu          | HABALV22/LV10RTMB00000000000016 | Rub        | EWallet       | Purse                | <UserId> |  

	  
	#QAA-550 (details is not checked)
   Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
	  | Amount      | DestinationId        | Direction | UserId              | CurrencyId | PurseId | RefundCount |
	  | 10000.00    | WireOut              | out       | <SystemPurseUserId> | Rub        | 666698  | 0           |
	  | 10000.00    | WireOut              | in        | <SystemPurseUserId> | Rub        | 1100    | 0           |
	  | <Comission> | OutBankWireComission | out       | <SystemPurseUserId> | Rub        | 666698  | 0           |
	  | <Comission> | OutBankWireComission | in        | <SystemPurseUserId> | Rub        | 1100    | 0           |  
	 
	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
	  | CurrencyId | Direction | Destination      | UserId   | Amount   | AmountInUsd   | Product           | ProductType |
	  | Rub        | out       | OutgoingBankWire | <UserId> | 10000.00 | **Generated** | 000-<UserPurseId> | Epid        |  

	Then No records in 'TExternalTransactions'
	
	##############################_Transactions_################################################

#Step 5
	Then User selects record in 'SanctionCheck' where UserId ="<UserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireOut | Not Sanctioned | false          |  
  
#Step 6  
	Then Operator close last invoice for UserId=<UserId>
	Given Reset checkers
	
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee         |
	  | 143             | 10000.00 | <Comission> |  
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State     | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | Successed | {VO99999}, Details | WaveCrest      | 000-<UserPurseId> | Rietumu          | HABALV22/LV10RTMB00000000000016 | Rub        | EWallet       | Purse                | <UserId> |  

	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver | Title                           |
      | Email       | 1        | <User>   | Отчет по операции № **Invoice** |  

  Examples:
      | User                     | UserId                               | Password  | Amount    | Comission | SystemPurseUserId                    | UserPurseId |
      | sb_ind_CC@qa.swiftcom.uk | a4ac4ef5-c2a7-4d5a-9973-42e73943ec6d | XSW@zaq11 | 10 000.00 | 4500.00   | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 294952      |  


 
 Scenario Outline: Пополнение по банковским реквизитам. Неопознанный wire (зачисление денег на счет клиенту) 
 
#Условия для получателя перевода:
#
#Клиент зарегистрирован в системе
#Клиент КУС2
#для перехода к разделу: Админская часть - Finance - Bank Wires
#запрос кода подтвержден
	
	Given Set StartTime for DB search

#Step 1-2-3-4
	Then Operator creates undefined wire:
		| isUndefined | reference   | currency | bankCharge | ourCharge | wireServiceId | paymentAmount | paymentDetails | beneficiaryAccountNumber |
		| true        | <Reference> | 2        | 10         | 0         | 4             | 110           | <Details>      | 000-001101               |  

#Step 5
	Then User selects record in 'SanctionCheck' where UserId ="<SystemPurseUserId>":
	  | Scenario    | Status         | IsConfirmedPep |
	  | BankWireIn  | Not Sanctioned | false          | 
	  | BankWireIn  | Not Sanctioned | false          | 

	 Then Operator process undefined incoming wire '<SystemPurseUserId>':
			| BeneficiaryAccountNumber | ComissionForIdentification | CommissionForWire | SourceOfFundsId |
			| 000-166879               | 35                         | 10                | 18              |    

#Step 12 (transactions and statements)
##############################_Transactions_################################################

	Then User selects records in 'TPurseTransactions' for undefined wire:
	  | Amount                       | DestinationId               | Direction | UserId              | CurrencyId | PurseId                     | RefundCount |
	  | <PaymentAmount>              | Refill                      | in        | <SystemPurseUserId> | Eur        | <EPS-03UndefinedWiresPurse> | 0           |
	  | <BankCharge>                 | BankComission               | out       | <EPSUserId>         | Eur        | <EPS-01Commissions>         | 0           |
	  | <PaymentAmount>              | Refill                      | out       | <SystemPurseUserId> | Eur        | <EPS-03UndefinedWiresPurse> | 0           |
	  | <PaymentAmount>              | Refill                      | in        | <ReceiverUserId>    | Eur        | <UserPurseId>               | 0           |
	  | <CommissionForWire>          | BankWireIncommingCommission | out       | <ReceiverUserId>    | Eur        | <UserPurseId>               | 0           |
	  | <CommissionForWire>          | BankWireIncommingCommission | in        | <EPSUserId>         | Eur        | <EPS-01Commissions>         | 0           |
	  | <ComissionForIdentification> | BankWireUndefinedCommission | out       | <ReceiverUserId>    | Eur        | <UserPurseId>               | 0           |
	  | <ComissionForIdentification> | BankWireUndefinedCommission | in        | <EPSUserId>         | Eur        | <EPS-01Commissions>         | 0           |  
 

	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<ReceiverUserId>":
	  | CurrencyId | Direction | Destination      | UserId           | Amount | AmountInUsd   | Product           | ProductType |
	  | Eur        | In        | IncomingBankWire | <ReceiverUserId> | 75.00  | **Generated** | 000-<UserPurseId> | Epid        |  

	Then User selects records in 'TExternalTransactions' for UndefinedWire
	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
	  | <BankCharge>    | Eur        | Rietumu           | false                 |  
##############################_Transactions_################################################

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page

	Given User clicks on Отчеты menu

	Given User see transactions list contains:
		| Date         | Name                                                                                                           | Amount                           |
		| **DD.MM.YY** | Комиссия системы за входящий банковский перевод                                                                | - € <BankCharge>                 |
		| **DD.MM.YY** | Комиссия за обработку банковских переводов с неверными реквизитами или без указания e-Wallet в деталях платежа | - € <ComissionForIdentification> |
		| **DD.MM.YY** | Входящий банковский перевод                                                                                    | € <PaymentAmount>                |  
	
	
    Given User see statement info for the UserId=<ReceiverUserId> where DestinationId='BankWireIncommingCommission' row № 0 direction='out' without invoice:
		| Column1      | Column2                                        |
		| Транзакция № | **TPurseTransactionId**                        |
		| Дата         | **dd.MM.yyyy HH:mm**                           |
		| Продукт      | e-Wallet 000-<UserPurseId>                     |
		| Сумма        | € <BankCharge>                                 |
		| Детали       | Commission for incoming wire. <Details> |     

	Given User see statement info for the UserId=<ReceiverUserId> where DestinationId='BankWireUndefinedCommission' row № 1 direction='out' without invoice:
		| Column1      | Column2                                                         |
		| Транзакция № | **TPurseTransactionId**                                         |
		| Дата         | **dd.MM.yyyy HH:mm**                                            |
		| Продукт      | e-Wallet 000-<UserPurseId>                                      |
		| Сумма        | € <ComissionForIdentification>                                  |
		| Детали       | Commission for bank wire <Reference> with incorrect details |     

		
	Given User see statement info for the UserId=<ReceiverUserId> where DestinationId='Refill' row № 2 direction='in' without invoice:
		| Column1      | Column2                    |
		| Транзакция № | **TPurseTransactionId**    |
		| Дата         | **dd.MM.yyyy HH:mm**       |
		| Продукт      | e-Wallet 000-<UserPurseId> |
		| Сумма        | € <PaymentAmount>          |
		| Детали       | <Details>                  |  


#[EPA-6432]
#		Then User selects records in table 'Notification' where UserId="<SystemPurseUserId>" with "**TPurseTransactionId**" replacing:
#      | MessageType | Priority | Receiver | Title                                       |
#      | Email       | 10       | <User>   | Отчет по операции № **TPurseTransactionId** |  

@349910
  Examples:
     | Reference        | PaymentAmount | BankCharge | ComissionForIdentification | CommissionForWire | Details          | ReceiverUserId                       | User                   | Password      | SystemPurseUserId                    | UserPurseId | EPSUserId                            | EPS-01Commissions | EPS-03UndefinedWiresPurse |
     | Qlsebyxguqodvirr | 110.00        | 10.00      | 35.00                      | 10.00             | autotest details | B5DC29B5-A071-4D5D-AE9D-5CECA7151E93 | kyc1nik@qa.swiftcom.uk | 72621010Abacc | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 166879      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 1101                      |  
	 


 Scenario Outline: Перевод на банковский счет (исх. ваер) через EarthPortLocal. Positive

# Пользователь KYC 2 - бизнес-клиент,
# У пользователя есть привязка адреса в таблице [test_epayments].[dbo].[TBussinessClient]
# Баланс кошелька USD/EUR > мин. суммы перевода,
# В ServiceAvailability - AutosendWireOut=ВЫКЛ
# Для роли Permission "SiteOutgoingBankWire" = ВКЛ,
# Для пользователя Restriction "SiteOutgoingBankWire" = ВЫКЛ,
# На стенде включен доступ к переводам в админке, в разделе System Availability, BankWireOutEarthPortLocal = ВКЛ ((для указанных IP, либо в целом для всех)),
# Получатель перевода НЕ из санкционного списка, примеры санкционных пользователей-получателей: http://hmt-sanctions.s3.amazonaws.com/sanctionsconlist.
# Данные для перевода:
# 1) Страна банка = Канада, 
# 2) Получаемая сумма = ... CAD
# 3) Номер счета/IBAN = G187LGDH02991304573959
# 4) SWIFT банка получателя = ACNACA2Q
# 5) Номер роутинга (ABA RTN) = 02652004

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Given User clicks on Отчеты menu

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Страна банка' UI selector set to 'Канада'
	# Step 1
	Then 'Отдаваемая сумма' set to '1000'
	Then 'Получаемая сумма' selector set to 'CAD'

	Then Section 'Amount including fees' is: $ 1 003.00 (Комиссия: $ 3.00)
	Given User see limits table
		| Column1                      | Column2       |
		| Минимальная сумма перевода:  | C$ 70.00      |
		| Максимальная сумма перевода: | C$ 130 000.00 |
		| Комиссия:                    | $ 3           |  
		
	Then 'Назначение платежа' details set to 'Details'

	Then 'Название банка' set to 'Canada bank'
	Then 'SWIFT банка получателя' set to 'ACNACA2Q'
	Then 'Номер роутинга (ABA RTN)' set to '02652004'
	Then 'Номер счета/IBAN' set to 'G187LGDH02991304573959'
	Then 'Отдаваемая сумма' set to '1000'

	Then 'Имя получателя' set to 'Nikita'
	Then 'Фамилия получателя' set to 'Ivanov'

	Then 'Страна получателя' UI selector set to 'Канада'
	Then 'Город получателя' set to 'Receiver's city'
	Then 'Адрес получателя' set to 'Receiver's city Address'
	Then 'Код операции' UI selector set to 'Payroll'
	Then Currency rate placeholder appears
	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	
	Given User see table
		| Column1            | Column2                                                      |
		| Отправитель        | USD, e-Wallet <UserPurseId>                                  |
		| Получатель         | Canada bank, ACNACA2Q, Nikita Ivanov, G187LGDH02991304573959 |
		| Отдаваемая сумма   | $ 1 000.00                                                   |
		| Комиссия           | $ 3.00                                                       |
		| Сумма с комиссией  | $ 1 003.00                                                   |
		| Курс обмена        | $ 1.00 = C$ **rateWM**                                       |
		| Получаемая сумма   | C$ **amount * rate**                                         |
		| Назначение платежа | Details                                                      |  
	Given Set StartTime for DB search
		
	Given User clicks on "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |
	Given Set StartTime for DB search

	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Given User clicks on "Закрыть"


	 # Step 2-3


	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - $ 3.00     |
		| **DD.MM.YY** | Банковский перевод                       | - $ 1 000.00 |  


   Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
			| Column1      | Column2                                                                                                                                                                                                                                                                                                          |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                                                                          |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                                                                    |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                                                             |
			| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                                                                                                                                           |
			| Получатель   | <Receiver>                                                                                                                                                                                                                                                                                                       |
			| Сумма        | $ 3.00                                                                                                                                                                                                                                                                                                           |
			| Детали       | Commission for outgoing bank wire. Beneficiary: Nikita Ivanov, Canada, Receiver's city, Receiver's city Address; Account number: G187LGDH02991304573959; Bank: Canada bank, ACNACA2Q, Canada; Details: Details. Amount transferred to outgoing bank wire: Can$**amount ** rate**, Rate: $1 = Can$**rate**. |    

		
    Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
			| Column1      | Column2                                                                                                                                                                                                                                                                                           |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                                                           |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                                                     |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                                              |
			| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                                                                                                                            |
			| Получатель   | <Receiver>                                                                                                                                                                                                                                                                                        |
			| Сумма        | $ 1 000.00                                                                                                                                                                                                                                                                                        |
			| Детали       | Outgoing bank wire. Beneficiary: Nikita Ivanov, Canada, Receiver's city, Receiver's city Address; Account number: G187LGDH02991304573959; Bank: Canada bank, ACNACA2Q, Canada; Details: Details. Amount transferred to outgoing bank wire: Can$**amount ** rate**, Rate: $1 = Can$**rate**. |  

	#Step 4
	Then Operator edits bank wire for UserId='<UserId>' where WireService='EarthPortLocal' and sends to bank

	Then Wait invoice closing with 150 sec timeout for UserId="<UserId>"

##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee  |
	  | 1042            | <Amount> | 3.00 |  

	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State                     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId                               |
	  | Successed				  | Details | WaveCrest      | <UserPurseId>  | EarthPortLocal   | <Receiver>       | Usd        | EWallet       | Purse                | 4D8814A7-A260-4083-8612-660598BA5F2D |   
	

      Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>" for EarthPort with "<SystemUserId>"
 	  | Amount      | DestinationId                | Direction | UserId         | CurrencyId | PurseId        | RefundCount |
 	  | <Amount>    | WireOut                      | out       | <UserId>       | Usd        | <ShortPurseId> | 0           |
 	  | <Amount>    | WireOut                      | in        | <SystemUserId> | Usd        | 1100           | 0           |
 	  | <Comission> | OutBankWireComission         | out       | <UserId>       | Usd        | <ShortPurseId> | 0           |
 	  | <Comission> | OutBankWireComission         | in        | <SystemUserId> | Usd        | 1100           | 0           |
 	  | <Comission> | OutBankWireComission         | out       | <SystemUserId> | Usd        | 1100           | 0           |
 	  | <Comission> | OutBankWireComission         | in        | <EPSUserId>    | Usd        | 406604         | 0           |
 	  | **fxrate**  | WireOut                      | out       | <SystemUserId> | Usd        | 1100			  | 0           |
 	  | **fxrate2** | ExternalCurrencyExchangeLoss | out       | <EPSUserId >   | Usd        | 406604         | 0           |
 	  | **fxrate2** | ExternalCurrencyExchangeLoss | in        | <SystemUserId> | Usd        | 1100			  | 0           |

 	 Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
 	  | CurrencyId | Direction | Destination      | UserId   | Amount   | AmountInUsd   | Product       | ProductType |
 	  | Usd        | Out       | OutgoingBankWire | <UserId> | <Amount> | **Generated** | <UserPurseId> | Epid        |    
 
	Then User selects records in 'TExternalTransactions' by OperationGuid for EarthPort
	  | Amount      | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | **fxrate2** | Usd        | EarthPortLocal    | False                 |  
 ##############################_Transactions_################################################


	#Step 5
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver                       | Title                           |
      | Email       | 1        | earthporttestui@qa.swiftcom.uk | Отчет по операции № **Invoice** |    

 @3616273
 @AutosendWireOut_OFF
  Examples:
      | Receiver                        | User         | UserId                               | Password     | Amount  | Comission | ShortPurseId | UserPurseId | SystemUserId                         | EPSUserId                            |
      | ACNACA2Q/G187LGDH02991304573959 | +70054844135 | 4d8814a7-a260-4083-8612-660598ba5f2d | 72621010Abac | 1000.00 | 3.00      | 1422543      | 001-422543  | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |




 Scenario Outline: Перевод на банковский счет (исх. ваер) через EarthPortSwift. Positive
 
# Пользователь KYC 2 - бизнес-клиент,
# Баланс кошелька USD/EUR > мин. суммы перевода,
# Для роли Permission "SiteOutgoingBankWire" = ВКЛ,
# Для пользователя Restriction "SiteOutgoingBankWire" = ВЫКЛ,
# На стенде включен доступ к переводам в админке, в разделе System Availability, BankWireOutEarthPortLocal = ВКЛ ((для указанных IP, либо в целом для всех)),
# Получатель перевода НЕ из санкционного списка, примеры санкционных пользователей-получателей: http://hmt-sanctions.s3.amazonaws.com/sanctionsconlist.
## Данные для перевода:
## 1) Страна банка = Германия
## 2) Получаемая сумма = 50 USD
## 3) Номер счета/IBAN = GB97XRYD37916294552407
## 4) SWIFT банка получателя = AARBDE5W200

	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Given User clicks on Отчеты menu

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'EUR' in eWallet section
	Then 'Страна банка' UI selector set to 'Германия'
	# Step 1
	Then 'Отдаваемая сумма' set to '1000'
	Then 'Получаемая сумма' selector set to 'USD'

	Then Section 'Amount including fees' is: € 1 015.00 (Комиссия: € 15.00)
	Given User see limits table
		| Column1                      | Column2      |
		| Минимальная сумма перевода:  | $ 50.00      |
		| Максимальная сумма перевода: | $ 100 000.00 |
		| Комиссия:                    | 0.5%min € 15 |  
		
	Then 'Назначение платежа' details set to 'Details'

	Then 'Название банка' set to 'Canada bank'
	Then 'SWIFT банка получателя' set to 'AARBDE5W200'
	Then 'Номер счета/IBAN' set to 'GB97XRYD37916294552407'


	Then 'Имя получателя' set to 'Nikita'
	Then 'Фамилия получателя' set to 'Ivanov'
	Then 'Страна получателя' UI selector set to 'Германия'
	Then 'Город получателя' set to 'Receiver's city'
	Then 'Адрес получателя' set to 'Receiver's city Address'
	#Then 'Код операции' UI selector set to 'Payroll'
	Then Currency rate placeholder appears
	Then Make screenshot
	Given User clicks on "Далее" on Multiform
	
	Given User see table
		| Column1            | Column2                                                         |
		| Отправитель        | EUR, e-Wallet <UserPurseId>                                     |
		| Получатель         | Canada bank, AARBDE5W200, Nikita Ivanov, GB97XRYD37916294552407 |
		| Отдаваемая сумма   | € 1 000.00                                                      |
		| Комиссия           | € 15.00                                                         |
		| Сумма с комиссией  | € 1 015.00                                                      |
		| Курс обмена        | € 1.00 = $ **rateWM**                                           |
		| Получаемая сумма   | $ **amount * rate**                                             |
		| Назначение платежа | Details                                                         |  
	Given Set StartTime for DB search
		
	Given User clicks on "Подтвердить"
	Then User type SMS sent to:
		| OperationType | Recipient | UserId   | IsUsed |
		| MassPayment   | <User>    | <UserId> | false  |

	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform
	Given User clicks on "Закрыть"

	 Then Wait for transactions loading

	 # Step 2-3
	 ##############################_Transactions_################################################
 	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee  |
	  | 1041            | <Amount> | 15.00 |  

	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State                     | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId                               |
	  | WaitingForManualAdmission | Details | WaveCrest      | <UserPurseId>  | EarthPortLocal   | <Receiver>       | Usd        | EWallet       | Purse                | 4D8814A7-A260-4083-8612-660598BA5F2D |   
	

   Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
 	  | Amount      | DestinationId        | Direction | UserId         | CurrencyId | PurseId        | RefundCount |
 	  | <Amount>    | WireOut              | out       | <UserId>       | Usd        | <ShortPurseId> | 0           |
 	  | <Amount>    | WireOut              | in        | <SystemUserId> | Usd        | 1100           | 0           |
 	  | <Comission> | OutBankWireComission | out       | <UserId>       | Usd        | <ShortPurseId> | 0           |
 	  | <Comission> | OutBankWireComission | in        | <SystemUserId> | Usd        | 1100           | 0           |  
 	  
 	 Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
 	  | CurrencyId | Direction | Destination      | UserId           | Amount | AmountInUsd   | Product    | ProductType |
 	  | Usd        | Out        | OutgoingBankWire | <UserId> | <Amount>    | **Generated** |<UserPurseId> | Epid        |  
 
 	Then No records in 'TExternalTransactions'
 ##############################_Transactions_################################################

	Then Redirected to /#/transfer/
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                                     | Amount       |
		| **DD.MM.YY** | Комиссия за исходящий банковский перевод | - $ 3.00     |
		| **DD.MM.YY** | Банковский перевод                       | - $ 1 000.00 |  


   Given User see statement info for the UserId=<UserId> where DestinationId='OutBankWireComission' row № 0 direction='out':
			| Column1      | Column2                                                                                                                                                                                                                                                                                                          |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                                                                          |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                                                                    |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                                                             |
			| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                                                                                                                                           |
			| Получатель   | <Receiver>                                                                                                                                                                                                                                                                                                       |
			| Сумма        | $ 3.00                                                                                                                                                                                                                                                                                                           |
			| Детали       | Commission for outgoing bank wire. Beneficiary: Nikita Ivanov, Canada, Receiver's city, Receiver's city Address; Account number: GB97XRYD37916294552407; Bank: Canada bank, AARBDE5W200, Canada; Details: Details. Amount transferred to outgoing bank wire: Can$**amount ** rate**, Rate: Can$1 = $**wrong rate**. |    

		
    Given User see statement info for the UserId=<UserId> where DestinationId='WireOut' row № 1 direction='out':
			| Column1      | Column2                                                                                                                                                                                                                                                                                           |
			| Транзакция № | **TPurseTransactionId**                                                                                                                                                                                                                                                                           |
			| Заказ №      | **InvoiceId**                                                                                                                                                                                                                                                                                     |
			| Дата         | **dd.MM.yyyy HH:mm**                                                                                                                                                                                                                                                                              |
			| Продукт      | e-Wallet <UserPurseId>                                                                                                                                                                                                                                                                            |
			| Получатель   | <Receiver>                                                                                                                                                                                                                                                                                        |
			| Сумма        | $ 1 000.00                                                                                                                                                                                                                                                                                        |
			| Детали       | Outgoing bank wire. Beneficiary: Nikita Ivanov, Canada, Receiver's city, Receiver's city Address; Account number: GB97XRYD37916294552407; Bank: Canada bank, AARBDE5W200, Canada; Details: Details. Amount transferred to outgoing bank wire: Can$**amount ** rate**, Rate: Can$1 = $**wrong rate**. |  

	#Step 4
	Then Operator edits bank wire for UserId='<UserId>' where WireService='EarthPortLocal' and sends to bank
#
#	#Step 5
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType | Priority | Receiver                       | Title                           |
     | Email       | 1        | earthporttestui@qa.swiftcom.uk | Отчет по операции № **Invoice** |    

@3050381
@AutosendWireOut_OFF
 Examples:
     | Receiver                           | User         | UserId                               | Password     | Amount  | Comission | ShortPurseId | UserPurseId | SystemUserId                         |
     | AARBDE5W200/GB97XRYD37916294552407 | +70054844135 | 4d8814a7-a260-4083-8612-660598ba5f2d | 72621010Abac | 1000.00 | 3.00      | 1422543      | 001-422543  | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF |  


