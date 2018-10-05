@SignIn
Feature: SignIn


	@349996
Scenario: Капча при входе в систему
	 Given User goes to SignIn page
	Given User signin "Epayments" with "nikitoz12@mail.ru" password "72621010Abaccc"
	 Given User gets "Неверный логин или пароль" message on Landing SignIn form
     Given User type password "72621010Abaccc"
	 Given User clicks on "Войти"
	 Given User gets "Неверный логин или пароль" message on Landing SignIn form
	 Given Captcha appears
	 Then Make screenshot
	 Given User type password "72621010Abaccc"

	 Given Button "Войти" is Disabled
	   Given Captcha appears
	 Given Captcha submitted
	 Given User clicks on "Войти"
	   Given Captcha appears
	 Given Captcha submitted
	 Then Make screenshot
     Given User type password "72621010Abac"
	 Given User clicks on "Войти"
	 Given User see Account Page


@135437
  Scenario: Вход в систему. Обработка ошибок
     
		Given User goes to SignIn page
  Given User signin "Epayments" with "70008888888" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form

       Given User goes to SignIn page
  Given User signin "Epayments" with "70008888" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form

  
       Given User goes to SignIn page
  Given User signin "Epayments" with "7000888888801234" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form

         Given User goes to SignIn page
  Given User signin "Epayments" with "bizqa.swiftcom.uk" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form

           Given User goes to SignIn page
  Given User signin "Epayments" with "@qa.swiftcom.uk" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form

             Given User goes to SignIn page
  Given User signin "Epayments" with "biz@" password "72621010Abacc"
  Given User gets "Номер телефона / e-mail указан неверно" message on SignIn form



	@135438
  Scenario: Восстановление пароля 
  
  Given User goes to SignIn page
  Given User clicks on "Забыли пароль?"
  Then Redirected to /#/restorepassword

  Given User type login invalid@login.com

    Given Captcha appears on SignIn Page
  Given Captcha submitted
  Given User clicks on "Далее"
  Then Validating message "Пользователь не найден или не существует" appears
  Then Make screenshot

  Then User clears password login field
  Given User type login +70066953484
    Given Captcha appears on SignIn Page
  Given Captcha submitted
  Given Set StartTime for DB search
  Given User clicks on "Далее"
  Given User fills new password
  Then User gets VerificationCode in table 'ConfirmationCodes' where:
	  | OperationType | Recipient    |
	  | 1             | +70066953484 |  
  Given User fills ConfirmationCode for restoring password
  Given Set StartTime for DB search
  Given User clicks on "Прислать код повторно" on restore password page

  Given User clicks on "Подтвердить"
  Then Validating message "Код введен неверно" appears
  Then Make screenshot
  Then User clears confirmation code field
  
  Then User gets VerificationCode in table 'ConfirmationCodes' where:
	  | OperationType | Recipient    |
	  | 1             | +70066953484 |  
  Given User fills ConfirmationCode for restoring password
  Given Set StartTime for DB search

  Given User clicks on "Подтвердить"
  Given User see Account Page

  Then User selects records in table 'Notification' for UserId="fb666660-1a9f-4b84-b35d-95771abec0d7"
		| MessageType | Priority | Receiver                                           | Title            |
		| Email       | 3        | db73f147ef8ff407309a8d0509.autotest@qa.swiftcom.uk | Изменение пароля |  
  Given User LogOut
  Given User signin "Epayments" with "+70066953484" restored password
  Given User see Account Page



@2712874
@Unfreeze_user
  Scenario Outline: Вход в систему. Заморозка пользователя на 60мин
   Given User goes to SignIn page
   Given User signin "Epayments" with "<Login>" password "72621010Abac"
  Given Captcha appears
  Given Captcha submitted
  Given User clicks on "Войти"
  Given User see Account Page
  Given User LogOut
  Given User signin "Epayments" with "<Login>" password "<Password>"
 
 Given User gets "Неверный логин или пароль" message on Landing SignIn form
  Given User type password "<Password>"
  Given User clicks on "Войти"

  Given User gets "Неверный логин или пароль" message on Landing SignIn form
  Given User type password "<Password>"
   Given Captcha appears
  Given Captcha submitted
  Given User clicks on "Войти"

  Given User gets "Неверный логин или пароль" message on Landing SignIn form

  Given User type password "<Password>"
    Given Captcha appears
  Given Captcha submitted
  Given User clicks on "Войти"
  Given User gets "Неверный логин или пароль" message on Landing SignIn form

   Given User type password "<Password>"
     Given Captcha appears
   Given Captcha submitted

    Given Set StartTime for DB search

   Given User clicks on "Войти"
   Given User gets "Неверный логин или пароль" message on Landing SignIn form
   Given User gets "Счет будет разблокирован через: 00:59" message on Landing SignIn form
   Then Make screenshot
	Then User selects records in table 'Notification' for UserId="<UserId>"
		| MessageType | Priority | Receiver | Title                         |
		| Email       | 2        | <Login>  | Аккаунт временно заблокирован |  
  Examples:
	| UserId                               | Login                                              | Password |
	| 70dcac51-8f06-457e-95ec-2ee036702338 | 0f7d264c08b5e939e6e6e38da2.autotest@qa.swiftcom.uk | invalid  |  



			@455121 
Scenario: Отслеживание UTM меток
	Given User open link "https://www.sandbox.epayments.com/ru/?utm_source=3&utm_medium=1&utm_campaign=wm5"
	Then Cookie "tags" is not received
	Given User open link "https://www.sandbox.epayments.com/?utm_source=3&utm_medium=1&utm_campaign=wm4"
	Then User receive Cookie "tags" with value [{"utm_source": "3"}, {"utm_term": ""}, {"utm_medium": "1"}, {"utm_content": ""}, {"utm_campaign": "wm4"}] 
	Given User goes to SignIn page

