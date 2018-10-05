@Tickets
Feature: Tickets

 @329213
  Scenario Outline: Zendesk

	  Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |
    Then User deletes records in table 'EpaZendeskUser':
      | EpaId    |
      | <UserId> |
     Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
    Given User clicks on "Закрытые" in "Служба поддержки" grid
    Then Message "У вас нет закрытых тикетов" appears on "Служба поддержки" view
    Given User clicks on "Активные" in "Служба поддержки" grid
    Then Message "У вас не создано ни одного тикета" appears on "Служба поддержки" view
	Then Make screenshot
   # // Add 1st ticket

    Given User clicks on ADD
    Then User fills ticket details:
      | TicketHeader | Message | File   |
      |              |         | \1.pdf |
    Then Alert Message "Размер загружаемого файла превышает максимально допустимое ограничение в 10 Mb" appears
    Then User fills ticket details:
      | TicketHeader | Message | File   |
      |              |         | \2.txt |
    Then Alert Message "Формат файла не поддерживается. Допустимы только файлы: JPG, JPEG, PNG, PDF" appears
    Then User fills ticket details:
      | TicketHeader    | Message         | File |
      | <TicketSubject> | <TicketMessage> |      |
	  Then Make screenshot
    Given User clicks on Отправить
    Then Tickets overview grid contains:
      | Title                                  | LastMessage     | From |
      | Тикет № **TICKET_ID**. <TicketSubject> | <TicketMessage> | Вы   |
    Then Zendesk contains created ticket with Priority="normal" and Title="<TicketSubject>"
      | Body            | AuthorId   |
      | <TicketMessage> | <AuthorId> |
    Then User selects records in table 'EpaZendeskUser' where EpaId="<UserId>":
      | EpaId    | ZendeskId    | CreatedOn    | UpdatedOn |
      | <UserId> | <AuthorId> | **DateTime** |           |  
	  Then Make screenshot
    Then User selects records in table 'EpaUserZendeskTicket' where EpaUserId="<UserId>":
      | Id     | EpaUserId | IsUnread | Subject         | Status | CreatedAt    | UpdatedAt    | LastMessage     | LastMessageByClient | CreatedViaChannel | Rating | RateMessage |
      | **Id** | <UserId>  | 0        | <TicketSubject> | 2      | **DateTime** | **DateTime** | <TicketMessage> | 1                   | 0                 |        |             |  
	Then User selects records in table 'Notification' where UserId="<UserId>" with "**TickedId**" replacing:
      | MessageType | Priority | Receiver | Title                |
      | Email       | 4        | <User>   | Тикет № **TickedId** |  

   # // Add 2nd ticket with file

    Given User clicks on ADD
    Then User fills ticket details:
      | TicketHeader     | Message          | File    |
      | <TicketSubject2> | <TicketMessage2> | \<File> |

    Given User clicks on Отправить with attachment
    Then Tickets chat grid contains with Title "<TicketSubject2>":
      | From | Date         | ChatMessage             |
      | Вы   | **DateTime** | <TicketMessage2> <File> |

    Then Tickets overview grid contains:
      | Title                                   | LastMessage      | From |
      | Тикет № **TICKET_ID**. <TicketSubject>  | <TicketMessage>  | Вы   |
      | Тикет № **TICKET_ID**. <TicketSubject2> | <TicketMessage2> | Вы   |
    Then Zendesk contains created ticket with Priority="normal" and Title="<TicketSubject2>"
      | Body             | AuthorId     |
      | <TicketMessage2> | <AuthorId> |
    Then User selects records in table 'EpaUserZendeskTicket' where EpaUserId="<UserId>":
      | Id     | EpaUserId | IsUnread | Subject          | Status | CreatedAt    | UpdatedAt    | LastMessage      | LastMessageByClient | CreatedViaChannel | Rating | RateMessage |
      | **Id** | <UserId>  | 0        | <TicketSubject>  | 2      | **DateTime** | **DateTime** | <TicketMessage>  | 1                   | 0                 |        |             |  
      | **Id** | <UserId>  | 0        | <TicketSubject2> | 2      | **DateTime** | **DateTime** | <TicketMessage2> | 1                   | 0                 |        |             |  

     # // Add 3rd ticket by Operator

    Then Zendesk operator creates new ticket:
      | Priority | Status | GroupId      | Operator_id  | Subject          | Body          | RequesterId |
      | high     | new    | 114094375453 | 114343373873 | Operator subject | Operator Body | <AuthorId>  |

    Then Zendesk contains created ticket with Priority="high" and Title="Operator subject"
      | Body          | AuthorId     |
      | Operator Body | 114343373873 |

    Then User refresh the page
    Then Tickets overview grid contains:
      | Title                                   | LastMessage      | From                      |
      | Тикет № **TICKET_ID**. <TicketSubject>  | <TicketMessage>  | Вы                        |
      | Тикет № **TICKET_ID**. <TicketSubject2> | <TicketMessage2> | Вы                        |
      | Тикет № **TICKET_ID**. Operator subject | Operator Body    | Оператор службы поддержки |
	  Then Make screenshot
    Then User selects records in table 'EpaUserZendeskTicket' where EpaUserId="<UserId>":
      | Id     | EpaUserId | IsUnread | Subject          | Status | CreatedAt    | UpdatedAt    | LastMessage      | LastMessageByClient | CreatedViaChannel | Rating | RateMessage |
      | **Id** | <UserId>  | 0        | <TicketSubject>  | 2      | **DateTime** | **DateTime** | <TicketMessage>  | 1                   | 0                 |        |             |
      | **Id** | <UserId>  | 0        | <TicketSubject2> | 2      | **DateTime** | **DateTime** | <TicketMessage2> | 1                   | 0                 |        |             |
      | **Id** | <UserId>  | 1        | Operator subject | 2      | **DateTime** | **DateTime** | Operator Body    | 0                   | 0                 |        |             |  
    Then Unread tickets messages "1" appears on sidebar and on active tab
    Given User clicks on "Operator subject" in "Служба поддержки" grid
    Then Tickets chat grid contains with Title "Operator subject":
      | From                      | Date         | ChatMessage   |
      | Оператор службы поддержки | **DateTime** | Operator Body |
	
	  # // 3rd Ticket closing 

	Then Zendesk operator close last created ticket
	Then User refresh the page
	Then Tickets overview grid contains:
      | Title                                   | LastMessage      | From |
      | Тикет № **TICKET_ID**. <TicketSubject>  | <TicketMessage>  | Вы   |
      | Тикет № **TICKET_ID**. <TicketSubject2> | <TicketMessage2> | Вы   |
	Given User clicks on "Закрытые" in "Служба поддержки" grid
	Then Tickets closed tickets grid contains:
      | Title                                   | LastMessage   | From                      |
      | Тикет № **TICKET_ID**. Operator subject | Operator Body | Оператор службы поддержки |  
	Given User clicks on "Operator subject" in "Служба поддержки" grid
    Then Tickets chat grid contains with Title "Operator subject":
      | From                      | Date         | ChatMessage   |
      | Оператор службы поддержки | **DateTime** | Operator Body |  
	Given User leave a rate
	Then Make screenshot
	Given User clicks on "Оценить"
	 Then Success message "Ваш отзыв получен, спасибо!×" appears
    Examples:
      | User                 | AuthorId     | TicketSubject | TicketMessage | TicketSubject2 | TicketMessage2 | File  | UserId                               | Password       |  paymentpwd |
    #  | nikitoz12@mail.ru    | 114551583954 | Title1        | Message1      | Title2         | Message2       | 3.jpg | a92ddb03-2a44-47d5-a5e7-cb1b15b36ff3 | 72621010Abacc |   111111     |
      | bizwm@qa.swiftcom.uk | 114551583954 | Title1        | Message1      | Title2         | Message2       | 3.jpg | a92ddb03-2a44-47d5-a5e7-cb1b15b36ff3 | 72621010Abacc |  111111     |  




  Scenario Outline: Сохранение документа из тикета на хол.сервер

    Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |
    Then User deletes records in table 'EpaZendeskUser':
      | EpaId    |
      | <UserId> |
     Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
    Given User clicks on "Активные" in "Служба поддержки" grid
    Then Message "У вас не создано ни одного тикета" appears on "Служба поддержки" view

	 # // Add ticket with file

    Given User clicks on ADD
    Then User fills ticket details:
      | TicketHeader | Message         | File         |
      | FirstTicket  | <TicketMessage> | \zendesk.png |   

    Given User clicks on Отправить with attachment
    Then Tickets chat grid contains with Title "FirstTicket":
      | From | Date         | ChatMessage                 |
      | Вы   | **DateTime** | <TicketMessage> zendesk.png |    

    Then Tickets overview grid contains:
      | Title                               | LastMessage     | From |
      | Тикет № **TICKET_ID**. FirstTicket | <TicketMessage> | Вы   |  

	 # // Add ticket with file that should be saved on FTP server

    Given User clicks on ADD
    Then User fills ticket details:
      | TicketHeader    | Message         | File    |
      | <TicketSubject> | <TicketMessage> | \<File> |  

    Given User clicks on Отправить with attachment
    Then Tickets chat grid contains with Title "<TicketSubject>":
      | From | Date         | ChatMessage             |
      | Вы   | **DateTime** | <TicketMessage> <File> |

    Then Tickets overview grid contains:
      | Title                                  | LastMessage     | From |
      | Тикет № **TICKET_ID**. FirstTicket     | <TicketMessage> | Вы   |
      | Тикет № **TICKET_ID**. <TicketSubject> | <TicketMessage> | Вы   |  
    Then Zendesk operator close last created ticket
	
	Then User refresh the page
	Then Tickets overview grid contains:
      | Title                                   | LastMessage      | From |
      | Тикет № **TICKET_ID**. FirstTicket    | <TicketMessage> | Вы   |  
	Given User clicks on "Закрытые" in "Служба поддержки" grid
	Then Tickets closed tickets grid contains:
      | Title                                  | LastMessage     | From |
      | Тикет № **TICKET_ID**. <TicketSubject> | <TicketMessage> | Вы   |

	
	Then User selects records in table 'UserAttachment' for last created ticket:
     | TicketId      | EpaUserId |
     | **TICKET_ID** | <UserId>  | 

	When Ftp dir "/storages/WiredDocs/<UserId>/" contains only <File> file

