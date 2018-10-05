@BankWiresIn
Feature: BankWiresIn


Scenario Outline: Входящий опознанный ваер создается в ручном режиме (POSITIVE)
 
# Страница создания ваера в админке -Create bank wire.
# Получатель = пользователь КУС2.
# Создается опознанный ваер.

 	Given Set StartTime for DB search
 #STEP 1
 	Then Operator creates incoming wire:
 		| isUndefined | reference   | currency | bankCharge | ourCharge | wireServiceId | paymentAmount | paymentDetails | beneficiaryAccountNumber |
 		| false       | <Reference> | 2        | 10         | 5         | 4             | 110           | <Details>      | 001-049399               |  
 
 	Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireIn  | Not Sanctioned | false          | 
 	  | BankWireIn  | Not Sanctioned | false          | 
 
  #STEP 2
 ##############################_Transactions_################################################
	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
 	  | Amount          | DestinationId               | Direction | UserId           | CurrencyId | PurseId             | RefundCount |
 	  | <PaymentAmount> | Refill                      | in        | <ReceiverUserId> | Eur        | 1049399             | 0           |
 	  | <ourCharge>     | BankWireIncommingCommission | out       | <ReceiverUserId> | Eur        | <UserPurseId>       | 0           |
 	  | <ourCharge>     | BankWireIncommingCommission | in        | <EPSUserId>      | Eur        | <EPS-01Commissions> | 0           |
 	  | <BankCharge>    | BankComission               | out       | <EPSUserId>      | Eur        | <EPS-01Commissions> | 0           |  
 	 
 	 Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<ReceiverUserId>":
 	  | CurrencyId | Direction | Destination      | UserId           | Amount | AmountInUsd   | Product    | ProductType |
 	  | Eur        | In        | IncomingBankWire | <ReceiverUserId> | 105    | **Generated** | 001-049399 | Epid        |  
 
 	 Then User selects records in 'TExternalTransactions' for UndefinedWire
 	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
 	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
 	  | <BankCharge>    | Eur        | Rietumu           | false                 |  
 ##############################_Transactions_################################################
 
 @2150622
  Examples:
     | Reference        | PaymentAmount | BankCharge | ourCharge |  ReceiverUserId                       |   SystemPurseUserId                    | UserPurseId | EPSUserId                            | EPS-01Commissions |  EPS-04Terrorist |
     | Qlsebyxguqodvirr | 110           | 10         | 5         |  2581235e-989d-4909-8a5a-71d2778ec215 |   F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1049399     | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 666698          |    




Scenario Outline: Входящий опознанный ваер создается в ручном режиме - Террорист(true positive) 
  	Given Set StartTime for DB search

#STEP 1  
  	Then Operator creates incoming wire from 'Alexey Milchakov':
  		| isUndefined | reference   | currency | bankCharge | ourCharge | wireServiceId | paymentAmount | paymentDetails | beneficiaryAccountNumber |
  		| false       | <Reference> | 2        | 10         | 5         | 4             | 110           | <Details>      | 001-049399               |  
 
#STEP 2 
  	Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | InProcess	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |  

  	Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
  ##############################_Transactions_################################################

#STEP 3
	Then Send CA true positive callback for reference '<Reference>'
   	Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | Confirmed	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
	Given Reset checkers
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |     
 
  	Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
  ##############################_Transactions_################################################

@3044422
  Examples:
     | Reference        | PaymentAmount | BankCharge | ourCharge |  ReceiverUserId                       |   SystemPurseUserId                    | UserPurseId | EPSUserId                            | EPS-01Commissions |  EPS-04Terrorist |
     | Qlsebyxguqodvirr | 110           | 10         | 5         |  2581235e-989d-4909-8a5a-71d2778ec215 |   F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1049399     | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 666698          |    



Scenario Outline: Входящий опознанный ваер создается в ручном режиме - РЕР 
	Given Set StartTime for DB search

#STEP 1  
  	Then Operator creates incoming wire from 'Alexey Milchakov':
  		| isUndefined | reference   | currency | bankCharge   | ourCharge   | wireServiceId | paymentAmount   | paymentDetails   | beneficiaryAccountNumber |
  		| false       | <Reference> | 2        | <BankCharge> | <ourCharge> | 4             | <PaymentAmount> | autotest details | 001-049399               |  

