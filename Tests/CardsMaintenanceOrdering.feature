@Cards
Feature: CardsMaintenanceOrdering

@433744 
Scenario Outline: Продление бесплатного обслуживания
# select top(100) ProxyPANCode,CardServiceExpireAt, ServiceActivationDate  from sb_epayments.[dbo].[TCards]  where ProxyPANCode='466579827'
# select top(100) * from sb_epayments_ehi_transactions.[dbo].[CardServicePeriods] where CardAccount='5$$RqqbJGECEmYH1qGw89w==' order by 1 desc
# select top(100) * from sb_epayments_ehi_transactions.[dbo].[CardTransaction] where CardAccount='5$$RqqbJGECEmYH1qGw89w==' order by Created desc
# select top(100) * from sb_epayments_ehi_transactions.[dbo].[CardServicePeriodHistory] where CardServicePeriodId IN (117055,117056)
#delete from sb_epayments_ehi_transactions.[dbo].[CardServicePeriods]  where Id IN (13929)
#delete from sb_epayments_ehi_transactions.[dbo].[CardServicePeriodHistory] where CardServicePeriodId in (117055,117056)


	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание:13.03.18" with replacing month
	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card 
	Then Scale "" appears on "USD" card
	Then Make screenshot
	Given Set StartTime for DB search

	When User executed POS transaction with amount <USDAmount> for user "<User>" with Token "<Token>"
 
	Then User updates records in table 'CardTransaction': 
		| OriginalLink | Created                    |
		| <Trans_link> | *yesterday(time 23.59.59)* |  
	
	Then User refresh the page
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
    Then Message "Обслуживание:13.03.18" with replacing month
	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Следующий месяц обслуживания бесплатно" appears on "USD" card
 	Then Make screenshot
	Then User updates records in table 'CardServicePeriods':
		| Token   | StartDate                  | EndDate                   |
		| <Token> | *today-31d(time 00.00.00)* | *yesterday(time 00.00.00)* |  

	Then User updates records in table 'Cards' on 'yesterday-1d time 00.00.00':
		| ProxyPANCode | CardServiceExpireAt           |
		| <Token>      | *yesterday-1d time 00.00.00* |  
		
 	When User download and executes "CardMaintenance.DailyService"
	Then User refresh the page
	Then User clicks on CardAndAccounts
	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание:13.03.18" with replacing month
	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Message "Получите следующий месяц обслуживания бесплатно при совершении покупок на $ 300" appears on "USD" card
	Then Message "Сделано покупок на" appears on "USD" card
	Then Message "0 / 300 USD" appears on "USD" card
	Then Scale "" appears on "USD" card
	Then Make screenshot
# [https://jira.swiftcom.uk/browse/EPA-4528]
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TXn_ID**" replacing:
		| MessageType | Priority | Receiver   | Title                                         |
		| Email       | 8        | <User>     | Бесплатный месяц обслуживания карты ePayments |
		| 3           | 8        | Ynhenmwotd | -                                             |
		| 4           | 8        | Hhherxtwtq | -                                             |  
		| Email       | 5        | <User>     | Отчет по операции №**TXn_ID**                 |
		| 3           | 13       | Ynhenmwotd | -                                             |
		| 4           | 13       | Hhherxtwtq | -                                             |  

Examples:
	| User                    | UserId                               | Password            | Token            | USDAmount | paymentpwd |
	| tazg@ya.ru              | E36286E9-A802-47A0-B694-40DCFF14371A | 72621010Abaccc      | 466579827        | -333      | 111111     |                 



	@329240
Scenario Outline: Регистрация/блокировка NP карты
	Then User creates NP Card
	Then User selects records in 'Ws_BulkCreation' and Request parameter ProductRef = NP 

	Given User lands on "Card Registration"
	Then User fills FullPAN
	Given User fills Phone number
    Given Set StartTime for DB search
	Given User clicks Submit
	Given Captcha submitted
	Then Make screenshot
	Given User clicks Submit

	Given User fills password "72621010Abac" 

	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
	  | OperationType | Recipient |
	  | 8             | **Phone** |  

	Given User fills VerificationCode
	Given User clicks Submit
	
	Given User fills Personal Details:
		| FirstName   | LastName   | DOB               | Country | Email             |
		| <Name>      | <LastName> | **Autogenerated** | Россия  | **Autogenerated** |  
   
   Then User selects records in 'Users' for created user by phone:
	  | KYCId              | UserRole | State | IsPep | PasswordExpireAt      |
	  | <KYCId_before_reg> | 63       | Lead  | 0     | **valid for 6 month** |  

	Then User selects records in table 'EpaZendeskUser' for created by promo card form user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   
	
	Given User clicks Submit
	
	Given User fills Activation Details:
	   | Country | State | City  | Index  | Address | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | Россия  | Штат  | Город | 424003 | Адрес   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
 	
	Given User clicks Submit
	Then Text message "ВАША КАРТА УСПЕШНО ЗАРЕГИСТРИРОВАНА" appears
	
	Then User selects records in 'Cards' for created user:
		| ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt | CardStateId |
		| **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   | Active      |  

    Then User selects records in 'Users' for created user by phone:
		| KYCId             | UserRole | State   | IsPep | PasswordExpireAt      |
		| <KYCId_after_reg> | 185      | <State> | 0     | **valid for 6 month** |     
			
	Then Modal window 'needAgreeMemberTerms' is opened
		 
	Then Click on Согласен(-а) on Modal Window

	Then User clicks on CardAndAccounts
	Then Click on Верифицировать аккаунт on Modal Window for unverified user
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Given User clicks on "Подтвердить E-mail"
	Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient  |
		  | 4            | **Email** |  

	Then 'Код из письма:' set confirmation code
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

	  #########################
	Then User clicks on CardAndAccounts

	Given User clicks on "Обслуживание:" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Message "Обслуживание:**today+2 month**" with replacing date
	Then Message "Сумма $ 2.9 будет списана автоматически в день окончания обслуживания." appears on "USD" card
	Then Make screenshot

