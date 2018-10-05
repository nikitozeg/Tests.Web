@InternalPayment

Feature: InternalPayment
	
Scenario Outline: Внутренний перевод существующему клиенту (валидация+комиссия)
  # На секциях кошелька имеется определенное количество средств
  # Минимальные и максимальные лимиты для перевода установлены

    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

#STEP 1 	
 	Given User clicks on Перевести menu
#STEP 2
 	Given User clicks on "Другому человеку"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Given User see limits table
 		| Column1                      | Column2 |
 		| Минимальная сумма перевода:  | $ 0.50  |
 		| Максимальная сумма перевода: | нет     |
 		| Комиссия:                    | $ 1     |  

	Given 'Со счета' selector is "USD" and contains:
    	| Options |
    	| USD     |
    	| EUR     | 
    	| RUB     | 

	Given 'Получатель' selector is "Кошелек" and contains:
     	| Options |
     	| Кошелек |
     	| Телефон |
     	| e-mail  |  

# Standart validation rules
 	Then 'Отдаваемая сумма' set to '10000000'
	Then User gets message "Сумма с комиссией превышает баланс" on Multiform
 	Then 'Отдаваемая сумма' set to '0.49'
	Then User gets message "Сумма перевода меньше" on Multiform
#STEP 3
 	Then 'Отдаваемая сумма' set to '<Amount>'
 	Then Section 'Amount including fees' is: $ 101.00 (Комиссия: $ 1.00)

 	Then 'Получатель' selector set to 'Телефон'
 	Then 'Получатель' set to '<Receiver>'

#STEP 4
 	Then 'Детали (необязательно)' details set to 'Details'
 	Given User clicks on "Далее" on Multiform

#STEP 5
	Given User see table
 		| Column1                | Column2                 |
 		| Со счета               | USD, e-Wallet <PurseId> |
 		| Получатель             | +<Receiver>             |
 		| Отдаваемая сумма       | $ <Amount>              |
 		| Комиссия               | $ <Comission>           |
 		| Сумма с комиссией      | $ 101.00                |
 		| Получаемая сумма       | $ 100.00                |
 		| Детали (необязательно) | Details                 |  

	
	@2977561
Examples:
    | Receiver    | Comission | Amount | User                              | Password     | PurseId    |
    | 70006666697 | 1.00      | 100.00 | sendmoneynewperson@qa.swiftcom.uk | 72621010Abac |  001-961743 |  

	

Scenario Outline: Внутренний перевод новому клиенту + регистрация нового клиента с получением денег (по телефону/email)
# Предусловие: 
# Клиент-отправитель: Логинимся за любого незаблокированного юзера с балансом больше установленного минимального лимита по переводу. Операция доступна для ФИЗИКА и БИЗНЕС клиента
# К клиенту-отправителю платежа привязаны моб устройства ios, Android (для проверки PUSH уведомлений)
# Например dududu@mail.ru:DaDaDa123(плат. пароль 535353).

    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
	Given Reset Email
 	Given User see Account Page

#Step 1  	
 	Given User clicks on Перевести menu

#Step 2
 	Given User clicks on "Другому человеку"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Then 'Получатель' selector set to '<SendBy>'

#Step 3 
 	Then 'Получатель' set to random <ReceiverIdentityType>
 	Then 'Отдаваемая сумма' set to '<Amount>'
  	Then Section 'Amount including fees' is: $ 11.00 (Комиссия: $ <Comission>)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1           | Column2                 |
 		| Со счета          | USD, e-Wallet <PurseId> |
 		| Получатель        | **Receiver**            |
 		| Отдаваемая сумма  | $ <Amount>              |
 		| Комиссия          | $ <Comission>           |
 		| Сумма с комиссией | $ 11.00                 |
 		| Получаемая сумма  | $ <Amount>              |  
 	Given Set StartTime for DB search
 	Given User clicks on "Подтвердить" on Multiform
	Then Memorize eWallet section

#Step 4
    Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70084361970 | <UserId> | false  |  

#Step 5
 	Given User clicks on "Оплатить" on Multiform
 	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform

   