#STEP 2 
  	Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | InProcess	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
 #1.2.5. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-1.2.%D0%91%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%BC%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D0%BE%D0%BC
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           | 
	Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
 ##############################_Transactions_################################################

#STEP 3
  Then Send CA PEP positive callback for reference '<Reference>'
 
  Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario   | Status         | IsConfirmedPep |
  	  | BankWireIn | Confirmed      | true           |
  	  | BankWireIn | Not Sanctioned | false          |  
 
  #1.2.6. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-1.2.%D0%91%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%BC%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D0%BE%D0%BC
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId               | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill                      | out       | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <PaymentAmount> | Refill                      | in        | <ReceiverUserId>    | Eur        | <UserPurseId>       | 0           |
  	  | <ourCharge>     | BankWireIncommingCommission | out       | <ReceiverUserId>    | Eur        | <UserPurseId>       | 0           |
  	  | <ourCharge>     | BankWireIncommingCommission | in        | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |  
 	 

	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<ReceiverUserId>":
 	  | CurrencyId | Direction | Destination      | UserId           | Amount | AmountInUsd   | Product    | ProductType |
 	  | Eur        | In        | IncomingBankWire | <ReceiverUserId> | 110    | **Generated** | 001-049399 | Epid        |  

# [EPA-6458] 
# 	 Then User selects records in 'TExternalTransactions' 
# 	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
# 	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
# 	  | <BankCharge>    | Eur        | Rietumu           | false                 |
  ##############################_Transactions_################################################

@3044421
  Examples:
     | Reference        | PaymentAmount | BankCharge | ourCharge |  ReceiverUserId                       |   SystemPurseUserId                    | UserPurseId | EPSUserId                            | EPS-01Commissions |  EPS-04Terrorist |
     | Qlsebyxguqodvirr | 110           | 10         | 5         |  2581235e-989d-4909-8a5a-71d2778ec215 |   F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1049399     | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 666698          |    

  


Scenario Outline: Входящий опознанный ваер создается в ручном режиме - Террорист(false positive) 
	Given Set StartTime for DB search
 
#STEP 1  
  	Then Operator creates incoming wire from 'Alexey Milchakov':
  		| isUndefined | reference   | currency | bankCharge   | ourCharge   | wireServiceId | paymentAmount   | paymentDetails   | beneficiaryAccountNumber |
  		| false       | <Reference> | 2        | <BankCharge> | <ourCharge> | 4             | <PaymentAmount> | autotest details | 001-049399               |   

#STEP 2
  	Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | InProcess	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
 #1.2.5. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-1.2.%D0%91%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%BC%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D0%BE%D0%BC
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           | 
	 Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
 ##############################_Transactions_################################################
 
#STEP 3
  Then Send CA false positive callback for reference '<Reference>'

  Then User selects record in 'SanctionCheck' where UserId ="<ReceiverUserId>":
  	  | Scenario   | Status         | IsConfirmedPep |
  	  | BankWireIn | Not Sanctioned | false          |
  	  | BankWireIn | Not Sanctioned | false          |  
 
  #1.2.6. https://confluence.swiftcom.uk/pages/viewpage.action?pageId=8618059#id-%D0%A1%D0%BF%D1%80%D0%B0%D0%B2%D0%BE%D1%87%D0%BD%D0%B8%D0%BA%D1%82%D1%80%D0%B0%D0%BD%D0%B7%D0%B0%D0%BA%D1%86%D0%B8%D0%B9-1.2.%D0%91%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%BC%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D0%BE%D0%BC
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="001-049399":
  	  | Amount          | DestinationId               | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill                      | out       | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <PaymentAmount> | Refill                      | in        | <ReceiverUserId>    | Eur        | <UserPurseId>       | 0           |
  	  | <ourCharge>     | BankWireIncommingCommission | out       | <ReceiverUserId>    | Eur        | <UserPurseId>       | 0           |
  	  | <ourCharge>     | BankWireIncommingCommission | in        | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |  

	Then User selects records in 'LimitRecords' by last OperationGuid where UserId="<ReceiverUserId>":
 	  | CurrencyId | Direction | Destination      | UserId           | Amount | AmountInUsd   | Product    | ProductType |
 	  | Eur        | In        | IncomingBankWire | <ReceiverUserId> | 110    | **Generated** | 001-049399 | Epid        |  

 #[EPA-6458] 
 #	 Then User selects records in 'TExternalTransactions' 
 #	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
 #	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
 #	  | <BankCharge>    | Eur        | Rietumu           | false                 |
  ##############################_Transactions_################################################