#Block NP Card and check product REF
	Then User updates balance="10" "Usd" in table 'TPurseSections' for created user

	Then User clicks on CardAndAccounts
	Given User clicks on "Заблокировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Click on Заблокировать on Modal Window
	Given User clicks on "Перевыпустить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then User selects delivery address="Россия, Штат, 424003, Город, Адрес" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> | 
	   
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                             |
		| Валюта карты                                  | USD                                 |
		| Адрес доставки                                | Россия, Штат, 424003, Город, Адрес  |
		| Тип доставки                                  | Почта России (с кодом отслеживания) |
		| Перевыпуск карты ePayments                    | $ 5.95                              |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                              |
		| Итого                                         | $ 5.95                              | 
		
	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User selects payment eWallet "USD 10.00" on Multiform
	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на перевыпуск карты ePayments принята. Карта будет доставлена в течение 1-3 недели" on Multiform
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1 | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | Адрес       | -           | -           | Город     | Штат        | 424003        | 643          | 643       | PP1        | 1508       |    
	
	Examples:
	| Name | LastName | SecretName  | KYCId_before_reg | KYCId_after_reg | State    | SecretDate | SecretPlace  | SecretCode |
	| Name | LastName | Secret name | 0                | 1               | Approved | 01.01.1998 | Secret place | 123123     |  

	
	@782761
	@VAT_Russia_update
	@UserReference_update
Scenario Outline: Регистрация + Заказ/Перевыпуск карты по реф.ссылке для дизайна карт LightCoBrand

	Given User goes to SignIn page
 	Given User signin "Epayments" with "newBizPartner@qa.swiftcom.uk" password "72621010Abaccc"
	Then User clicks on Invite
	Then User clicks on ADD
	Then User fill create "1" invite link "6fi0q95w4q" with currency "EUR" on Multiform
	Given User clicks on "Создать"
	Then User gets message "Вы успешно создали инвайт(-ы)" on Multiform
	Given User clicks on "Закрыть"
	
	Then User clicks on last created invite link
	Then Make screenshot
	Given User clicks on "Войти" on Landing Page
	 
	Given User goes to registration page
	Given User clicks on button "Продолжить"

	Then Checkbox "Есть промокод?" is checked

	Then Промокод field contains ID of created link
	Then 'Имя' set FirstName to random text
	Then 'Фамилия' set LastName to random text

	Then User change Country to Россия
	Then 'Электронная почта' set to random email
	Then 'Пароль' set to '72621010Abac'
	Then 'Дата рождения' set to '01.01.1991'
	
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
	Given User clicks on button "Регистрация"
	Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	
	Then 'Ввести код вручную' set confirmation code
	Given User clicks on button "Продолжить"

	Then Verification widget appears

################################3

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 
 
## Make account verification request
	
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  

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
	Then 'Округ/Область:' set to 'Округ'
	Then 'Город:' set to 'Город'
	Then 'Индекс:' set to '345345'
	Then 'Адрес:' details set to 'Адрес'
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

	  #########################
   
 	Then User order eur card
	Then User selects delivery address="Россия, Округ, 345345, Город, Адрес" on Multiform

	Given User clicks on "Далее" on Multiform 

	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                       | Column2                                                |
		| Валюта карты                  |    EUR                                                 |
		| Адрес доставки                | Россия, Округ, 345345, Город, Адрес					 |
		| Тип доставки                  | Royal mail                                             |
		| Выпуск первой карты ePayments | € 0.00                                                 |
		| Доставка: Royal mail          | € 0.00                                                 |
		| Итого:                        | € 0.00                                                 |  
	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform

	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
	| DelvMethod | Delv_AddrL1 | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | ImageId | CardDesign |
	| 0          | Adres       |      -       |      -       | Gorod     | Okrug       | 345345    | 643          | 826       | LC         | image1  | 1510       |  
	
	
   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 64              | 0.00   | 4.95 |
	  | 94              | 0.00   | 0.74 |   
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<RefLinkOwner>":
	   | State     | Details                    | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity |  CurrencyId | PaymentSource | ReceiverIdentityType | UserId         |
	   | Successed | Pay business for user card | WaveCrest      | 000-218956     | WaveCrest        | 000-121121       |  Eur        | EWallet       | NotRecognized        | <RefLinkOwner> |  

	Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<RefLinkOwner>":
	  | Amount | DestinationId     | Direction | UserId                               | CurrencyId | PurseId | RefundCount |
	  | 4.95   | FirstCardByInvite | out       | <RefLinkOwner>                       | Eur        | 218956  | 0           |
	  | 4.95   | FirstCardByInvite | in        | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | Eur        | 121121  | 0           |
	  | 0.74   | Vat               | out       | <RefLinkOwner>                       | Eur        | 218956  | 0           |
	  | 0.74   | Vat               | in        | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | Eur        | 121121  | 0           |  

     Given Reset checkers

	Then Preparing records in 'InvoicePositions':
	   | OperationTypeId | Amount | Fee  | 
	   | 56              | 0.00   | 0.00 | 
	   | 54              | 0.00   | 0.00 |  
	Then User selects records in 'Invoices' for created user by email with replacing fields:
	  | State     | Details              | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId              |
	  | Successed | ePayments card order | 1              | 001-           | 1                | 000-121121       | Eur        | EWallet       | NotRecognized        | **created user id** |  
	
   	##############################_Transactions_################################################

	Then User selects records in table 'BonusProgramClients' for created user:
        | BonusRefOwnerId | IsActive | UtmSource | UtmMedium | UtmTerm | UtmContent | UtmCampaign | LinkType | Link       |
        | <RefLinkOwner>  | true     |           |           |         |            |             | Invite   | 6fi0q95w4q |    

	Then Operator blocks EPA Card for created user

	 Then Operator updates CardDesign in UserReference:
	| RefId | UserId         | ReferenceString | AutoApproveContacts | ManualCardCreating | CoBrand |
	| 1417  | <RefLinkOwner> | 6fi0q95w4q      | false               | false              | FF      |  

	
	Then User updates balance="10" "Eur" in table 'TPurseSections' for created user
	Then User refresh the page
	Then Make screenshot
	Then User clicks on CardAndAccounts
	Given User clicks on "Перевыпустить" "EUR" 'Epayments Cards' at CardAndAccounts grid
	Then User selects delivery address="Россия, Округ, 345345, Город, Адрес" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                             |
		| Валюта карты                                  | EUR                                 |
		| Адрес доставки                                | Россия, Округ, 345345, Город, Адрес |
		| Тип доставки                                  | Почта России (с кодом отслеживания) |
		| Перевыпуск карты ePayments                    | € 4.95                              |
		| Доставка: Почта России (с кодом отслеживания) | € 0.00                              |
		| Налог на добавленную стоимость                | € 0.74                              |
		| Итого                                         | € 5.69                              |  
	Given User clicks on "Заказать" on Multiform 

    Then User selects payment eWallet "EUR 10.00" on Multiform
	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на перевыпуск карты ePayments принята. Карта будет доставлена в течение 1-3 недели" on Multiform
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_Update_Cardholder_Details:
		| dlvMethod | dlvaddr1 | dlvaddr2 | dlvaddr3 | dlvcity | dlvcounty | dlvpostcode | dlvcountry | Delv_Code | imageID | crddesign |
		| 0         | Адрес    |   -    |   -          | Город   | Округ      | 345345  | 643        | 643       | -       | FF        |  


	Then Operator gets client info by card
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CardHolder_Details_Enquiry_V2:
		| CrdDesign | ImageID |
		| FF        | -       |  

  Examples:
	| RefLinkOwner                         | SecretName  | SecretDate | SecretPlace  | SecretCode | Delv_AddrL1 | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County | Delv_PostCode | Delv_Country |
	| edea918c-407d-4383-8581-40029941c14c | Secret name | 01.01.1998 | Secret place | 123123     | адрес       | адрес2      | адрес3      | город     | штат        | индекс 123    | Россия       |  


	@135405 
	@Auto_card_creating_OFF
