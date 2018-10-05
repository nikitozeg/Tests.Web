@AffiliateProgram
Feature: AffiliateProgram

	@1324062 
Scenario: Выплата бонусных начислений

# Для юзеров должны быть проставлен тарфи autotest в ПП
#Memorize 1-level bonus table
	Given User goes to SignIn page
	Then Make screenshot
	Given User signin "Epayments" with "referal123@qa.swiftcom.uk" password "3EDC4rfv"
	Given User clicks on Партнерская программа menu
	Then User expands Payment Table
	Given Memorize 1-level refferer 'Available for payment' table
	Given User LogOut

#Memorize 0-level bonus table
	Given User goes to SignIn page
 	Given User signin "Epayments" with "qrrtttPart@test.ru" password "3EDC4rfv"
	Given User clicks on Партнерская программа menu
	Then User expands Payment Table
	Given Memorize 0-level refferer 'Available for payment' table
	Given User LogOut

#Send transfer by 2-level  	
	Given Set StartTime for DB search
	Given User signin "Epayments" with "nikitatest206@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Перевести menu
	Given User clicks on "Другому человеку"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	Then 'Получатель' set to '000304699'
	Then 'Со счета' selector set to 'RUB'
	Then 'Отдаваемая сумма' set to '1000'
	Then Section 'Amount including fees' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)
	Given User clicks on "Далее" on Multiform
	Given User clicks on "Подтвердить" on Multiform
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId                               | IsUsed |
		| MassPayment   | +70276111299 | 8e80007b-62a8-471b-b5ca-4e2c622c56d9 | false  | 
	Given User clicks on "Оплатить" on Multiform
	Then User gets message "Платеж успешно отправлен" on Multiform
	Given User LogOut

#Check that 1-level gets bonus
	Given User signin "Epayments" with "referal123@qa.swiftcom.uk" password "3EDC4rfv"
	Given User clicks on Партнерская программа menu
    Then User expands Payment Table
	Given User see 1-level refferer 'AvailableForPayment' table with updated columns:
		 | ForPayment | Processing | Cancelled | Completed |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | +3.15      | 0.00      | 0.00      |  
	Then Make screenshot	 
#Send transfer by 1-level
	Given User clicks on Перевести menu
	Given User clicks on "Другому человеку"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	Then 'Получатель' set to '000193351'
	Then 'Со счета' selector set to 'RUB'
	Then 'Отдаваемая сумма' set to '1000'
	Then Section 'Amount including fees' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)
	Given User clicks on "Далее" on Multiform
	Given User clicks on "Подтвердить" on Multiform
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId                               | IsUsed |
		| MassPayment   | +70009991179 | 89fafa8d-49da-453c-ab85-eedf501dc706 | false  |  
	Given User clicks on "Оплатить" on Multiform
	Then User gets message "Платеж успешно отправлен" on Multiform
	Given User LogOut

#Check that 0-level gets bonus in PROCESSING for 2- and 1- levels
	Given User signin "Epayments" with "qrrtttPart@test.ru" password "3EDC4rfv"
	Given User clicks on Партнерская программа menu
    Then User expands Payment Table
	Given User see 0-level refferer 'AvailableForPayment' table with updated columns:
		 | ForPayment | Processing | Cancelled | Completed |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | +6.30      | 0.00      | 0.00      |  
	Then Make screenshot
#Make 0-level bonus IN PROCESS -> FOR PAYMENT
	Then Send event to epacash for UserId = 8e80007b-62a8-471b-b5ca-4e2c622c56d9 with last InvoiceId
	Then Send event to epacash for UserId = 89fafa8d-49da-453c-ab85-eedf501dc706 with last InvoiceId
	Then User refresh the page
	Given User clicks on Партнерская программа menu
	Then User expands Payment Table
	Given User see 0-level refferer 'AvailableForPayment' table with updated columns:
		 | ForPayment | Processing | Cancelled | Completed |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | +6.30      | 0.00       | 0.00      | 0.00      |  
	Then Make screenshot
	Then Memorize eWallet section

 #Make 0-level bonus FOR PAYMENT -> FILL EWALLET
	Given User clicks on "Перевести на кошелек"
	Then Success message "Бонусное вознаграждение успешно зачислено на ваш кошелек×" appears
	Given User clicks on Партнерская программа menu
	Given User see 0-level refferer 'AvailableForPayment' table with updated columns:
		 | ForPayment | Processing | Cancelled | Completed |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       |  0.00      | 0.00      | +6.30      | 
	Then Make screenshot
	Then eWallet updated sections are:
		| USD  | EUR  | RUB   |
		| 0.00 | 0.00 | +6.30 |  