#Step 6
	Then User selects records in table 'Notification' for UserId="00000000-0000-0000-0000-000000000000" internal payment
     | MessageType   | Priority | Receiver     | Title   | Body   |
     | <MessageType> | 6        | **Receiver** | <Title> | <Body> |   

 	##############################_Transactions_################################################
			Then Preparing records in 'InvoicePositions':
			  | OperationTypeId | Amount   | Fee         |
			  | 16              | <Amount> | <Comission> |    
			Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>" internal payment:
			  | State                        | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
			  | WaitingForAutomaticAdmission |         | WaveCrest      | <PurseId>      | WaveCrest        | **Receiver**     | Usd        | EWallet       | <ReceiverIdentityType>                | <UserId> |  
	  
			#QAA-550 (details is not checked)
			Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
			  | Amount      | DestinationId               | Direction | UserId      | CurrencyId | PurseId                       | RefundCount |
			  | <Amount>    | InternalPaymentForNonClient | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Amount>    | InternalPaymentForNonClient | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
			  | <Comission> | InternalPaymentCommission   | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Comission> | InternalPaymentCommission   | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |  
	 
			#QAA-550 (details is not checked)
			#EPA-7315
			Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
			  | CurrencyId | Direction | Destination     | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
			  | Usd        | out       | InternalPayment | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |   
	  
			Then No records in 'TExternalTransactions'

 	##############################_Transactions_################################################
 	
   	Given User closes multiform by clicking on "Закрыть"

 	Then Redirected to /#/transfer/
	Then User refresh the page
	Then eWallet updated sections are:
		| USD    | EUR  | RUB  |
		| -11.00 | 0.00 | 0.00 | 

 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 			| Date         | Name                                         | Amount          |
 			| **DD.MM.YY** | Комиссия за исходящий внутренний перевод     | - $ <Comission> |
 			| **DD.MM.YY** | Перевод новому клиенту ePayments             | - $ <Amount>    |  
 				
 	Given User see statement info for the UserId=<UserId> where DestinationId='InternalPaymentCommission' row № 0 direction='out':
 			| Column1      | Column2                                                                  |
 			| Транзакция № | **TPurseTransactionId**                                                  |
 			| Заказ №      | **InvoiceId**                                                            |
 			| Дата         | **dd.MM.yyyy HH:mm**                                                     |
 			| Продукт      | e-Wallet <PurseId>                                                       |
 			| Получатель   | **Receiver**                                                             |
 			| Сумма        | $ <Comission>                                                            |
 			| Детали       | Commission for outgoing internal payment to **Receiver** from <PurseId>. |      
 	
    Given User see statement info for the UserId=<UserId> where DestinationId='InternalPaymentForNonClient' row № 1 direction='out':
 			| Column1      | Column2                                                  |
 			| Транзакция № | **TPurseTransactionId**                                  |
 			| Заказ №      | **InvoiceId**                                            |
 			| Дата         | **dd.MM.yyyy HH:mm**                                     |
 			| Продукт      | e-Wallet <PurseId>                                       |
 			| Получатель   | **Receiver**                                             |
 			| Сумма        | $ <Amount>                                               |
 			| Детали       | Transfer to a new client to **Receiver** from <PurseId>. |   

#Step 7 
	Given User LogOut

	Given User goes to registration page
	Given User clicks on button "Продолжить"

	Then 'Имя' set FirstName to random text
	Then 'Фамилия' set LastName to random text
	Then User change Country to Россия
	Then 'Электронная почта' set to <ReceiverEmail> when receiver specify his email

	Then 'Пароль' set to '72621010Abac'
	Then 'Дата рождения' set to '01.01.1991'
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
	Given User clicks on button "Регистрация"

	Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33            | email     |  
	Then 'Ввести код вручную' set confirmation code
	Given User clicks on button "Продолжить"

	Then Verification widget appears
	Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 

	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	
	Then 'Номер телефона:' set to <ReceiverPhone> when receiver specify his phone
	
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 5             | **Phone** |  


	Then 'Код из SMS:' set confirmation code
	Given User clicks on "Продолжить"

	Then Verification widget contains 'Подтвердите вашу личность'
	Then 'Гражданство:' citizenship set to 'Россия'

	Given User clicks on "Общегражданский паспорт"
	Then User scrolls down
	Then 'Серия и номер документа:' set to '8811073131'

	Then File "passport.jpg" uploaded for verification
	Then Make screenshot
	Given User clicks on "Продолжить" on verification widget

	Then Verification widget contains 'Укажите адрес проживания'
	Then 'Округ/Область:' set to 'Округ/Область'
	Then 'Город:' set to 'Казань'
	Then 'Индекс:' set to '424003'
	Then 'Адрес:' details set to 'ул. Ленина, д.20.кв.17'
	Then Make screenshot

	Given User clicks on "Продолжить" on verification widget

	Then Set select option to 'Cтраница паспорта с адресом регистрации'
	Then User scrolls down
	
	Then File "3.jpg" uploaded for verification
	Then Make screenshot
	Given User clicks on "Отправить заявку" on verification widget

	Then Verification widget contains 'Заявка на верификацию принята'

## Set user Address verified
	Then Operator set address verified for created user
## Make user KYC2
	Then Operator set created user as verified
	Then User refresh the page
	Then Wait for transactions loading
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                             | Amount     |
 		| **DD.MM.YY** | Перевод новому клиенту ePayments | $ <Amount> | 
	
#EPA - баг на то что Получатель, в поле Получатель указан системный кошелек. 000-406604
	Given User see statement info for created user where DestinationId='InternalPaymentForNonClient' row № 0 direction='in' internal payment:
 			| Column1      | Column2                                                    |
 			| Транзакция № | **TPurseTransactionId**                                    |
 			| Заказ №      | **InvoiceId**                                              |
 			| Дата         | **dd.MM.yyyy HH:mm**                                       |
 			| Продукт      | e-Wallet **ReceiverPurse**                                 |
 			| Получатель   | 000-406604                                                 |
 			| Сумма        | $ <Amount>                                                 |
 			| Детали       | Internal payment to <ReceiverIdentityType> from <PurseId>. |      