@688093
@DeleteFTPTicketDocuments
    Examples:
      | User                 | AuthorId     | TicketSubject                      | TicketMessage | File  | UserId                               | Password      | paymentpwd |
      | bizwm@qa.swiftcom.uk | 114551583954 | Incoming bank wire transfer (name) | Message1      | 3.jpg | a92ddb03-2a44-47d5-a5e7-cb1b15b36ff3 | 72621010Abacc | 111111     |
     
 @2949603
 @DeleteFTPTicketDocuments
    Examples:
     | User                 | AuthorId     | TicketSubject                      | TicketMessage | File  | UserId                               | Password      | paymentpwd |
	 | bizwm@qa.swiftcom.uk | 114551583954 | Входящий банковский перевод ()     | Message1      | 3.jpg | a92ddb03-2a44-47d5-a5e7-cb1b15b36ff3 | 72621010Abacc | 111111     |  


	  
	   @1341004
  Scenario Outline: EpaTicketsUpdater. Основные проверки

  #В шагах описано какие тикеты нужно создать. Каждый шаг - новый тикет. 
  #В ожидаемом результате - то, что будет с этим тикетом после запуска машинки.
  #Перед запуском необходимо убедиться, что время создание всех проверяемых тикетов попадает под период охватываемый машинкой 
  #(указывается в конфиге lastTicket.json, в нём есть только левая граница, правая всегда равна текущей дате).

    Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |
    Then User deletes records in table 'EpaZendeskUser':
      | EpaId    |
      | <UserId> |

   Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
	Given User clicks on "Активные" in "Служба поддержки" grid
	Given User clicks on ADD


