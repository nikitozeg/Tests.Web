@WaitingInvoiceHandler 
Feature: WaitingInvoiceHandler 


@1676695
 Scenario Outline: WaitingInvoiceHandler не закрывает инвойсы исходящих ваеров 

# Пользователь зарегистрирован, KYC2, баланс кошелька USD/EUR > мин. суммы перевода,
# Машинку запускать тут:K:\epayments\sandbox\ePayments.Tools.WaitingInvoiceHandler \<самая свежая по дате изменения папка>
# Логи машинки смотреть тут: K:\logs\tools

#STEP 1
    Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Then Memorize eWallet section

	Given User clicks on Перевести menu
	Given User clicks on "На банковский счет"

	Then Section 'Amount including fees' is: $ 0.00 (Комиссия: $ 0.00)

	Then 'Кошелек' selector set to 'RUB' in eWallet section
	Then 'Получатель платежа' selector set to 'receiver bank, ReceiverName ReceiverSurname, LV10RTMB0000000000009'
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
		| Column1            | Column2                                                                         |
		| Отправитель        | RUB, e-Wallet 001-<UserPurseId>                                                 |
		| Получатель         | receiver bank, rcvrSwift12, ReceiverName ReceiverSurname, LV10RTMB0000000000009 |
		| Отдаваемая сумма   | ₽ <Amount>                                                                      |
		| Комиссия           | ₽ <Comission>                                                                   |
		| Сумма с комиссией  | ₽ 14 500.00                                                                     |
		| Получаемая сумма   | ₽ <Amount>                                                                      |
		| Назначение платежа | Details                                                                         |  
	Then Make screenshot
	Given Set StartTime for DB search

	Given User clicks on "Подтвердить"
	Given Set StartTime for DB search
	Then User type SMS sent to:
		| OperationType | Recipient    | UserId   | IsUsed |
		| MassPayment   | +70064581799 | <UserId> | false  |  
	Given User clicks on "Оплатить"
	Then User gets message "Обработка платежа займет несколько минут. Дождитесь результата перевода или продолжите работу в личном кабинете" on Multiform
	Then User gets message "Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке" on Multiform

	Then Make screenshot
#STEP 2
	 Then Operator edits bank wire for UserId='<UserId>' where WireService='Rietumu' and sends to bank

   	##############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee     |
	  | 143             | 10000.00 | 4500.00 |     
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State                        | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                  | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | WaitingForAutomaticAdmission | {VO99999}, Details | WaveCrest      | 001-<UserPurseId> | Rietumu          | rcvrSwift12/LV10RTMB0000000000009 | Rub        | EWallet       | Purse                | <UserId> |    
   	##############################_Transactions_################################################

#STEP 3
 	When User download and executes "Tools.WaitingInvoiceHandler"
	
	#############################_Transactions_################################################
	Then Preparing records in 'InvoicePositions':
	  | OperationTypeId | Amount   | Fee     |
	  | 143             | 10000.00 | 4500.00 |  
	Then User selects last record in 'Invoices and InvoicePositions' where UserId="<UserId>":
	  | State                        | Details            | SenderSystemId | SenderIdentity    | ReceiverSystemId | ReceiverIdentity                  | CurrencyId | PaymentSource | ReceiverIdentityType | UserId   |
	  | WaitingForAutomaticAdmission | {VO99999}, Details | WaveCrest      | 001-<UserPurseId> | Rietumu          | rcvrSwift12/LV10RTMB0000000000009 | Rub        | EWallet       | Purse                | <UserId> |  
   	##############################_Transactions_################################################

  Examples:
      | User                                     | UserId                               | Password     | Amount    | Comission | UserPurseId |
      | toolWaitInvoiceHandlerBiz@qa.swiftcom.uk | 13684ab7-edb0-451c-a4d4-33fd839e30ac | 72621010Abac | 10 000.00 | 4 500.00  | 791479      |  