@3044420
  Examples:
     | Reference        | PaymentAmount | BankCharge | ourCharge |  ReceiverUserId                       |   SystemPurseUserId                    | UserPurseId | EPSUserId                            | EPS-01Commissions |  EPS-04Terrorist |
     | Qlsebyxguqodvirr | 110           | 10         | 5         |  2581235e-989d-4909-8a5a-71d2778ec215 |   F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 1049399     | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 666698          |    




	 Scenario Outline: Входящий неопознанный ваер создается в автоматическом режиме (POSITIVE)
# Страница создания ваера в админке -Create bank wire.
# Получатель = пользователь КУС2.
# Создается неопознанный ваер.

 	Given Set StartTime for DB search
 #STEP 1
 	Then Create BankWireInTemp and Accept with Type=Undefined:
	| Reference   | SupportUserId                        | SenderName   | BeneficiaryAccountNumber        | PaymentAmount | OurCharge | BankCharge | CurrencyId | PaymentDetails | WireServiceId |
	| <Reference> | 403d5963-b904-4a78-a51b-eab922bc5640 | Ilya Malchev | <EPS-03UndefinedWiresPurseFull> | 1231          |           | 1          | 2          | details        | 4             |  

  #STEP 2
 	Then User selects record in 'SanctionCheck' where UserId ="<SystemPurseUserId>":
 	  | Scenario    | Status         | IsConfirmedPep |
 	  | BankWireIn  | Not Sanctioned | false          | 
 	  | BankWireIn  | Not Sanctioned | false          | 
 
 ##############################_Transactions_################################################
	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="<EPS-03UndefinedWiresPurseFull>":
 	  | Amount          | DestinationId               | Direction | UserId              | CurrencyId | PurseId                     | RefundCount |
 	  | <PaymentAmount> | Refill                      | in        | <SystemPurseUserId> | Eur        | <EPS-03UndefinedWiresPurse> | 0           |
 	  | <BankCharge>    | BankComission               | out       | <EPSUserId>         | Eur        | <EPS-01Commissions>         | 0           |  
 	 
     Then No records in 'LimitRecords'

 	 Then User selects records in 'TExternalTransactions' for UndefinedWire
 	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
 	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
 	  | <BankCharge>    | Eur        | Rietumu           | false                 |  
 ##############################_Transactions_################################################
 
 @2150623
  Examples:
     | Reference            | PaymentAmount | BankCharge |  SystemPurseUserId                    | EPSUserId                            | EPS-01Commissions | EPS-03UndefinedWiresPurse | EPS-03UndefinedWiresPurseFull |
     | asdasdwasdzxcvbn9999 | 1231          | 1          | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 1101                      | 000-001101                    |  




	 Scenario Outline: Входящий неопознанный ваер создается в автоматическом режиме- Террорист;(true positive)
# Страница создания ваера в админке -Create bank wire.
# Получатель = пользователь КУС2.
# Создается неопознанный ваер.

 	Given Set StartTime for DB search
 #STEP 1
 	Then Create BankWireInTemp and Accept with Type=Undefined:
	 | Reference   | SupportUserId                        | SenderName       | BeneficiaryAccountNumber        | PaymentAmount | OurCharge | BankCharge | CurrencyId | PaymentDetails | WireServiceId |
	 | <Reference> | 403d5963-b904-4a78-a51b-eab922bc5640 | Alexey Milchakov | <EPS-03UndefinedWiresPurseFull> | 1231          | 5         | 1          | 2          | details        | 4             |  

 	Then User selects record in 'SanctionCheck' where UserId ="<SystemPurseUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | InProcess	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
  #STEP 2
 ##############################_Transactions_################################################
	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="<EPS-03UndefinedWiresPurseFull>":
 	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
 	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
 	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |  
 	 
 	 Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
 ##############################_Transactions_################################################
 
 #STEP 3
  Then Send CA true positive callback for reference '<Reference>'

   	Then User selects record in 'SanctionCheck' where UserId ="<SystemPurseUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | Confirmed	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
 Given Reset checkers
  ##############################_Transactions_################################################
  	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="<EPS-03UndefinedWiresPurseFull>":
  	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
  	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
  	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |     
 
  	 Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'
  ##############################_Transactions_################################################

 @3050378
  Examples:
     | Reference            | PaymentAmount | BankCharge | ourCharge | SystemPurseUserId                    | EPSUserId                            | EPS-01Commissions | EPS-03UndefinedWiresPurse | EPS-03UndefinedWiresPurseFull | EPS-04Terrorist |
     | asdasdwasdzxcvbn9999 | 1231          | 1          | 5         | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 1101                      | 000-001101                    | 666698          |

	 


	 Scenario Outline: Входящий неопознанный ваер создается в автоматическом режиме- PEP / Terrorist(false positive)