#Step 8
	Then User selects records in table 'Notification' for created user with "**SenderInvoiceId**" replacing:
      | MessageType | Priority | Receiver     | Title                          |
      | Email       | 9        | **Receiver** | Верификация аккаунта           |
      | Email       | 9        | **Receiver** | Заявка на верификацию принята  |
      | Email       | 9        | **Receiver** | Контактные данные подтверждены |
      | Sms         | 1        | **Receiver** | -                              |  

#Step 9
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice internal payment**" replacing:
     | MessageType | Priority | Receiver                                                                                                                                                 | Title                                           |
     | Email       | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice internal payment** |
     | PushAndroid | 6        | cLCkHIt61Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                                               |
     | PushIos     | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d947e2                                                                                         | -                                               |  

 # send to new client by Phone	
 @135392
 Examples:
| ReceiverEmail | ReceiverPhone | ReceiverIdentityType | Title				   |  MessageType | SendBy  | Receiver     | Comission | Amount | User                              | UserId                               | Password     | UserPurseId | PurseId    | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            | Body                                                                                                                                                                    |
| random        | Phone         | Phone                | -					   |  Sms         | Телефон | +70006666697 | 1.00      | 10.00  | sendmoneynewperson@qa.swiftcom.uk | efc7a135-33bd-4257-9585-491db78a6e01 | 72621010Abac | 1961743     | 001-961743 | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | Payment of 10 USD has been received from e-Wallet 001-961743. To receive the funds you need to register or bind phone at ePayments.com, if you have already registered. |

 # send to new client by Email
 @3001909
Examples:
| ReceiverEmail | ReceiverPhone | ReceiverIdentityType | Title                 | MessageType | SendBy | Receiver     | Comission | Amount | User                              | UserId                               | Password     | UserPurseId | PurseId    | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            | Body |
| Email         | random        | Email                | New transfer received | Email       | e-mail | +70006666697 | 1.00      | 10.00  | sendmoneynewperson@qa.swiftcom.uk | efc7a135-33bd-4257-9585-491db78a6e01 | 72621010Abac | 1961743     | 001-961743 | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |      |
 

 
  Scenario Outline: V2 Перевод с PUSH/SMS подтверждением(существующему физ/биз/пользователю epa)
# Пользователь зарегистрирован в системе
# Пользователь ФИЗИК
# На секциях кошелька имеется определенное количество средств
# Минимальные и максимальные лимиты для перевода установлены
# У пользователя нет индивидуального роутинга для данного перевода в ExternalCardProviderMappings
# Страница Перевести открыта 
# TransactionConfirmationType.TUsers = 1
# Номер телефона пользователя подтвержден


    Then User updates TransactionConfirmationType="<ConfirmationCode>" for UserId="<UserId>" in table 'TUsers'

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
 	Then 'Получатель' set to '<Receiver>'
 	Then 'Отдаваемая сумма' set to '10.00'
  	Then Section 'Amount including fees' is: $ 11.00 (Комиссия: $ 1.00)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1           | Column2                       |
 		| Со счета          | USD, e-Wallet <SenderPurseId> |
 		| Получатель        | <Receiver>                    |
 		| Отдаваемая сумма  | $ 10.00                       |
 		| Комиссия          | $ 1.00                        |
 		| Сумма с комиссией | $ 11.00                       |
 		| Получаемая сумма  | $ 10.00                       |      
 	Given Set StartTime for DB search
 	Given User clicks on "Подтвердить" on Multiform

    Then User type <ConfirmationCode> sent to:
		| OperationType | Recipient       | UserId   | IsUsed |
		| MassPayment   | <CodeRecipient> | <UserId> | false  |   

	Given Set StartTime for DB search