Scenario Outline: Заказ первой/второй и активация карты GPS - ручная обработка
# Пользователь имеет KYC1
# Пользователь не санкционный
# Information Block - System availability-Auto card creating = выкл

	Given User goes to registration page
	Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
		
	Given User clicks on button "Регистрация"

	Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	 Then Verification widget appears
	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |

	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  

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

	
	  #########################
   

   Then User updates balance="4.95" "Eur" in table 'TPurseSections' for created user
   Then User updates balance="5.95" "Usd" in table 'TPurseSections' for created user
	

#Order USD card	
	Then User order usd card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform

	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | USD                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Выпуск первой карты ePayments                 | $ 5.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
		| Итого:                                        | $ 5.95                                                        |   
	Given User clicks on "Заказать" on Multiform 
	Then User choose ewallet to pay for card order
    Then 'Источник оплаты' selector set to 'USD' in eWallet section

	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform

	Then Operator clicks on edit card info and save it with CardDeliveryType = RussianPost
    Then Operator creates card
	Then Operator gets client info by card
	
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CardHolder_Details_Enquiry_V2:
		| CrdDesign | ImageID |
		| PP1       | -       |  

	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1                  | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County        | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | ул. Ленина, д.20.кв.17       | -           | -           | Казань    | Округ/Область      | 424003        | 643          | 643       | PP1        | 1508       |    

## Activate Card
	Then Get FullPAN
		
	Then User refresh the page
	Given User clicks on "Активировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Given Set StartTime for DB search
	Then User fills FullPAN
	Given User clicks on "Активировать" on Multiform 
	Given 'Действия с PIN' selector is "Получить PIN" and contains:
    	| Options        |
    	| Получить PIN   |
    	| Установить PIN |  
	Then Make screenshot
	Given User clicks on "Далее" on Multiform 

    Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 105           | **phone** |  
	 Given User fills ConfirmationCode on activation details
	 Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно активирована" on Multiform
	Then User see PIN code
	
	Then User refresh the page		

#Trying to order SECOND card 	
	Then User clicks on CardAndAccounts
    Then User clicks 'Заказать' on Menu

### Set auto card creating to TRUE	
	Then ServiceAvailability 'Auto card creating' set to true

	Then User order eur card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
		Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | EUR                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Выпуск второй карты ePayments                 | € 4.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | € 0.00                                                        |
		| Итого:                                        | € 4.95                                                        |  
	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
    Then 'Источник оплаты' selector set to 'EUR' in eWallet section

	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1                  | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County        | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | ул. Ленина, д.20.кв.17       | -           | -           | Казань    | Округ/Область      | 424003        | 643          | 643       | PP2        | 1510       |    

Examples:
	 | SecretName  | SecretDate | SecretPlace  | SecretCode |
	 | Secret name | 01.01.1998 | Secret place | 123123     |  



	 
	@135411 
Scenario: Блокировка/разблокировка карты GPS c ЛК 

	Given User goes to SignIn page
	Given User signin "Epayments" with "+70015414080" password "72621010Abac"
	Given User see Account Page
	Then User clicks on CardAndAccounts
	Given User clicks on "Заблокировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Click on Заблокировать on Modal Window
	Given User clicks on "Разблокировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Given Set StartTime for DB search
	Then User See EPA card masked PAN='5283930278172858' firstName='MVQHCPANDR' lastName='VOVNTJIPBE'
	Given User clicks on "Разблокировать" on Multiform 
	Then User gets VerificationCode in table 'ConfirmationCodes' where:
		  | OperationType | Recipient    |
		  | 105           | +70015414080 |  
	Given User fills ConfirmationCode on activation details
	Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно разблокирована" on Multiform
	Then Make screenshot
	Given User clicks on "Закрыть" 
	
	Given User clicks on "Заблокировать" "USD" 'Epayments Cards' at CardAndAccounts grid


	@552632 
Scenario Outline: Комиссия за неактивность по карте

# Активность определяется по наличию операций по карте, для которых выполняется условие: 
# CardTransaction.OperationSum != 0.00 AND CardTransaction.OperationSubType = P, A, L, U, B AND CardTransaction.Status = S, А. 
# (balance adjustment являются активностью, за исключением операции снятия комиссии за неактивность и снятия ежемесячного обслуживания)