## Step 1

	 Then User fills ticket details:
      | TicketHeader    | Message         | File |
      | <TicketSubject> | <TicketMessage> |      |
    Given User clicks on Отправить
    Then Zendesk operator '114343373873' replied with 'Public comment' on created ticket with status "open"

	
    Then Zendesk operator '114343373873' puts internal comment 'Internal comment' on created ticket

	Then User refresh the page
	Then Tickets overview grid contains:
      | Title                                  | LastMessage     | From |
      | Тикет № **TICKET_ID**. <TicketSubject> | Public comment | Оператор службы поддержки   |

	Then Tickets chat grid contains with Title "<TicketSubject>":
      | From                      | Date         | ChatMessage             |
      | Вы                        | **DateTime** | Message for ticket tool |
      | Оператор службы поддержки | **DateTime** | Public comment          |

 	When User download and executes "Tools.EpaTicketsUpdater"

	Then User refresh the page

	Then Tickets chat grid contains with Title "<TicketSubject>":
      | From                      | Date         | ChatMessage             |
      | Вы                        | **DateTime** | Message for ticket tool |
      | Оператор службы поддержки | **DateTime** | Public comment          |

	Then After 10 seconds delay User selects records in table 'Notification' where UserId="<UserId>" with "**TickedId**" replacing:
      | MessageType | Priority | Receiver | Title                |
      | Email       | 4        | <User>   | Тикет № **TickedId** | 
      | Email       | 4        | <User>   | Тикет № **TickedId** | 