#Step 6
 	Given User clicks on "Оплатить" on Multiform
 	Then User gets message "Платеж успешно отправлен" on Multiform
 	 	

 	##############################_Transactions_################################################
			Then Preparing records in 'InvoicePositions':
			  | OperationTypeId | Amount   | Fee         |
			  | 16              | <Amount> | <Comission> |    
			Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
			  | State     | Details | SenderSystemId | SenderIdentity  | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
			  | Successed |         | WaveCrest      | <SenderPurseId> | WaveCrest        | <ReceiverPurse>  | Usd        | EWallet       | Purse                | <UserId> |  

			#QAA-550 (details is not checked)
			Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
			  | Amount      | DestinationId             | Direction | UserId      | CurrencyId | PurseId                       | RefundCount |
			  | <Amount>    | TransferToPurse           | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Amount>    | TransferToPurse           | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
			  | <Comission> | InternalPaymentCommission | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Comission> | InternalPaymentCommission | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
			  | <Comission> | InternalPaymentCommission | out       | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
			  | <Comission> | InternalPaymentCommission | in        | <EPSUserId> | Usd        | 406604                        | 0           |  

			#QAA-550 (details is not checked)
			Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
			  | CurrencyId | Direction | Destination     | UserId   | Amount | AmountInUsd   | Product         | ProductType |
			  | Usd        | out       | InternalPayment | <UserId> | 10.00  | **Generated** | <SenderPurseId> | Epid        |   
	  
			Then No records in 'TExternalTransactions'
 	##############################_Transactions_################################################
 	
   	Given User closes multiform by clicking on "Закрыть"

 	Then Redirected to /#/transfer/
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 			| Date         | Name                                         | Amount          |
 			| **DD.MM.YY** | Комиссия за исходящий внутренний перевод     | - $ <Comission> |
 			| **DD.MM.YY** | Внутренний перевод                           | - $ <Amount>    |  
 				
 	Given User see statement info for the UserId=<UserId> where DestinationId='InternalPaymentCommission' row № 0 direction='out':
 			| Column1      | Column2                                                                      |
 			| Транзакция № | **TPurseTransactionId**                                                      |
 			| Заказ №      | **InvoiceId**                                                                |
 			| Дата         | **dd.MM.yyyy HH:mm**                                                         |
 			| Продукт      | e-Wallet <SenderPurseId>                                                     |
 			| Получатель   | <ReceiverPurse>                                                              |
 			| Сумма        | $ <Comission>                                                                |
 			| Детали       | Commission for outgoing internal payment to <Receiver> from <SenderPurseId>. |          
 	
    Given User see statement info for the UserId=<UserId> where DestinationId='TransferToPurse' row № 1 direction='out':
 			| Column1      | Column2                                              |
 			| Транзакция № | **TPurseTransactionId**                              |
 			| Заказ №      | **InvoiceId**                                        |
 			| Дата         | **dd.MM.yyyy HH:mm**                                 |
 			| Продукт      | e-Wallet <SenderPurseId>                             |
 			| Получатель   | <ReceiverPurse>                                      |
 			| Сумма        | $ <Amount>                                           |
 			| Детали       | Internal payment to <Receiver> from <SenderPurseId>. |  

#Step 9
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
     | MessageType   | Priority | Receiver                                                                                                                                                 | Title                          |
     | Email         | 6        | <User>                                                                                                                                                   | Отчет по операции №**Invoice** |
     | PushAndroid   | 6        | cLCkHIt61Rg:APA91bH1wbbomcaNRtCx31-cBrYKXzddd7I_H3zzlb7QK0tyZ7iCvXvQmypLfF0ehETKlUCSQkdmj-aPK33W6kz-29FsoM6svvxRv9PgPN7_GbVHovgbQS0Hqj-eJYXubjEtQXM9ra7T | -                              |
     | PushIos       | 6        | 55954f64ce084e09330cd74a746708cb610c1c10db847ae57c69f58aa2d947e2                                                                                         | -                              |  


#перевод физу PushCode
	@3254400
Examples:
   | CodeRecipient                        | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                                | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
   | AADD5197-4BF3-426F-A730-2E84822C7CC0 | PushCode         | +70009990027 | 001-729570    | +70027804391 | 1.00      | 10.00  | v2smsinternalpayment@qa.swiftcom.uk | 7d6d9819-9be1-47cd-8193-a4798274d39f | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-063756    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


#перевод бизу PushCode
	@3393745
Examples:
    | CodeRecipient                        | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                                | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
    | AADD5197-4BF3-426F-A730-2E84822C7CC0 | PushCode         | +70004562152 | 000-637140    | +70027804391 | 1.00      | 10.00  | v2smsinternalpayment@qa.swiftcom.uk | 7d6d9819-9be1-47cd-8193-a4798274d39f | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-063756    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


#перевод физу SMSCode
	@3254400
Examples:
    | CodeRecipient | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                                | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
    | +70027804391  | SMSCode          | +70009990027 | 001-729570    | +70027804391 | 1.00      | 10.00  | v2smsinternalpayment@qa.swiftcom.uk | 7d6d9819-9be1-47cd-8193-a4798274d39f | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-063756    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  

#перевод бизу SMSCode
   	@3334792
Examples:
   | CodeRecipient | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                                | UserId                               | Password     | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
   | +70027804391  | SMSCode          | +70004562152 | 000-637140    | +70027804391 | 1.00      | 10.00  | v2smsinternalpayment@qa.swiftcom.uk | 7d6d9819-9be1-47cd-8193-a4798274d39f | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-063756    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  