# Страница создания ваера в админке -Create bank wire.
# Получатель = пользователь КУС2.
# Создается неопознанный ваер.

 	Given Set StartTime for DB search
 #STEP 1
 	Then Create BankWireInTemp and Accept with Type=Undefined:
	 | Reference   | SupportUserId                        | SenderName       | BeneficiaryAccountNumber        | PaymentAmount | OurCharge | BankCharge | CurrencyId | PaymentDetails | WireServiceId |
	 | <Reference> | 403d5963-b904-4a78-a51b-eab922bc5640 | Alexey Milchakov | <EPS-03UndefinedWiresPurseFull> | 1231          |           | 1          | 2          | details        | 4             |  

	Then User selects record in 'SanctionCheck' where UserId ="<SystemPurseUserId>":
  	  | Scenario    | Status         | IsConfirmedPep |
  	  | BankWireIn  | InProcess	     | false          | 
  	  | BankWireIn  | Not Sanctioned | false          | 
 
 #STEP 2
	Then Send CA <ResponseFromCA> positive callback for reference '<Reference>'

 
 ##############################_Transactions_################################################
	Then User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber="<EPS-03UndefinedWiresPurseFull>":
 	  | Amount          | DestinationId | Direction | UserId              | CurrencyId | PurseId             | RefundCount |
 	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
 	  | <BankCharge>    | BankComission | out       | <EPSUserId>         | Eur        | <EPS-01Commissions> | 0           |
 	  | <PaymentAmount> | Refill        | out       | <SystemPurseUserId> | Eur        | <EPS-04Terrorist>   | 0           |
 	  | <PaymentAmount> | Refill        | in        | <SystemPurseUserId> | Eur        | 1101                | 0           |   

 	Then No records in 'LimitRecords'
 	 
	Then No records in 'TExternalTransactions'

# [EPA-6458] 
# 	 Then User selects records in 'TExternalTransactions' 
# 	  | Amount          | CurrencyId | ExternalServiceId | IsIncomingTransaction |
# 	  | <PaymentAmount> | Eur        | Rietumu           | true                  |
# 	  | <BankCharge>    | Eur        | Rietumu           | false                 |
  ##############################_Transactions_################################################


#Входящий неопознанный ваер создается в автоматическом режиме- PEP
 @3050382
  Examples:
      | ResponseFromCA | Reference | PaymentAmount | BankCharge | ourCharge | SystemPurseUserId                    | EPSUserId                            | EPS-01Commissions | EPS-03UndefinedWiresPurse | EPS-03UndefinedWiresPurseFull | EPS-04Terrorist |
      | PEP            | nikwire9  | 1231          | 1          | 5         | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 1101                      | 000-001101                    | 666698          |   


#Входящий неопознанный ваер создается в автоматическом режиме- Террорист(false positive)
@3053087
  Examples:
      | ResponseFromCA | Reference | PaymentAmount | BankCharge | ourCharge | SystemPurseUserId                    | EPSUserId                            | EPS-01Commissions | EPS-03UndefinedWiresPurse | EPS-03UndefinedWiresPurseFull | EPS-04Terrorist |
      | false          | nikwire9  | 1231          | 1          | 5         | F03ABC6E-25D6-4C98-A06F-A36B9B510BAF | 99B4BB5F-2BE5-4481-9E78-F2E30339DC88 | 406604            | 1101                      | 000-001101                    | 666698          |  