## Step 2

	Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |

	  	Given User clicks on "Активные" in "Служба поддержки" grid
	 Given User clicks on ADD

	Then User fills ticket details:
      | TicketHeader    | Message         | File |
      | <TicketSubject> | <TicketMessage> |      |

    Given User clicks on Отправить
	 Then User selects records in table 'Notification' where UserId="<UserId>" with "**TickedId**" replacing:
      | MessageType | Priority | Receiver | Title                |
      | Email       | 4        | <User>   | Тикет № **TickedId** |  

	Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |
   
   Given Set StartTime for DB search

   When User executes "Tools.EpaTicketsUpdater"
   	 Then User selects records in table 'Notification' where UserId="<UserId>" with "**TickedId**" replacing:
      | MessageType | Priority | Receiver | Title                |
      | Email       | 4        | <User>   | Тикет № **TickedId** | 
	  Then User refresh the page
	   Then Tickets chat grid contains with Title "<TicketSubject>":
      | From | Date         | ChatMessage     |
      | Вы   | **DateTime** | <TicketMessage> |  

 ## Step 3

	Then User deletes records in table 'EpaUserZendeskTicket':
    | EpaUserId |
    | <UserId>  |
		Given User clicks on "Активные" in "Служба поддержки" grid
	Given User clicks on ADD
	Then User fills ticket details:
    | TicketHeader    | Message         | File |
    | <TicketSubject> | <TicketMessage> |      |

  Given User clicks on Отправить

	Then Zendesk operator '114343373873' replied with 'Public comment 1' on created ticket with status "open"
	Then Zendesk operator '114343373873' replied with 'Public comment 2' on created ticket with status "open"
 	Then User refresh the page

	Then User updates last comment in table 'EpaUserZendeskTicket' on comment='Public comment 1':
   When User executes "Tools.EpaTicketsUpdater"
 	 Then User selects records in table 'Notification' where UserId="<UserId>" with "**TickedId**" replacing:
    | MessageType | Priority | Receiver | Title                |
    | Email       | 4        | <User>   | Тикет № **TickedId** | 
    | Email       | 4        | <User>   | Тикет № **TickedId** | 
    | Email       | 4        | <User>   | Тикет № **TickedId** | 
    | Email       | 4        | <User>   | Тикет № **TickedId** | 

	 Given User clicks on Партнерская программа menu
	Then User refresh the page
		Given User clicks on "Активные" in "Служба поддержки" grid
	 Then User see 1 unread comments in ticket
	 Then User clicks on last ticket

	Then Tickets chat grid contains with Title "<TicketSubject>":
     | From                      | Date         | ChatMessage      |
     | Вы                        | **DateTime** | <TicketMessage>  |
     | Оператор службы поддержки | **DateTime** | Public comment 1 |
     | Оператор службы поддержки | **DateTime** | Public comment 2 |


	Examples:
      | User                         | AuthorId     | TicketSubject            | TicketMessage           | UserId                               | Password     |
      | ticketUIcheck@qa.swiftcom.uk | 114551583954 | Check update ticket tool | Message for ticket tool | f29d520c-b408-43e5-8004-eeb37bf98e6b | 72621010Abac |  




	   @329232
  Scenario Outline: Zendesk. Добавление комментария к тикету

	  Then User deletes records in table 'EpaUserZendeskTicket':
      | EpaUserId |
      | <UserId>  |
    Then User deletes records in table 'EpaZendeskUser':
      | EpaId    |
      | <UserId> |
     Given User goes to SignIn page
	Given User signin "Epayments" with "<User>" password "<Password>"
	Given User see Account Page
    Given User clicks on "Закрытые" in "Служба поддержки" grid
    Then Message "У вас нет закрытых тикетов" appears on "Служба поддержки" view
    Given User clicks on "Активные" in "Служба поддержки" grid
    Then Message "У вас не создано ни одного тикета" appears on "Служба поддержки" view
  
  # Step 1
    Given User clicks on ADD
    Then User fills ticket details:
      | TicketHeader    | Message | File |
      | <TicketSubject> | b       |      |    
	Given User clicks on Отправить

    Then Tickets overview grid contains:
      | Title                                  | LastMessage | From |
      | Тикет № **TICKET_ID**. <TicketSubject> | b           | Вы   |    
	Then Tickets chat grid contains with Title "<TicketSubject>":
      | From | Date         | ChatMessage             |
      | Вы   | **DateTime** | b                       |
	Then Zendesk contains created ticket with Priority="normal" and Title="<TicketSubject>"
      | Body | AuthorId     |
      | b    | 366446552834 |  
  
  # Step 2
	  Then User add comment in ticket
       | Message | File    |
       | -       | \<File> |  
	Given Button "Отправить" is Disabled on ticket form
	Given User clicks on Remove uploaded file
  
  # Step 3
   Then User add comment in ticket
       | Message | File |
       | c       |      |  
	   Given User clicks on Отправить
	Then Tickets chat grid contains with Title "<TicketSubject>":
      | From | Date         | ChatMessage |
      | Вы   | **DateTime** | b           |
      | Вы   | **DateTime** | c           |  

 # Step 4
	Then User add comment in ticket
       | Message | File    |
       | d       | \<File> |  
	Given User clicks on Отправить
	Then Tickets chat grid contains with Title "<TicketSubject>":
      | From | Date         | ChatMessage |
      | Вы   | **DateTime** | b           |
      | Вы   | **DateTime** | c           |
      | Вы   | **DateTime** | d <File>    |  
	Then Last ticket comment contains file URL 	

 Then Zendesk contains created ticket with Priority="normal" and Title="<TicketSubject>" with attachment
      | Body | AuthorId     |
      | b    | 366446552834 |
      | c    | 366446552834 |
      | d    | 366446552834 |  