Scenario Outline: Массовый перевод на кошельки
    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page
 
 	Given User clicks on Перевести menu
 	Given User clicks on "Пользователям ePayments"
 
 	Then Section 'Amount including fees' is: 1 $ 0.00 (Комиссия: $ 0.00)
 	Given User see limits table in MassPayment
 		| Description                                      | USD       | EUR       | RUB       |
 		| Минимальная сумма каждого перевода с комиссией:  | $ 0.10USD | € 0.10EUR | ₽ 1.00RUB |
 		| Максимальная сумма каждого перевода с комиссией: | нет       | нет       | нет       |
 		| Комиссия каждого перевода:                       | 0%        | 0%        | 0%        |  
 	Then 'Отправитель' value is '001-<UserPurseId>'
 	Given 'Получатель' selector is "Кошелек" and contains:
     	| Options |
     	| Кошелек |
     	| Телефон |
     	| e-mail  | 
 	Then Placeholder for 'Получатель' is '000-000000'
 	Then 'Получатель' selector set to 'e-mail'
 	Then Placeholder for 'Получатель' is 'Введите e-mail'
 	Then 'Получатель' selector set to 'Телефон'
 	Then Placeholder for 'Получатель' is 'Введите номер телефона'
 
    Given 'Сумма' selector is "USD" and contains:
     	| Options       |
     	| USD           | 
     	| EUR           | 
     	| RUB           | 
    Given 'Сумма с комиссией' selector is "USD" and contains:
     	| Options |
     	| USD     |
     	| EUR     |
     	| RUB     |  
 	Then Make screenshot
 	Then User clicks on ADD
 	Then New fieldset appears
 	Then Make screenshot
 	Then User clicks on Close
 
 	Then 'Сумма' set to '0.01'
 	Then Validating message 'Сумма перевода меньше  $ 0.10' appears on MultiForm
 
 	Then 'Сумма с комиссией' set to '10000000'
     Then Validating message 'Сумма с комиссией превышает баланс' appears on MultiForm
     Then 'Сумма с комиссией' set to '200'
 
 	Given User clicks on "Загрузка CSV-файла с параметрами платежей"
 	Then File "Sample_file_for_mass_internal_payment_negative.csv" uploaded
 	Then Alert Message "Line 1: Строка invalid: Номер кошелька указан неверно" appears
 	Then File "Sample_file_for_mass_internal_payment.csv" uploaded
 	Then Section 'Amount including fees' is: 2 $ 10.27 + ₽ <Amount2> (Комиссия: $ 0.00 + ₽ 0.00)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1                | Column2                    |
 		| Отправитель            | e-Wallet 001-<UserPurseId> |
 		| Количество получателей | 2                          |
 		| Сумма                  | $ 10.27 + ₽ <Amount2>      |
 		| Комиссия               | $ 0.00 + ₽ 0.00            |
 		| Сумма с комиссией      | $ 10.27 + ₽ <Amount2>      |      
 	Given User see Receiver table
 		| Number | Recipient                        | Amount      | Fees   | Total       | Details                  |
 		| 1      | 001-399202                       | $ 10.27     | $ 0.00 | $ 10.27     | payment under a contract |
 		| 2      | sample@google.com (Новый клиент) | ₽ <Amount2> | ₽ 0.00 | ₽ <Amount2> | Agreement no.1           |  
 	
 	Given User clicks on "Назад"
 	Then Section 'Amount including fees' is: 2 $ 10.27 + ₽ <Amount2> (Комиссия: $ 0.00 + ₽ 0.00)
 	Then 'Сумма' set to '<Amount2>'
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1                | Column2                   |
 		| Отправитель            | e-Wallet 001-<UserPurseId>       |
 		| Количество получателей | 2                         |
 		| Сумма                  | $ <Amount1> + ₽ <Amount2> |
 		| Комиссия               | $ 0.00 + ₽ 0.00           |
 		| Сумма с комиссией      | $ <Amount1> + ₽ <Amount2> |    
 	Given Set StartTime for DB search
 	Given User see Receiver table
 		| Number | Recipient                        | Amount      | Fees   | Total       | Details                  |
 		| 1      | 001-399202                       | $ <Amount1> | $ 0.00 | $ <Amount1> | payment under a contract |
 		| 2      | sample@google.com (Новый клиент) | ₽ <Amount2> | ₽ 0.00 | ₽ <Amount2> | Agreement no.1           |   
 
 	Given User clicks on "Подтвердить"
    Then User type SMS sent to:
		| OperationType           | Recipient    | UserId   | IsUsed |
		| PaymentOperationConfirm | +70068002905 | <UserId> | false  |  
 	Given Set StartTime for DB search
 	Then Memorize eWallet section
 
 	Given User clicks on "Оплатить"
 	Then Success message "Платеж успешно выполнен×" appears
 	#[EPA-5445]
 	Given User see table
 		| Column1                | Column2                    |
 		| Статус                 | Успешно                    |
 		| Отправитель            | e-Wallet 001-<UserPurseId> |
 		| Количество получателей | 2                          |
 		| Сумма                  | $ <Amount1> + ₽ <Amount2>  |
 		| Комиссия               | $ 0.00 + ₽ 0.00            |
 		| Итого                  | $ <Amount1> + ₽ <Amount2>  |   
 	Given User see Receiver table
 		| Number | Recipient         | Amount      | Fees   | Total       | Details                  |
 		| 1      | 001-399202        | $ <Amount1> | $ 0.00 | $ <Amount1> | payment under a contract |
 		| 2      | sample@google.com | ₽ <Amount2> | ₽ 0.00 | ₽ <Amount2> | Agreement no.1           |   
 	Given User clicks on "Закрыть"
 
  ##############################_Transactions_################################################
 	Given Check 1 of 2 transaction for last BatchOperationGuid where UserId="<UserId>" and ReceiverIdentity="001-399202"
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount    | Fee         |
 	  | 16              | <Amount1> | <Comission> |  
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State     | Details    | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | Successed | <Details1> | WaveCrest      | 001-<UserPurseId> | WaveCrest        | <Receiver1>      | Usd        | EWallet       | Purse                | <UserId> |  
 	
 	
 	#QAA-550 (details is not checked)
    Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
 	  | Amount    | DestinationId   | Direction | UserId           | CurrencyId | PurseId            | RefundCount |
 	  | <Amount1> | TransferToPurse | out       | <UserId>         | Usd        | 1<UserPurseId>     | 0           |
 	  | <Amount1> | TransferToPurse | in        | <RecieverUserId> | Usd        | <Receiver1PurseId> | 0           |  
 
 	#QAA-550 (details is not checked)
 	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
 	  | CurrencyId | Direction | Destination     | UserId           | Amount    | AmountInUsd | Product           | ProductType |
 	  | Usd        | out       | InternalPayment | <UserId>         | <Amount1> | <Amount1>   | 001-<UserPurseId> | Epid        |
 	  | Usd        | in        | InternalPayment | <RecieverUserId> | <Amount1> | <Amount1>   | <Receiver1>       | Epid        |   
    
 	Then No records in 'TExternalTransactions'
 	
 	##############################_Transactions_################################################
 	Given Reset checkers
 
 	Given Check 2 of 2 transaction for last BatchOperationGuid where UserId="<UserId>" and ReceiverIdentity="sample@google.com"
 	Then Preparing records in 'InvoicePositions':
 	  | OperationTypeId | Amount    | Fee         |
 	  | 114             | <Amount2> | <Comission> |  
 	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
 	  | State                        | Details    | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
 	  | WaitingForAutomaticAdmission | <Details2> | WaveCrest      | 001-<UserPurseId> | WaveCrest        | <Receiver2>      | Rub        | EWallet       | Email                | <UserId> |  
 	
 	
 	#QAA-550 (details is not checked)
    Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
 	  | Amount    | DestinationId               | Direction | UserId              | CurrencyId | PurseId                  | RefundCount |
 	  | <Amount2> | InternalPaymentForNonClient | out       | <UserId>            | Rub        | 1<UserPurseId>           | 0           |
 	  | <Amount2> | InternalPaymentForNonClient | in        | <SystemPurseUserId> | Rub        | <TransfersSystemPurseId> | 0           |  
 
 	#QAA-550 (details is not checked)
 	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
 	  | CurrencyId | Direction | Destination                | UserId   | Amount    | AmountInUsd   | Product           | ProductType |
 	  | Rub        | out       | InternalPaymentToNewClient | <UserId> | <Amount2> | **Generated** | 001-<UserPurseId> | Epid        |   
      
 	Then No records in 'TExternalTransactions'
 	
 
 	   ##############################_Transactions_################################################
 	   Then eWallet updated sections are:
 		| USD        | EUR  | RUB        |
 		| -<Amount1> | 0.00 | -<Amount2> |  
 
 	Then Redirected to /#/transfer/
 	Then Wait for transactions loading
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 		| Date         | Name                             | Amount        |
 		| **DD.MM.YY** | Перевод новому клиенту ePayments | - ₽ <Amount2> |
 		| **DD.MM.YY** | Внутренний перевод               | - $ <Amount1> |  
 	Then User selects records in table 'Notification' for UserId="00000000-0000-0000-0000-000000000000"
       | MessageType | Priority | Receiver          | Title                 |
       | Email       | 6        | sample@google.com | New transfer received |  
 	  #[EPA-5472]
 	#Then User selects records in table 'Notification' where UserId="67FFD7BB-3415-4A63-B62C-0B12EE0F692E" with "**Invoice**" replacing:
    #   | MessageType | Priority | Receiver                    | Title                                |
     #  | Email       | 6        | bc6ec247688e597a7894fff9e3.autotest@qa.swiftcom.uk | Report for operation No. **Invoice** |  
 	Then User selects records in table 'Notification' for UserId="<UserId>"
       | MessageType | Priority | Receiver                                                                                                                                                 | Title |
       | PushAndroid | 13        | ecAFO1HKm8o:APA91bEWPkpSj7H4ZguawcPhLKZjIPRqDHlsbA6BR394uQ7HAtwGwwpg2UBiUdzY3mzMZjMHDIAxHqQqruZ95LZGY3rpjssXXkR6hsXVOM_S0gq00NG5bdT22MF5LOMWQ9kM66s2Edw- | -     |
       | PushIos     | 13        | 44a434d54e72c4df41f40a0cdbe362a4bf2a86f9f52ceafd36b7b9573bee2fed                                                                                         | -     |     
 
 	@135423
 	Examples:
     | paymentCodePhone | UserPurseId | User         | UserId                               | Password     | Receiver1  | Receiver1PurseId | Amount1 | Details1                 | Receiver2         | Amount2 | Details2       | Comission | SystemPurseUserId                    | RecieverUserId                       | TransfersSystemPurseId |
     | +70068002905     | 574909      | +70068002905 | 08bc4d2d-8276-4e92-b57f-28f9ef9bfc4c | 72621010Abac | 001-399202 | 1399202          | 10.27   | payment under a contract | sample@google.com | 5.55    | Agreement no.1 | 0.00      | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 98D6EFA7-1D17-4E4A-AF84-882D55FE128B | 1100                   |  





