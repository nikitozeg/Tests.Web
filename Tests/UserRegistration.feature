@UserRegistration
Feature: UserRegistration


	@135397 
Scenario: Регистрация Individual User (по email)

	
	
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
	
     Then No EPA cards section in menu
	 Then No Affiliate Program section in menu
	 Then User selects records in 'Users' for created user:
		| KYCId | UserRole | State    | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |      
 
	 Then User selects records in table 'Notification' for created user
      | MessageType | Priority | Receiver     | Title                      |
      | Email       | 3        | **Receiver** | Изменение статуса аккаунта |  
      | Email       | 1        | **Receiver** | Подтверждение e-mail |
	  
	Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                |    |  
	
	Then User selects records in table 'EpaZendeskUser' for created user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   



	@3674445 
Scenario: Регистрация Business User

	 Given User goes to registration page
	 Given User clicks on "Бизнес аккаунт"
	 Given User clicks on button "Продолжить"
	 Given Set StartTime for DB search

	 Then 'Электронная почта' set to random email
	  Given User clicks on button "Регистрация"
	 Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 8             | **email** |  

	Then 'Пароль *' set to '72621010Abac'

	Then 'Код подтверждения *' set confirmation code

	Given User clicks on button "Продолжить"

	Then User redirected to account page
	Then No Affiliate Program section in menu
	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State | IsPep | PasswordExpireAt |
	    | 0     | 60       | Lead  | 0     | 9999-12-31       |  
	Given User fills User activation details for Business user:
	   | CompanyName    | WebSite                      | RegNumber | Country | TradingAddress       |
	   | nikita company | https://www.nikitaivanov.com | 9852108   | Россия  | USA,NY,Wall street 3 |   
	Given User clicks on "Далее" on Multiform

	Then 'Имя' set FirstName to random text
	Then 'Фамилия' set LastName to random text
	Then 'Страна проживания' UI selector set to 'Россия'
	Then 'Дата рождения' set to '01.01.1991'
	Then 'Номер телефона' set to random phone
	Given User clicks on "Мужской"
 
	Given Set StartTime for DB search
	
	Then User set Country "Россия" in address of residence
	Then User sets State to Республика Татарстан
	Then User sets City to Казань
	Then User sets Postal Code to 424003
	Then User sets Address to Адресс
	Then Make screenshot

	Given User clicks on "Далее" on Multiform

	 Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5             | **Email** |  
	 Given User fills ConfirmationCode on activation details
	 Given User clicks on button "Далее"
	
   Then User gets message "Спасибо за предоставление информации о компании. Для получения доступа до финансовых операций вам осталось подтвердить документами указанную информацию" on Multiform
   	Given User clicks on "Закрыть"
	 
	 Then User selects records in table 'Notification' for created user
      | MessageType | Priority | Receiver     | Title                |
      | Email       | 3        | **Receiver** | Верификация аккаунта |
      | Sms         | 1        | **Receiver** |       -               |  
	 Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State                     | IsPep | PasswordExpireAt |
	    | 1     | 60       | WaitingManualRegistration | 0     | 9999-12-31       |    
	Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                | Male   |  
	Then User selects records in table 'EpaZendeskUser' for created business user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    | **today** |   

	
	Then Modal window 'needAgreeMemberTerms' is opened
		 
	Then Click on Согласен(-а) on Modal Window

	Then User clicks on Верифицировать счет on Menu
	Then User confirms Identity
	| Citizenship | DocumentNumber | ValidUntil | DocumentUpload |
	| Россия      | 12312 43        | 01.01.2099  | 3.jpg    |  

	Then User confirms Company details with document 3.jpg
	Then User clicks on Верифицировать счет on Menu
	Then User confirms Address "Россия, Республика Татарстан, 424003, Казань, Адресс" with document 3.jpg
	Then User fill Financial activity questionnaire 
	Given User clicks on "Закрыть"
	Then User send verification request
	Then User gets message "Заявка на рассмотрении" on Multiform
	Then Operator marks business user with RiskLevel A
	Then Operator set created user as verified
	Given User clicks on "Закрыть"
	Then User refresh the page
	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State    | IsPep | PasswordExpireAt |
	    | 2     | 61       | Approved | 0     | 9999-12-31       |  
	Given User clicks on Партнерская программа menu
	Given User see partner links:
	| LinkNames | Transitions | Registrations | ForPayment | Processing | Cancelled |
	| **link**  | 0           | 0             | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |  

	
	@1674898 