#Step 1

 	Then User updates records in table 'Cards' and set LastActivityDate to "*today-7m-1d*":
 		| ProxyPANCode | LastActivityDate | 
 		| <Token>      | *today-7m-1d*  |                            
 
    Then User updates records in table 'Cards' and set LastDebitForInactivityDate to "":
 		| ProxyPANCode | LastDebitForInactivityDate |
 		| <Token>      |                            |  
 
	Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
 	Then Memorize EPACards section
 	Given Set StartTime for DB search
 	When User download and executes "CardMaintenance.DailyService"
 	Then User selects record in 'Cards' where token ="<Token>":
 	  | LastDebitForInactivityDate |
 	  | *today*                    | 
	
	 #QAA-550 (details is not checked)  
 	Then User selects records in 'TPurseTransactions' by last OperationGuid where UserId="<UserId>":
 	  | CurrencyId |  Amount | DestinationId | Direction | UserId                                 | PurseId | RefundCount | 
 	  | Usd        |  10.00  | 6             | in        | <UserId>                               | 1064410 | 0           |                     
 	  | Usd        |  10.00  | 85            | out       | <UserId>                               | 1064410 | 0           |                      
 	  | Usd        |  10.00  | 85            | in        | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF   | 121121  | 0           |                      
 
 	Then User selects records in table 'Notification' where UserId="<UserId>" with "**Invoice**" replacing:
      | MessageType | Priority | Receiver                                                                                                                                                 | Title                           |
      | Email       | 5        | 0e61084c308ca224c5b7d41add.autotest@qa.swiftcom.uk                                                                                                       | Отчет по операции № **Invoice** |
      | PushAndroid | 8        | dIgcAO_AJAA:APA91bHPuFje6jC0PnPOnk_Bij_y1K6UR6a1EsZoceyEhZ2DdtPaNSm83HQissbBhTvXia6Q2gtBtj1H03aN7MIwmtsfcCYERdsfumjuzZwQtuBzeV6DFSq7TEllDdpFFYIMwOYox-in |  -                      |
      | PushIos     | 8        | 2d4eaad395433da12bad4e3f1f4091afaba2f19ff7cbb01078143ebde4ab5b6n                                                                                         | -                       |      
  	
	Then User refresh the page
	Then EPA cards updated sections are:
	| USD    | EUR  |
	| -10.00 | 0.00 | 
 #Step 2
 	Then Memorize EPACards section
 
 	Then User updates records in table 'Cards' and set LastActivityDate to "*today-7m-1d*":
 		| ProxyPANCode | LastActivityDate | 
 		| <Token>      | *today-7m-1d*  |                            
 
     Then User updates records in table 'Cards' and set LastDebitForInactivityDate to "*today*":
 		| ProxyPANCode |  LastDebitForInactivityDate |
 		| <Token>      |   *today*                   |
 
 	Given Set StartTime for DB search
 	When User executes "CardMaintenance.DailyService"
 
 	Then User refresh the page
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |  
 
 	 Then User didn't receive Notifications for UserId="<UserId>"
 
 #Step 3
 	Then Memorize EPACards section
 
 	Then User updates records in table 'Cards' and set LastActivityDate to "*today-7m-1d*":
 		| ProxyPANCode | LastActivityDate |
 		|421117843      | *today-7m-1d*    |                              
 
     Then User updates records in table 'Cards' and set LastDebitForInactivityDate to "":
 		| ProxyPANCode | LastDebitForInactivityDate |
 		| 421117843     |                            |  
 
 	Given Set StartTime for DB search
 	When User executes "CardMaintenance.DailyService"
 
 	Then User didn't receive Notifications for UserId="<UserId>"

 	Then User refresh the page
 	Then EPA cards updated sections are:
 		| USD  | EUR  |
 		| 0.00 | 0.00 |  
  #Step 4
 	Then Memorize EPACards section
 
 	Then User updates records in table 'Cards' and set LastActivityDate to "":
 		| ProxyPANCode | LastActivityDate |
 		| <Token>      |                  |                 
 
      Then User updates records in table 'Cards' and set ActivationDate to "*today-6m*":
 		| ProxyPANCode | ActivationDate |
 		| <Token>      | *today-6m*     |  
 
 	Then User updates records in table 'Cards' and set LastDebitForInactivityDate to "":
 		| ProxyPANCode |  LastDebitForInactivityDate |
 		| <Token>      |                             |
 
 	Given Set StartTime for DB search
 	When User executes "CardMaintenance.DailyService"
 
 	Then User selects records in table 'Notification' for UserId="<UserId>"
 		 | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                     |
 		 | Email       | 8        | 0e61084c308ca224c5b7d41add.autotest@qa.swiftcom.uk                                                                                                       | Приближается срок списания комиссии за неактивность карты |
 		 | PushAndroid | 8        | dIgcAO_AJAA:APA91bHPuFje6jC0PnPOnk_Bij_y1K6UR6a1EsZoceyEhZ2DdtPaNSm83HQissbBhTvXia6Q2gtBtj1H03aN7MIwmtsfcCYERdsfumjuzZwQtuBzeV6DFSq7TEllDdpFFYIMwOYox-in |  -                                                        |
 		 | PushIos     | 8        | 2d4eaad395433da12bad4e3f1f4091afaba2f19ff7cbb01078143ebde4ab5b6n                                                                                         | -                                                        |      

 	Then User refresh the page
	Then EPA cards updated sections are:
		| USD  | EUR  |
		| 0.00 | 0.00 |  
#Step 5
	Then Memorize EPACards section

	Then User updates records in table 'Cards' and set LastActivityDate to "":
		| ProxyPANCode | LastActivityDate |
		| <Token>      |                  |                 

    Then User updates records in table 'Cards' and set ActivationDate to "*today-7m+7d*":
		| ProxyPANCode | ActivationDate |
		| <Token>      | *today-7m+7d*  |  

	Then User updates records in table 'Cards' and set LastDebitForInactivityDate to "":
		| ProxyPANCode |  LastDebitForInactivityDate |
		| <Token>      |                             |

	Given Set StartTime for DB search
	When User executes "CardMaintenance.DailyService"
	 
	Then User selects records in table 'Notification' for UserId="<UserId>"
		 | MessageType | Priority | Receiver                                                                                                                                                 | Title                                                     |
		 | Email       | 8        | 0e61084c308ca224c5b7d41add.autotest@qa.swiftcom.uk                                                                                                       | Приближается срок списания комиссии за неактивность карты |
		 | PushAndroid | 8        | dIgcAO_AJAA:APA91bHPuFje6jC0PnPOnk_Bij_y1K6UR6a1EsZoceyEhZ2DdtPaNSm83HQissbBhTvXia6Q2gtBtj1H03aN7MIwmtsfcCYERdsfumjuzZwQtuBzeV6DFSq7TEllDdpFFYIMwOYox-in | -                                                 |
		 | PushIos     | 8        | 2d4eaad395433da12bad4e3f1f4091afaba2f19ff7cbb01078143ebde4ab5b6n                                                                                         | -                                                 |  
	
	Then User refresh the page
	Then EPA cards updated sections are:
		| USD  | EUR  |
		| 0.00 | 0.00 | 
	Examples:
	| User         | UserId                               | Password     | Token     |
	| +70013559801 | 03529943-D580-4665-AB28-BEADA989952C | 72621010Abac | 102719948 |                  

	 


	 @1933910
	 @Auto_card_creating_ON