Scenario Outline: V1 Обработка просроченного внутреннего перевода новому клиенту 
	# Проверять для перевода по v1
	# Машинки лежат здесь: ftp://78.140.172.80/tools/
	# Доступ по RDP: K:\epayments\sandbox\<имя тулы>\<самая свежая по дате изменения папка>
	# 
	# Логи после прогона машинки проверить на наличие error
	# путь:
	# K:\logs\tools\WaitingInvoiceHandler


    #Then User updates TransactionConfirmationType="<ConfirmationCode>" for UserId="<UserId>" in table 'TUsers'
 

    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

#Step 1  	
 	Given User clicks on Перевести menu

#Step 2
 	Given User clicks on "Пользователям ePayments"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Then 'Получатель' selector set to 'e-mail'
	
	Then 'Получатель' set to random Email

#Step 3 
 	Then 'Сумма' set to '10.00'
  	Then Section 'Amount including fees' is: $ 10.00 (Комиссия: $ 0.00)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1                | Column2                  |
 		| Отправитель            | e-Wallet <SenderPurseId> |
 		| Количество получателей | 1                        |
 		| Сумма                  | $ 10.00                  |
 		| Комиссия               | $ 0.00                   |
 		| Сумма с комиссией      | $ 10.00                  |  
		
	Given User see Receiver table
 		| Number | Recipient                   | Amount  | Fees   | Total   | Details |
 		| 1      | **Receiver** (Новый клиент) | $ 10.00 | $ 0.00 | $ 10.00 | -       |  
 
	Then Memorize eWallet section

 	Given Set StartTime for DB search
 	Given User clicks on "Подтвердить" on Multiform

    Then User type SMSCode sent to:
		| OperationType | Recipient     | UserId   | IsUsed |
		| PaymentOperationConfirm   | <SenderPhone> | <UserId> | false  |    

	Given Set StartTime for DB search