Scenario: Регистрация по партнерской ссылке (физик)
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
		  | 33             | email     |  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	 Then Verification widget appears

	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State | IsPep | PasswordExpireAt |
		| 1     | 185      | Approved | 0     | *today+6month*   |    

 
	Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                |    |  
	Then User selects records in table 'EpaZendeskUser' for created user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   
		   
     Then No EPA cards section in menu
	 Then No Affiliate Program section in menu
 
	Given User LogOut
	
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given User see partner links with updated columns:
		| LinkNames  | Transitions | Registrations | ForPayment | Processing | Cancelled |
		| 000-255206 | 0           | 0             | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |
		| hidvltu1f8 | +1          | +1            | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |  
	Then User selects records in table 'BonusProgramClients' for created user:
        | BonusRefOwnerId | IsActive | UtmSource | UtmMedium | UtmTerm | UtmContent | UtmCampaign | LinkType     | Link       |
        |                 | true     |   -        | -          |    -     |   -         |    -         | AffilateLink | hidvltu1f8 |  



	@135400 
Scenario: Регистрация по бонусной ссылке (физик)

	Given User goes to SignIn page
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given Memorize partner link table with 2 links
	Given User LogOut
	Given User open partner's link "http://r.sandbox.epayments.com/?promo=000-255206"
	Then User receive Cookie "referenceId" 
	Then User receive Cookie "tags" 
	Then User receive Cookie "iv" 
	Then User receive Cookie "promocode" 
	 Given User clicks on "Войти" on Landing Page

	 Given User goes to registration page

	  Given User clicks on button "Продолжить"
	Then Checkbox "Есть промокод?" is checked
		Then 'Промокод' value is '000-255206'
			Then Text "Регистрация по промо-коду:" appears 
			Then Text "000-255206" appears 

	 Then 'Имя' set FirstName to random text
	 Then 'Фамилия' set LastName to random text
	 	  Then User change Country to Россия
	 Then 'Электронная почта' set to random email
	 Then 'Пароль' set to '72621010Abac'
	 Then 'Дата рождения' set to '01.01.1991'


		 Given Set StartTime for DB search
		 
     Then User scrolls down
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
	    | 1     | 185      | Approved | 0     | 9999-12-31       |  

	 Then User selects records in table 'Notification' for created user
      | MessageType | Priority | Receiver     | Title                      |
      | Email       | 3        | **Receiver** | Изменение статуса аккаунта |
      | Email       | 1        | **Receiver** | Подтверждение e-mail       |  

		Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                |        |  
	Then User selects records in table 'EpaZendeskUser' for created user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   
 
     Then No EPA cards section in menu
	 Then No Affiliate Program section in menu

	Given User LogOut
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given User see partner links with updated columns:
		| LinkNames  | Transitions | Registrations | ForPayment | Processing | Cancelled |
		| 000-255206 | +1          | +1            | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |
		| hidvltu1f8 | 0           | 0             | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |  
	Then User selects records in table 'BonusProgramClients' for created user:
        | BonusRefOwnerId                      | IsActive | UtmSource | UtmMedium | UtmTerm | UtmContent | UtmCampaign | LinkType | Link       |
        | 65B6AFB7-C21F-45A5-853B-45C2DA9D8A44 | true     | -         | -         | -       | -          | -           | Bonus    | 000-255206 |  

		
	@2712877 
Scenario: Регистрация по бонусной ссылке c UTM метками(физик)
	Given User goes to SignIn page
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given Memorize partner link table with 2 links
	Given User LogOut
	Given User open partner's link "http://r.sandbox.epayments.com/?promo=000-255206&utm_medium=[wrrwrw]&utm_source=[fhghghgf]&utm_campaign=[gfhghjhgjgh]&utm_term=[ghjghj]&utm_content=[ghjhgjghj]"
	Then User receive Cookie "referenceId" 
	Then User receive Cookie "tags" with value [{"utm_source": "%5bfhghghgf%5d"}, {"utm_term": "%5bghjghj%5d"}, {"utm_medium": "%5bwrrwrw%5d"}, {"utm_content": "%5bghjhgjghj%5d"}, {"utm_campaign": "%5bgfhghjhgjgh%5d"}] 
	Then User receive Cookie "iv" 
	Then User receive Cookie "promocode" 
	 Given User clicks on "Войти" on Landing Page
	 Given User goes to registration page

	Given User clicks on button "Продолжить"
	Then Checkbox "Есть промокод?" is checked
	Then 'Промокод' value is '000-255206'
	Then Text "Регистрация по промо-коду:" appears 
	Then Text "000-255206" appears 

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
	  Given Set StartTime for DB search

	 Given User clicks on button "Продолжить"

	 Then Verification widget appears

 Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State    | IsPep | PasswordExpireAt |
	    | 1     | 185       | Approved | 0     | 9999-12-31       | 


	 Then User selects records in table 'Notification' for created user
     | MessageType | Priority | Receiver     | Title                      |
     | Email       | 3        | **Receiver** | Изменение статуса аккаунта |  

	Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State    | IsPep | PasswordExpireAt |
	    | 1     | 185       | Approved | 0     | 9999-12-31       |  
	Then User selects records in 'PersonalData' for created user:
	    | Email     | MobilePhone     | FirstName     | LastName      | BirthDate  | CitizenShipCountryId | ResidenceCountryId | Gender |
	    | **Email** | **MobilePhone** | **Generated** | **Generated** | 01.01.1991 |                      | 185                |        |  
	Then User selects records in table 'EpaZendeskUser' for created user:
       | EpaId    | ZendeskId | CreatedOn    | UpdatedOn |
       | <UserId> | **ID**    | **today**    |           |   
 
     Then No EPA cards section in menu
	 Then No Affiliate Program section in menu

	Given User LogOut
	Given User signin "Epayments" with "a72f1644eabcf2a7fe28f9987e.autotest@qa.swiftcom.uk" password "72621010Abac"
	Given User clicks on Партнерская программа menu
	Given User see partner links with updated columns:
	| LinkNames  | Transitions | Registrations | ForPayment | Processing | Cancelled |
	| 000-255206 | +1          | +1            | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |
	| hidvltu1f8 | 0           | 0             | ~ 0.00 $   | ~ 0.00 $   | ~ 0.00 $  |  
	Then User selects records in table 'BonusProgramClients' for created user:
        | BonusRefOwnerId                      | IsActive | UtmSource  | UtmMedium | UtmTerm  | UtmContent  | UtmCampaign   | LinkType | Link       |
        | 65B6AFB7-C21F-45A5-853B-45C2DA9D8A44 | true     | [fhghghgf] | [wrrwrw]  | [ghjghj] | [ghjhgjghj] | [gfhghjhgjgh] | Bonus    | 000-255206 |  


		