Scenario Outline: Заказ и перевыпуск карты с ручной обработкой из-за страны без попадания под санкции
  
    ## Пользователь KYC2 Approved не санкционный, у пользователя нет карт, на кошельке достаточно средств для оплаты заказа и перевыпуска карты.
	## Включен автозаказ карт. Условия автозаказа описаны в сценарии https://qa.swiftcom.uk/index.php?/cases/view/349987.
	
	Given User goes to registration page
	Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Армения
	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
	Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |      
		
################################3

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 

## Make account verification request
	
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  


	Then 'Код из SMS:' set confirmation code
	Given User clicks on "Продолжить"

	Then Verification widget contains 'Подтвердите вашу личность'

	Given User clicks on "Удостоверение личности"

	Then 'Серия и номер документа:' set to '8811073131'
	Then 'Действителен до:' set to '06082020'
	Then User scrolls down

	Then File "passport.jpg" uploaded for verification
	Then Make screenshot
	Given User clicks on "Продолжить" on verification widget

	Then Verification widget contains 'Укажите адрес проживания'
	Then 'Округ/Область:' set to 'Okrug'
	Then 'Город:' set to 'Gorod'
	Then 'Индекс:' set to '345345'
	Then 'Адрес:' details set to 'Adres'
	Then Make screenshot

	Given User clicks on "Продолжить" on verification widget

	Then Set select option to 'Выписка с банковского или кредитного счета' 
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

	  #########################

   Then User updates balance="11.9" "Usd" in table 'TPurseSections' for created user

 #Step 1	
	Then User order usd card
	Then User selects delivery address="Adres, Okrug, Gorod, Армения, 345345" on Multiform

	Given User clicks on "Далее" on Multiform 

	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                       | Column2                                           |
		| Валюта карты                  | USD                                               |
		| Адрес доставки                | Adres, Okrug, Gorod, Армения, 345345				|
		| Тип доставки                  | Royal mail                                        |
		| Выпуск первой карты ePayments | $ 5.95                                            |
		| Доставка: Royal mail          | $ 0.00                                            |
		| Итого:                        | $ 5.95                                            | 
		
	Given User clicks on "Заказать" on Multiform 
	Then User choose ewallet to pay for card order
    Then 'Источник оплаты' selector set to 'USD' in eWallet section

	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform
	Then User refresh the page
	 Then EPA card block contains Ожидает выпуска

	Then User selects records in 'Cards' for created user with not-activated card:
		| CardStateId   | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| ManualRequest |              | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  
	
#Step 2
	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State    | IsPep | PasswordExpireAt |
	    | 2     | 62       | Approved | 0     | 9999-12-31       |  
#STEP 3
	Then User selects record in 'SanctionCheck' for created user:
 	  | Scenario           | Status         | IsConfirmedPep |
 	  | BeforeVerification | Not sanctioned | false          |  

#STEP 6
	Then Operator clicks on edit card info and save it with CardDeliveryType = RoyalMail
	Then User selects records in 'Cards' for created user with not-activated card:
		| CardStateId   | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| NewRequest    |              | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  
#STEP 7: 1/2
	Then Operator creates card

#STEP 8
	Then User selects record in 'SanctionCheck' for created user:
		 | Scenario           | Status         | IsConfirmedPep |
		 | BeforeVerification | Not sanctioned | false          |  

#STEP 9
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1    | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | Adres | -           | -           | Gorod    | Okrug    | 345345        | 051          | 826       | PP1        | 1508       |    

#STEP 7: 2/2
	Then User selects records in 'Cards' for created user with replacing ProxyPANCode:
		| CardStateId | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Request     | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |

#STEP 10
 Then Operator blocks EPA Card for created user
   Then User refresh the page
   	Then User clicks on CardAndAccounts

#STEP 12
	Given User clicks on "Перевыпустить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then User selects delivery address="Adres, Okrug, Gorod, Армения, 345345" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                    | Column2                                           |
		| Валюта карты               | USD                                               |
		| Адрес доставки             | Adres, Okrug, Gorod, Армения, 345345				 |
		| Тип доставки               | Royal mail                                        |
		| Перевыпуск карты ePayments | $ 5.95                                            |
		| Доставка: Royal mail       | $ 0.00                                            |
		| Итого                      | $ 5.95                                            |  

	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User selects payment eWallet "USD 5.95" on Multiform
	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на перевыпуск карты ePayments принята. Карта будет доставлена в течение 3-6 недель" on Multiform
    Then EPA card block contains Ожидает выпуска

	#STEP 12
	Then User selects records in 'Cards' for created user with blocked card and ManualRequest:
		| CardStateId   | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Blocked       | ProxyPANCode | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  
		| ManualRequest |              | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     | 

   #STEP 13
	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole  | State     | IsPep | PasswordExpireAt |
	    | 2     | 62       | Approved  | 0     | 9999-12-31       | 

	#STEP 14
	Then User selects record in 'SanctionCheck' for created user:
 	  | Scenario           | Status         | IsConfirmedPep |
 	  | BeforeVerification | Not sanctioned | false          |  
	

	#STEP 17
	Then Operator clicks on edit card info and save it with CardDeliveryType = RoyalMail
	Then User selects records in 'Cards' for created user with blocked card and ManualRequest:
		| CardStateId   | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Blocked       | ProxyPANCode | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  
		| NewRequest    |              | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     | 
	
	#STEP 18
	Then Operator creates card
	Then User refresh the page
	Then User selects records in 'Cards' for created user with blocked inactivated card and 2nd inactivated card:
		| CardStateId   | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Blocked       | ProxyPANCode | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  
		| Request       | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     | 
	
	#STEP 19	
	Then User selects record in 'SanctionCheck' for created user:
 	  | Scenario           | Status         | IsConfirmedPep |
 	  | BeforeVerification | Not sanctioned | false          |  

	#STEP 20
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_Update_Cardholder_Details:
		| dlvMethod | dlvaddr1       | dlvaddr2 | dlvaddr3 | dlvcity | dlvcounty | dlvpostcode | dlvcountry | Delv_Code | imageID | crddesign |
		| 0         | Adres | -        | -        | Gorod  | Okrug  | 345345      | 051        | 826       | -       | PP1       |  


	#STEP 21
	Then User refresh the page
	Then EPA card block contains АКТИВИРОВАТЬ

  Examples:
 | SecretName  | SecretDate | SecretPlace  | SecretCode |
 | Secret name | 01.01.1998 | Secret place | 123123     |  


 @135407 
 @Auto_card_creating_ON