#Refund 1-level invoice
    Then Operator confirms Invoice refund
    Then User gets VerificationCode in table 'ConfirmationCodes' where:
	  | OperationType | Recipient    |
	  | 20            | +70002342342 |  
    Then Operator refunds last invoice for UserId=89fafa8d-49da-453c-ab85-eedf501dc706
	Then User refresh the page

#Check that refund is OK
	Given User clicks on Партнерская программа menu
	Then User expands Payment Table
	Given User see 0-level refferer 'AvailableForPayment' table with updated columns:
		 | ForPayment | Processing | Cancelled | Completed |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | 0.00       | 0.00       | 0.00      | 0.00      |
		 | -3.15      | 0.00       | +3.15     | +6.30     |  
	Then Make screenshot
	Given User clicks on Отчеты menu
	Given User see transactions list contains:
		| Date         | Name               | Amount |
		| **DD.MM.YY** | Внутренний перевод | ₽ 6.30 |  


#[EPA-5472]
	
#  Given User see expanded transaction info for the UserId=6fe8df5e-14e3-422a-b317-bb3d0b047581 row № 0:
#	| Column1      | Column2                                                          |
#	| Транзакция № | **TPurseTransactionId**                                          |
#	| Заказ №      | **InvoiceId**                                                    |
#	| Дата         | **dd.MM.yyyy HH:mm**                                             |
#	| Продукт      | e-Wallet 000-338562                                              |
#	| Получатель   | 000-338562                                                       |
#	| Сумма        | ₽ 6.30                                                           |
#	| Детали       | Internal payment from e-Wallet 000-280173. Details: Bonus reward |  


#Reset balance FOR PAYMENT for 0-level.
	Given User LogOut
	Given User signin "Epayments" with "nikitatest206@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Перевести menu
	Given User clicks on "Другому человеку"
	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)
	Then 'Получатель' set to '000304699'
	Then 'Со счета' selector set to 'RUB'
	Then 'Отдаваемая сумма' set to '1000'
	Given Set StartTime for DB search
	Then Section 'Amount including fees' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)
	Given User clicks on "Далее" on Multiform
	Given User clicks on "Подтвердить" on Multiform
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId                               | IsUsed |
		| MassPayment   | +70276111299 | 8e80007b-62a8-471b-b5ca-4e2c622c56d9 | false  |  
	Given User clicks on "Оплатить" on Multiform
	Then User gets message "Платеж успешно отправлен" on Multiform
	Then Send event to epacash for UserId = 8e80007b-62a8-471b-b5ca-4e2c622c56d9 with last InvoiceId
	
	Given User LogOut



 @837633 
Scenario: Создание/редактирование/удаление/восстановление партнерской ссылки
	Given User goes to SignIn page
 	Given User signin "Epayments" with "4edbb445feb0a4feac95e9fa22.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Then User clicks on ADD
	Then User type Link reference
	Then 'Целевая страница' value is 'https://www.sandbox.epayments.com'
	Given Affiliate link value is "https://sandbox.epacash.com/"+AffiliateLink
	Given User clicks on button "Сохранить"
	Then Success message "Партнерская ссылка создана×" appears
	Given User see active partner links contains:
		| LinkNames | Transitions | Registrations | ForPayment | Processing | Cancelled |
		| **link**  | 0           | 0             | 0.00       | 0.00       | 0.00      |  
	Then Make screenshot
	Given User clicks on created partner link
	Then User clicks on "Редактировать" on Partner Link
	Then User type Link reference
	Then 'Целевая страница' value is 'https://www.sandbox.epayments.com'
	Given Affiliate link value is "https://sandbox.epacash.com/"+AffiliateLink
	Given User clicks on "Сохранить"
	Then Success message "Партнерская ссылка сохранена×" appears
	Given User see active partner links contains:
		| LinkNames | Transitions | Registrations | ForPayment | Processing | Cancelled |
		| **link**  | 0           | 0             | 0.00       | 0.00       | 0.00      |  

	Given User clicks on edited partner link
	Then User clicks on "Удалить" on Partner Link
	Then Make screenshot
	Then Click on Удалить on Modal Window
	Then Deleted Partner link is inactive
 	Given User clicks on edited partner link
	Then User clicks on "Восстановить" on Partner Link
	Then Click on Восстановить on Modal Window
	Given User see active partner links contains:
		| LinkNames | Transitions | Registrations | ForPayment | Processing | Cancelled |
		| **link**  | 0           | 0             | 0.00       | 0.00       | 0.00      |  
	Given User clicks on edited partner link
	Then User clicks on "Удалить" on Partner Link
	Then Click on Отмена on Modal Window