Scenario Outline: Регистрация с попаданием на санкции - физ лицо

	Given User goes to registration page

	Given User clicks on button "Продолжить"
	Then Checkbox "Есть промокод?" is unchecked

	Then 'Имя' set to 'ALEXEY'
	Then 'Фамилия' set to 'MILCHAKOV'
	Then User change Country to Украина
	Then 'Электронная почта' set to random email
	Then 'Пароль' set to '72621010Abac'
	Then 'Дата рождения' set to '30.04.1991'
	Given Set StartTime for DB search
	Then Select checkbox 'Я принимаю Правила и условия использования сервиса и Политику конфиденциальности'
	Given User clicks on button "Регистрация"
	Then User gets VerificationCode in table 'ConfirmationCodes' by email:
		  | OperationType | Recipient |
		  | 33            | email     |  
		  
	 Then 'Ввести код вручную' set confirmation code
	 Given User clicks on button "Продолжить"

	 Then Verification widget appears

	
     Then No EPA cards section in menu

	Then No records in 'SanctionCheck' for created user
		Then User selects records in 'Users' for created user:
	    | KYCId | UserRole | State    | IsPep | PasswordExpireAt |
	    | 1     | 185      | Approved | 0     | *today+6month*       | 

	 Then User selects records in table 'Notification' for created user
      | MessageType | Priority | Receiver  | Title                      |
      | Email       | 3        | **Email** | Изменение статуса аккаунта |
      | Email       | 1        | **Email** | Подтверждение e-mail       |   
	
   
	Then Make screenshot
	 
	 Given Set StartTime for DB search

	Then User clicks on 'Через личный кабинет' on VerificationWidget
	Then 'Номер телефона:' set to random phone
	Given User clicks on "Отправить SMS"
	Then User gets VerificationCode in table 'ConfirmationCodes' by phone:
		  | OperationType | Recipient  |
		  | 5             | **Phone** |  


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
	Then 'Округ/Область:' set to 'state/district'
	Then 'Город:' set to 'city'
	Then 'Индекс:' set to '123456'
	Then 'Адрес:' details set to 'adress'
	Then Make screenshot

	Given User clicks on "Продолжить" on verification widget
	Then User scrolls down

	Then Set select option to 'Cтраница паспорта с адресом регистрации' 
	Then File "3.jpg" uploaded for verification
	Then Make screenshot
	Given User clicks on "Отправить заявку" on verification widget
	
	Then Verification widget contains 'Заявка на верификацию принята'
	Then Operator marks business user with RiskLevel A
	Then Operator try to set created user as verified
	 Then Make screenshot
	
	Then User selects record in 'SanctionCheck' for created user:
 	  | Scenario           | Status    | IsConfirmedPep |
 	  | BeforeVerification | InProcess | false          |  

	Then Send CA <IsSanctioned> positive callback for created user
	Then User selects record in 'SanctionCheck' for created user:
 	  | Scenario           | Status   | IsConfirmedPep |
 	  | BeforeVerification | <Status> | false          |  

	Then User selects records in 'Users' for created user:
		| KYCId   | UserRole   | State   | IsPep | PasswordExpireAt |
		| <KYCId> | <UserRole> | <State> | 0     | 9999-12-31       |  

@433742 
@Reset_first_name
Examples:
	| IsSanctioned | Status         | KYCId | State    | UserRole |
	| true         | Confirmed      | 5     | Blocked  | 63       |

@2951621 
@Reset_first_name
Examples:
	| IsSanctioned | Status         | KYCId | State    | UserRole |
	| false        | Not sanctioned | 2     | Approved | 62       |  

			