Scenario Outline: Оплата первой карты с банковской карты

	 Given User goes to registration page
	 Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
		
	Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears
		Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |

	############## Make client KYC2 t##################

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 

 
## Make account verification request
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  


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
	
	############## Make client KYC2 t##################
	

	Then User order usd card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | USD                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Выпуск первой карты ePayments                 | $ 5.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
		| Итого:                                        | $ 5.95                                                        |  
	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User selects bank card payment on Multiform
	Given User clicks on "Оплатить" 
	Then User proceed payment by bank card

	Then Text Message "Ваш платеж обрабатывается и в скором времени будет зачислен на Ваш кошелек" appears
	Given User clicks on "Вернутся в личный кабинет ePayments" 
	
    Then Redirecting to account page
	Then User refresh the page
	Then Wait Ws_CreateCard from GPS
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
			| DelvMethod | Delv_AddrL1            | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County   | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
			| 0          | ул. Ленина, д.20.кв.17 | -           | -           | Казань    | Округ/Область | 424003        | 643          | 643       | PP1        | 1508       |   

	Then User selects records in 'Cards' for created user with replacing ProxyPANCode:
			| CardStateId | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
			|Request      | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     | 
		


	Then Preparing records in 'InvoicePositions':
		  | OperationTypeId | Amount | Fee  |
		  | 55              | 0.00   | 5.95 |
		  | 120             | 0.00   | 0.00 |   

	 Then User selects records in 'Invoices' for created user by email:
		  | State     | Details              | SenderSystemId | SenderIdentity | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId              |
		  | Successed | ePayments card order | Ecompay        | 555555...4444  | 1                | 000-121121       | Usd        | BankCard      | NotRecognized        | **created user id** |    
	   
	Then No records in 'TPurseTransactions'
	Then No records in 'LimitRecords'
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
		  | Amount | CurrencyId | ExternalServiceId | IsIncomingTransaction |
		  | 5.95   | Usd        | Ecompay           | true                  |  

	Then User refresh the page
	Then EPA card block contains АКТИВИРОВАТЬ
	
	Examples:
	     | SecretName  | SecretDate | SecretPlace  | SecretCode |
	     | Secret name | 01.01.1998 | Secret place | 123123     |  


		  @135408 
Scenario Outline: Оплата первой карты с PayPal
	
	Given User goes to registration page
	Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
	Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
		
	Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears
		Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |

	############## Make client KYC2 t##################

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 

## Make account verification request
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  


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
	
	############## Make client KYC2 t##################
	
	Then User order usd card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
	| Column1                                       | Column2                                                       |
	| Валюта карты                                  | USD                                                           |
	| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
	| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
	| Выпуск первой карты ePayments                 | $ 5.95                                                        |
	| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
	| Итого:                                        | $ 5.95                                                        |  
	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User selects PayPal payment on Multiform
	Given User clicks on "Оплатить" 
	
    Then User proceed payment in PayPal with user payaccount@myewallet.ru password Pass@word1

	#Then Text Message "Ваш платеж обрабатывается и в скором времени будет зачислен на Ваш кошелек" appears
	#Given User clicks on "Вернутся в личный кабинет ePayments" 
		   Given User goes to Account page
		   
    Then Redirecting to account page

	Then Click on Отмена on Modal Window
	
    Then Wait for card ready to be activated
	Then User refresh the page
	Then EPA card block contains АКТИВИРОВАТЬ


	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount | Fee  |
	  | 55              | 0.00   | 5.95 |
	  | 120             | 0.00   | 0.00 |   

	 Then User selects records in 'Invoices' for created user by email:
	  | State     | Details              | SenderSystemId | SenderIdentity          | ReceiverSystemId | ReceiverIdentity | CurrencyId | PaymentSource | ReceiverIdentityType | UserId              |
	  | Successed | ePayments card order | PayPal         | payaccount@myewallet.ru | 1                | 000-121121       | Usd        | PayPal        | NotRecognized        | **created user id** |  

	   
	Then No records in 'TPurseTransactions'
	Then No records in 'LimitRecords'
	
   
	Then User selects records in 'TExternalTransactions' by OperationGuid
	  | Amount | CurrencyId | ExternalServiceId | IsIncomingTransaction |
	  | 0.56   | Usd        | PayPal            | false                 |
	  | 5.95   | Usd        | PayPal            | true                  |  

	Examples:
	      | SecretName  | SecretDate | SecretPlace  | SecretCode |
	      | Secret name | 01.01.1998 | Secret place | 123123     |  


@135414
@Auto_card_creating_ON
@VAT_Russia_update
Scenario Outline: Заказ - активация - перевыпуск GPS->GPS - активация без попадания под ручную обработку КУС2
	Given User goes to registration page
	Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
	 Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
	Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears
		 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |

	############ VERIFICATING USER ####################3

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 
 
## Make account verification request
	
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  

	Then 'Код из SMS:' set confirmation code
	Given User clicks on "Продолжить"

	Then Verification widget contains 'Подтвердите вашу личность'
	Then 'Гражданство:' citizenship set to 'Россия'

	Given User clicks on "Общегражданский паспорт"
	Then 'Серия и номер документа:' set to '8811073131'
	Then User scrolls down

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

	############ VERIFICATING USER ####################3

   Then User updates balance="13.68" "Usd" in table 'TPurseSections' for created user
	