#Step 6
 	Given User clicks on "Оплатить" on Multiform

 	Then Success message "Платеж успешно выполнен×" appears
	Given User see table
 		| Column1                | Column2             |
 		| Статус                 | Успешно             |
 		| Отправитель            | e-Wallet 001-359821 |
 		| Количество получателей | 1                   |
 		| Сумма                  | $ 10.00             |
 		| Комиссия               | $ 0.00              |
 		| Итого      | $ 10.00             |  
 	
   	Given User closes multiform by clicking on "Закрыть"

 	Then Redirected to /#/transfer/
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 			| Date         | Name                             | Amount    |
 			| **DD.MM.YY** | Перевод новому клиенту ePayments | - $ 10.00 |  
 				
 	Given User see statement info for the UserId=<UserId> where DestinationId='InternalPaymentForNonClient' row № 0 direction='out':
 			| Column1      | Column2                                   |
 			| Транзакция № | **TPurseTransactionId**                   |
 			| Заказ №      | **InvoiceId**                             |
 			| Дата         | **dd.MM.yyyy HH:mm**                      |
 			| Продукт      | e-Wallet <SenderPurseId>                  |
 			| Получатель   | **Receiver**                              |
 			| Сумма        | $ 10.00                                   |
 			| Детали       | Transfer to a new client to **Receiver**. |       
 	
	Then eWallet updated sections are:
		| USD  | EUR  | RUB   |
		| -10.00 | 0.00 | 0.00 | 


	Then User updates records in table 'Invoices' for UserId="<UserId>":
		| UserId  | PayDate                    | CreationDate               |
		| <Token> | *today-14d(time 00.00.00)* | *today-14d(time 00.00.00)* | 

	When User download and executes "Tools.WaitingInvoiceHandler"

	Then User refresh the page

	Given User see transactions list contains:
 			| Date         | Name                             | Amount    |
 			| **DD.MM.YY** | Перевод новому клиенту ePayments |  $ 10.00 |


	Then eWallet updated sections are:
		| USD  | EUR  | RUB   |
		| +10.00 | 0.00 | 0.00 | 


#перевод бизу SMSCode
   	@3334792
Examples:
   | CodeRecipient | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                               | UserId                               | Password      | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
   | +70027804391  | SMSCode          | +70004562152 | 000-637140    | +70068318139 | 1.00      | 10.00  | WMmassPayment_bysms@qa.swiftcom.uk | 479a30da-80ce-46bd-be24-810e3e8e7b91 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-359821    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  




Scenario Outline: Рефанд инвойса внутреннего перевода(V1) из админки
#Отправитель: бизнес клиент, Approved, КУС2
#Получатель: биз, физ, Approved, КУС2

    Given User goes to SignIn page
 	Given User signin "Epayments" with "<User>" password "<Password>"
 	Given User see Account Page

#Step 1  	
 	Given User clicks on Перевести menu

#Step 2
 	Given User clicks on "Пользователям ePayments"
 	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
 	Then 'Получатель' selector set to 'e-mail'
	
	Then 'Получатель' set to random Email