#Step 5 -6
## To-do

#Step 7
	  Then Zendesk operator '114343373873' replied with 'pending' on created ticket with status "pending"
	  Then User refresh the page
	  Then Tickets chat grid contains with Title "<TicketSubject>":
		  | From                      | Date         | ChatMessage |
		  | Вы                        | **DateTime** | b           |
		  | Вы                        | **DateTime** | c           |
		  | Вы                        | **DateTime** | d <File>    |
		  | Оператор службы поддержки | **DateTime** | pending     |  

	   Then Zendesk operator '114343373873' replied with 'hold' on created ticket with status "hold"
	   Then User refresh the page
	   Then Tickets chat grid contains with Title "<TicketSubject>":
		  | From                      | Date         | ChatMessage |
		  | Вы                        | **DateTime** | b           |
		  | Вы                        | **DateTime** | c           |
		  | Вы                        | **DateTime** | d <File>    |
		  | Оператор службы поддержки | **DateTime** | pending     | 
		  | Оператор службы поддержки | **DateTime** | hold        | 

	 Then Zendesk operator '114343373873' replied with 'solved' on created ticket with status "solved"
	 Then User refresh the page
	 Then Tickets chat grid contains with Title "<TicketSubject>":
		  | From                      | Date         | ChatMessage |
		  | Вы                        | **DateTime** | b           |
		  | Вы                        | **DateTime** | c           |
		  | Вы                        | **DateTime** | d <File>    |
		  | Оператор службы поддержки | **DateTime** | pending     |
		  | Оператор службы поддержки | **DateTime** | hold        |
		  | Оператор службы поддержки | **DateTime** | solved      |  
		   Given User clicks on "Активные" in "Служба поддержки" grid

	Then Message "У вас не создано ни одного тикета" appears on "Служба поддержки" view
	Given User clicks on "Закрытые" in "Служба поддержки" grid
	Then Tickets closed tickets grid contains:
      | Title                                  | LastMessage | From                      |
      | Тикет № **TICKET_ID**. <TicketSubject> | solved      | Оператор службы поддержки |    

       Examples:
      | User                             | TicketSubject |  File  | UserId                               | Password     | 
      | ticketreplyuitest@qa.swiftcom.uk |  Title        |  3.jpg | 8a363797-d716-4e28-a45f-ae33a06aa07b | 72621010Abac | 