# STEP 1 (Order and Activate)
	Then User order usd card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform

	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | USD                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Выпуск первой карты ePayments                 | $ 5.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
		| Налог на добавленную стоимость                | $ 0.89                                                        |  
		| Итого:                                        | $ 6.84                                                        |   
	Given User clicks on "Заказать" on Multiform 
	Then User choose ewallet to pay for card order
    Then 'Источник оплаты' selector set to 'USD' in eWallet section

	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform

	#=============== Activate EPA USD card ================#

	Then Operator clicks on edit card info and save it with CardDeliveryType = RussianPost
	Then Operator gets client info by card
	
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CardHolder_Details_Enquiry_V2:
		| CrdDesign | ImageID |
		| PP1       | -       |  

	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1                  | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County        | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | ул. Ленина, д.20.кв.17       | -           | -           | Казань    | Округ/Область        | 424003        | 643          | 643       | PP1        | 1508       |    
		
	Then User selects records in 'Cards' for created user with replacing ProxyPANCode:
		| CardStateId | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		|Request      | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     | 

	Then Get FullPAN
		
	Then User refresh the page
	Given User clicks on "Активировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Given Set StartTime for DB search
	Then User fills FullPAN
	Given User clicks on "Активировать" on Multiform 
	Given 'Действия с PIN' selector is "Получить PIN" and contains:
    	| Options        |
    	| Получить PIN   |
    	| Установить PIN |  
	Then Make screenshot
	Given User clicks on "Далее" on Multiform 

    Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 105           | **phone** |  
	Given User fills ConfirmationCode on activation details
	Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно активирована" on Multiform
	Then User see PIN code
	
	Then User refresh the page		

	Then User selects records in 'Cards' for created user:
		| CardStateId | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Active      | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   |  

	#=============== Activate EPA USD card ================#
	
	Then No records in 'SanctionCheck' for created user

	Then EPA card block contains $ 0.00

# STEP 2 (Reissue and activate)
	Then Operator blocks EPA Card for created user
	Then User refresh the page

   	Then User clicks on CardAndAccounts

	Then EPA card block contains Заблокирована

	Given Set StartTime for DB search
	Given User clicks on "Перевыпустить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | USD                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Перевыпуск карты ePayments                    | $ 5.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
		| Налог на добавленную стоимость                | $ 0.89                                                        |
		| Итого                                        | $ 6.84                                                        |  

	Then Make screenshot
	Given User clicks on "Заказать" on Multiform 
	Then User selects payment eWallet "USD 6.84" on Multiform
	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на перевыпуск карты ePayments принята. Карта будет доставлена в течение 1-3 недели" on Multiform
    Then User refresh the page
	Then EPA card block contains АКТИВИРОВАТЬ

	Then User selects records in 'Cards' for created user with blocked card:
		| CardStateId | ProxyPANCode     | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Blocked     | **ProxyPANCode** | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   |
		| Request     | **ProxyPANCode** | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  

	Then User selects records in table 'Notification' for created user
		 | MessageType | Priority | Receiver  | Title                        |
		 | Email       | 8        | **Email** | Карта ePayments перевыпущена |  

# \\\\\\\\\\\\\\ReActivate reissued card\\\\\\\\\\\\
		
	Then Operator clicks on edit card info and save it with CardDeliveryType = RussianPost

	Then Get FullPAN
		
	Then User refresh the page
	Given User clicks on "Активировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Given Set StartTime for DB search
	Then User fills FullPAN
	Given User clicks on "Активировать" on Multiform 
	Given 'Действия с PIN' selector is "Получить PIN" and contains:
    	| Options        |
    	| Получить PIN   |
    	| Установить PIN |  
	Then Make screenshot
	Given User clicks on "Далее" on Multiform 

    Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 105           | **phone** |  
	Given User fills ConfirmationCode on activation details
	Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно активирована" on Multiform
	Then User see PIN code
	
	Then User refresh the page	
	
	Then EPA card block contains $ 0.00

	Then User selects records in 'Cards' for created user with blocked and reactivated card:
		| CardStateId | ProxyPANCode     | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		| Blocked     | **ProxyPANCode** | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   |
		| Active      | **ProxyPANCode** | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   |                |                     |  

	Then No records in 'SanctionCheck' for created user
# \\\\\\\\\\\\\\ReActivate reissued card\\\\\\\\\\\\


 Examples:
	 | SecretName  | SecretDate | SecretPlace  | SecretCode |
	 | Secret name | 01.01.1998 | Secret place | 123123     |  


		   @346871 
Scenario Outline:  Привязка NP карты 
# Клиент не зарегистрирован в системе
# У клиента нет USD GPS карты
# имеется непривязанная NP карта

	 Given User goes to registration page
	 Given User clicks on button "Продолжить"

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
		Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
		
		Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears
	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |
	
	  ########## VERIFICATE USER ###############

	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   | 

	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  


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

	
	  ########## VERIFICATE USER ###############

#Step 1
	Then User clicks on CardAndAccounts
	Then User refresh the page
	Then User order 'Привязать промо карту'
#Step 2
    Then Card template appears
	 Given Button "Активировать" is Disabled

	Then User fills invalid FullPAN '3333333333333333'
	
	Then Alert Message "Номер банковской карты введен неверно" appears
	
	 Given Button "Активировать" is Disabled
#Step 3
	Then User creates NP Card
	Given Set StartTime for DB search
	
	Then User fills FullPAN
	
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Активировать" on Multiform 
	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 


	Given 'Действия с PIN' selector is "Получить PIN" and contains:
    	| Options        |
    	| Получить PIN   |
    	| Установить PIN |

	Given User clicks on "Далее" on Multiform 


  Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 105           | **phone** |  
	 Given User fills ConfirmationCode on activation details
	 Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно активирована" on Multiform
	Then User see PIN code
	
	Then User refresh the page
	
	Then EPA card block contains $ 0.00

	Then User selects records in 'Cards' for created user:
		| CardStateId | ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt |
		|Active      | **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   | 


	  Examples:
	 | SecretName  | SecretDate | SecretPlace  | SecretCode |
	 | Secret name | 01.01.1998 | Secret place | 123123     |  



	 	@2878611 
	@Ref_card_create_ON
	@Card_create_OFF
Scenario: Альтернативный заказ карт
# System Availability cardcreate вЫключен
# System Availability RefCardCreate включен
# 
# Найти реф. ссылку в таблице [dbo].[TUserReferences] с параметром AllowRefCardCreate = 1
# SELECT TOP 100 *
# FROM [sb_epayments].[dbo].[TUserReferences]
# WHERE AllowRefCardCreate = 1

	 Given User open link "https://my.sandbox.epayments.com/#/registration?promo=trirazdva"
	Given User clicks on "Войти" on Landing Page
	Given User clicks on "Регистрация"
	Given User clicks on button "Продолжить"
	Given User lands on registration form
		Then Checkbox "Есть промокод?" is checked
		Then 'Промокод' value is 'trirazdva'
		Then Text "Регистрация по промо-коду:" appears 
		Then Text "trirazdva" appears
	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия

	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'
		 Given Set StartTime for DB search

	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
		
		Given User clicks on button "Регистрация"

	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	Then Verification widget appears
	
	################################3
	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185       | Approved | 0     | *today+6month*   | 

 