#Step 3 
 	Then 'Сумма' set to '10.00'
  	Then Section 'Amount including fees' is: $ 10.00 (Комиссия: $ 0.00)
 	Given User clicks on "Далее" on Multiform
 	Given User see table
 		| Column1                | Column2                  |
 		| Отправитель            | e-Wallet <SenderPurseId> |
 		| Количество получателей | 1                        |
 		| Сумма                  | $ 10.00                  |
 		| Комиссия               | $ 0.00                   |
 		| Сумма с комиссией      | $ 10.00                  |  
		
	Given User see Receiver table
 		| Number | Recipient                   | Amount  | Fees   | Total   | Details |
 		| 1      | **Receiver** (Новый клиент) | $ 10.00 | $ 0.00 | $ 10.00 | -       |  
 
	Then Memorize eWallet section

 	Given Set StartTime for DB search
 	Given User clicks on "Подтвердить" on Multiform

    Then User type SMSCode sent to:
		| OperationType           | Recipient     | UserId   | IsUsed |
		| PaymentOperationConfirm | <SenderPhone> | <UserId> | false  |   

	Given Set StartTime for DB search
#Step 6
 	Given User clicks on "Оплатить" on Multiform

 	Then Success message "Платеж успешно выполнен×" appears
	Given User see table
 		| Column1                | Column2             |
 		| Статус                 | Успешно             |
 		| Отправитель            | e-Wallet 001-359821 |
 		| Количество получателей | 1                   |
 		| Сумма                  | $ 10.00             |
 		| Комиссия               | $ 0.00              |
 		| Итого                  | $ 10.00             |    
 	
   	Given User closes multiform by clicking on "Закрыть"





 	Then Redirected to /#/transfer/
 	Given User clicks on Отчеты menu
 	Given User see transactions list contains:
 			| Date         | Name                             | Amount    |
 			| **DD.MM.YY** | Перевод новому клиенту ePayments | - $ 10.00 |  
 				
 	Given User see statement info for the UserId=<UserId> where DestinationId='InternalPaymentForNonClient' row № 0 direction='out':
 			| Column1      | Column2                                   |
 			| Транзакция № | **TPurseTransactionId**                   |
 			| Заказ №      | **InvoiceId**                             |
 			| Дата         | **dd.MM.yyyy HH:mm**                      |
 			| Продукт      | e-Wallet <SenderPurseId>                  |
 			| Получатель   | **Receiver**                              |
 			| Сумма        | $ 10.00                                   |
 			| Детали       | Transfer to a new client to **Receiver**. |       

    Then Operator confirms Invoice refund
    Then User gets VerificationCode in table 'ConfirmationCodes' where:
	  | OperationType | Recipient     |
	  | 20            | +70002342342 |  
    Then Operator refunds last invoice for UserId=<UserId>


 	##############################_Transactions_################################################
			Then Preparing records in 'InvoicePositions':
			  | OperationTypeId | Amount   | Fee         |
			  | 73              | <Amount> | <Comission> |    
			Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>" internal payment:
			  | State    | Details | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType   | UserId   |
			  | Refunded |         | WaveCrest      | <PurseId>      | WaveCrest        | **Receiver**     | Usd        | EWallet       | <ReceiverIdentityType> | <UserId> |  
	  
			#QAA-550 (details is not checked)
			Then New records appears in 'TPurseTransactions' for UserId="<UserId>":
			  | Amount      | DestinationId               | Direction | UserId      | CurrencyId | PurseId                       | RefundCount |
			  | <Amount>    | InternalPaymentForNonClient | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Amount>    | InternalPaymentForNonClient | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |
			  | <Comission> | InternalPaymentCommission   | out       | <UserId>    | Usd        | <UserPurseId>                 | 0           |
			  | <Comission> | InternalPaymentCommission   | in        | <EPSUserId> | Usd        | <EPS-02TemporaryStoragePurse> | 0           |  
	 
			#QAA-550 (details is not checked)
			#EPA-7315
			Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<UserId>":
			  | CurrencyId | Direction | Destination     | UserId   | Amount   | AmountInUsd   | Product   | ProductType |
			  | Usd        | out       | InternalPayment | <UserId> | <Amount> | **Generated** | <PurseId> | Epid        |   
	  
			Then No records in 'TExternalTransactions'

 	##############################_Transactions_################################################



#перевод бизу SMSCode
   	@433730
Examples:
   | CodeRecipient | ConfirmationCode | Receiver     | ReceiverPurse | SenderPhone  | Comission | Amount | User                               | UserId                               | Password      | SystemPurseUserId                    | UserPurseId | SenderPurseId | SystemPurseId | EPS-02TemporaryStoragePurse | EPSUserId                            |
   | +70027804391  | SMSCode          | +70004562152 | 000-637140    | +70068318139 | 0.00      | 10.00  | WMmassPayment_bysms@qa.swiftcom.uk | 479a30da-80ce-46bd-be24-810e3e8e7b91 | 72621010Abac | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1063756     | 001-359821    | 122122        | 144177                      | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 |  