## Make account verification request
	
	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  


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

	
	  #########################
   


#Order USD card	
	Then User order usd card
		Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform



	
	@349987 
	@Auto_card_creating_OFF
Scenario Outline: Автозаказ карты: Пользователь, зарегистрированный по партнерской ссылке.

	Given User goes to SignIn page
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given Memorize partner link table with 2 links
	Given User LogOut

	Given User open partner's link "https://sandbox.epacash.com/hidvltu1f8"
	Then User receive Cookie "iv" 
	Then User receive Cookie "promocode"
	Then User receive Cookie "tags" 
	Given User goes to registration page

	Given User clicks on button "Продолжить"
	Then Checkbox "Есть промокод?" is checked
	Then 'Промокод' value is 'hidvltu1f8'
	Then Text "Регистрация по промо-коду:" appears 
	Then Text "hidvltu1f8" appears 

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 Then User change Country to Россия
	 Then 'Электронная почта' set to random email
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

 
	Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                |        |  
	
	Then User selects records in table 'EpaZendeskUser' for created user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   

	Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5            | **Phone** |  

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
	
	  #########################

   Then User updates balance="5.95" "Usd" in table 'TPurseSections' for created user

#Order USD card	
	Then User order usd card
	Then User selects delivery address="Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17" on Multiform
	Given User clicks on "Далее" on Multiform

	Given User fills Secret Details on Multifrom:
	   | SecretName   | SecretDate   | SecretPlace   | SecretCode   |
	   | <SecretName> | <SecretDate> | <SecretPlace> | <SecretCode> |  
	Given User clicks on "Далее" on Multiform 
	Given User see table
		| Column1                                       | Column2                                                       |
		| Валюта карты                                  | USD                                                           |
		| Адрес доставки                                | Россия, Округ/Область, 424003, Казань, ул. Ленина, д.20.кв.17 |
		| Тип доставки                                  | Почта России (с кодом отслеживания)                           |
		| Выпуск первой карты ePayments                 | $ 5.95                                                        |
		| Доставка: Почта России (с кодом отслеживания) | $ 0.00                                                        |
		| Итого:                                        | $ 5.95                                                        |   
	Given User clicks on "Заказать" on Multiform 
	Then User choose ewallet to pay for card order
    Then 'Источник оплаты' selector set to 'USD' in eWallet section

	Given User clicks on "Оплатить" on Multiform 
	Then User gets message "Поздравляем! Ваша заявка на выпуск карты ePayments принята. Обработка заявки занимает 5 рабочих дней" on Multiform

	Then Operator clicks on edit card info and save it with CardDeliveryType = RussianPost
    Then Operator creates card
	Then Operator gets client info by card
	
	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CardHolder_Details_Enquiry_V2:
		| CrdDesign | ImageID |
		| PP1       | -       |  

	Then User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:
		| DelvMethod | Delv_AddrL1                  | Delv_AddrL2 | Delv_AddrL3 | Delv_City | Delv_County        | Delv_PostCode | Delv_Country | Delv_Code | ProductRef | CardDesign |
		| 0          | ул. Ленина, д.20.кв.17       | -           | -           | Казань    | Округ/Область      | 424003        | 643          | 643       | PP1        | 1508       |    

## Activate Card
	Then Get FullPAN
		
	Then User refresh the page
	Given User clicks on "Активировать" "USD" 'Epayments Cards' at CardAndAccounts grid
	Given Set StartTime for DB search
	Then User fills FullPAN
	Given User clicks on "Активировать" on Multiform 
	Given 'Действия с PIN' selector is "Получить PIN" and contains:
    	| Options        |
    	| Получить PIN   |
    	| Установить PIN |  
	Then Make screenshot
	Given User clicks on "Далее" on Multiform 

    Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient |
		  | 105           | **phone** |  
	 Given User fills ConfirmationCode on activation details
	 Given User clicks on "Подтвердить" on Multiform 
	Then User gets message "Ваша карта ePayments успешно активирована" on Multiform
	Then User see PIN code

#Update SpecialBalance
	Then User updates balance="150" "Usd" in table 'TPurseSections' for created user
	Then User updates SpecialBalance="150" "Usd" in table 'TUsers' for created user

	Then User refresh the page		

	Then User selects records in 'Cards' for created user:
		| ProxyPANCode | MemorableName | MemorableDate | MemorablePlace | ActivationCode | ActivationDate | CardServiceExpireAt | CardStateId |
		| **Token**    | <SecretName>  | <SecretDate>  | <SecretPlace>  | <SecretCode>   | **today**      | **2 month later**   | Active      |  

	Then User clicks on CardAndAccounts
	Given User clicks on "Пополнить" "USD" 'Epayments Cards' at CardAndAccounts grid
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
		    
    Given User see limits table
    	| Column1                      | Column2     |
    	| Минимальная сумма перевода:  | $ 10.00     |
    	| Максимальная сумма перевода: | $ 15 000.00 |
    	| Комиссия:                    | 0%          |  
    Given Set StartTime for DB search
	Then 'Сумма' set to '10'
	Then Section 'Amount including fees' is: $ 10.00 (Комиссия: $ 0.00)

	Given User clicks on "Далее"
	
	Then Memorize EPACards section
	Then Memorize eWallet section

	Given User clicks on "Перевести" on Multiform

	Then Success message "Ваша карта успешно пополнена×" appears

	Given User clicks on "Закрыть"

	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name                         | Amount    |
		| **DD.MM.YY** | Пополнение карты ePayments   | - $ 10.00 |
		| **DD.MM.YY** | Пополнение карты ePayments   | $ 10.00   |
		| **DD.MM.YY** | Заказ первой карты ePayments | - $ 5.95   |  

	Then eWallet updated sections are:
		| USD    | EUR  | RUB  |
		| -10.00 | 0.00 | 0.00 |  
		
	 Then EPA cards updated sections are:
 		| USD   | EUR  |
 		| +10.0 | 0.00 |

	Examples:
	 | SecretName  | SecretDate | SecretPlace  | SecretCode |
	 | Secret name | 01.01.1998 | Secret place | 123123     |