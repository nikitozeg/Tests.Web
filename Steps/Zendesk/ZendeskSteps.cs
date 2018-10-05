using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using ePayments.Tests.ApiClient.ZendeskApiClient;
using ePayments.Tests.Common.Extensions;
using ePayments.Tests.Data.Domain.Poco;
using ePayments.Tests.Services;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;
using ZendeskApi_v2.Models.Tickets;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;


namespace ePayments.Tests.Web.Steps.Zendesk
{
    /// <summary>
    /// Zendesk UI steps
    /// </summary>
    [Binding]
    public class ZendeskSteps
    {
        private readonly Context _context;
        private ApiZendeskWrapper _apiZendesk;
        private long fileSize;
        public static String removeUploadedFile = ".icon-close-red-small";
        //Support: ticket chat
        public static String ChatMessages = ".chat-list-item";
        public static String FileIsUploaded = ".icon-check-small";
        public static String ChatHeader = ".chat-header";
        public static String ChatMessage = ".message";
        public static String ChatMessageTime = ".time";
        public static String ChatMessageAuthor = ".author";
        public static String SendButton = "button.ng-binding:not([disabled])";
        public static String AttachmentLocator = " .files a";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public ZendeskSteps(Context context)
        {
            _context = context;
            _apiZendesk = new ApiZendeskWrapper();
        }


        private void CheckChatList(List<ChatMessages> ticketChatList, string chatHeader)
        {
            _context.Grid.WaitElementWithText(ChatHeader, _context.TicketsIDList.Last() + ". " + chatHeader);

            //Waiting for expected ticked are loaded
            WaitCountOfCssElements(ChatMessages,ticketChatList.Count);

            CreateChatMessageList(_context.Grid.DataGridContent(ChatMessages, ticketChatList.Count)).Select(
                    row => new ChatMessages
                    {
                        From = row.From,
                        ChatMessage = row.ChatMessage
                    })
                .ShouldBeEquivalentTo(ticketChatList, options => options.WithStrictOrdering(),
                    $"ticketChatList не соответствуют ожидаемым");
        }

        private void CheckTicketsList(List<TicketsList> ticketListSet)
        {
            CreateTicketsList(_context.Grid.DataGridContent(TicketsListItem, ticketListSet.Count)).Select(
                    row => new TicketsList
                    {
                        Title = row.Title,
                        From = row.From,
                        LastMessage = row.LastMessage
                    })
                .ShouldBeEquivalentTo(ticketListSet,
                    $"TicketList не соответствуют ожидаемым");
        }


        private IEnumerable<ChatMessages> CreateChatMessageList(IList<IWebElement> grid)
        {
            List<ChatMessages> list = new List<ChatMessages>();

            foreach (var row in grid)
            {
                DateTime _date;
                Assert.True(
                    DateTime.TryParseExact(row.FindElement(By.CssSelector(ChatMessageTime)).Text, "HH:mm:ss", null,
                        DateTimeStyles.None, out _date), "Unable to parse chat date");

                var dic = new ChatMessages
                {
                    From = row.FindElement(By.CssSelector(ChatMessageAuthor)).Text,
                    Date = _date,
                    ChatMessage = row.FindElement(By.CssSelector(ChatMessage)).Text.Replace("\r\n", " ")
                };

                list.Add(dic);
            }

            return list;
        }

        private IEnumerable<TicketsList> CreateTicketsList(IList<IWebElement> grid)
        {
            List<TicketsList> list = new List<TicketsList>();

            foreach (var row in grid)
            {
                DateTime _date;
                Assert.True(
                    DateTime.TryParseExact(row.FindElement(By.CssSelector(TicketsListDate)).Text, "dd.MM.yyyy, HH:mm",
                        null, DateTimeStyles.None, out _date), "Unable to parse ticket date");
                var dic = new TicketsList
                {
                    Title = row.FindElement(By.CssSelector(TicketsListTitle)).Text,
                    LastMessage = row.FindElement(By.CssSelector(TicketsListMessage)).Text,
                    From = row.FindElement(By.CssSelector(TicketsListFrom)).Text,
                    Date = _date
                };

                list.Add(dic);
            }

            return list;
        }


        [Then(@"Tickets (chat|overview|closed tickets) grid contains( with Title ""(.*)"")?:")]
        public void ThenTicketsGridContains(string location, string opt, string Title, Table table)
        {
            switch (location)
            {
                case "chat":
                    _context.Grid = SupportPage.FindTicketChatForm();
                    CheckChatList(table.CreateSet<ChatMessages>().ToList(), Title);
                    break;
                case "overview":
                    _context.Grid = SupportPage.FindTicketsGrid();
                    CheckTicketsList(CommonComponentHelper.ReplaceTableWithList(table.CreateSet<TicketsList>().ToList(),
                        _context.TicketsIDList));
                    break;
                case "closed tickets":
                    _context.Grid = SupportPage.FindTicketsGrid();
                    CheckTicketsList(CommonComponentHelper.ReplaceTableWithList(table.CreateSet<TicketsList>().ToList(),
                        new List<long> {_context.TicketsIDList.ToList().Last()}));
                    break;

                default:
                    throw new Exception("No any case -branch for " + location);
            }
        }


        [Given(@"User leave a rate")]
        public void GivenUserLeaveARate()
        {
            _context.Grid
                .ClickOnElement(".star-rating li")
                .SendText(".ticket-feedback textarea", "asdasd");
        }


        [Then(@"Zendesk operator close last created ticket")]
        public void ThenZendeskOperatorCloseNewTicket()
        {
            _apiZendesk.CloseTicket(_context.TicketsIDList.ToList().Last());
        }

        [Then(@"Zendesk operator creates new ticket:")]
        public void ThenZendeskOperatorCreatesNewTicket(Table table)
        {

            foreach (var row in table.CreateDynamicSet().ToList())
            {
                var createTicketResponse = _apiZendesk.CreateTicket(
                    new Ticket
                    {
                        Priority = row.Priority,
                        Status = row.Status,
                        GroupId = (long) row.GroupId,
                        AssigneeId = (long) row.Operator_id,
                        SubmitterId = (long) row.Operator_id,
                        RequesterId = (long) row.RequesterId,
                        Comment = new Comment
                        {
                            Body = row.Body,
                            Public = true,
                            AuthorId = (long) row.Operator_id
                        },
                        Subject = row.Subject
                    });

                _context.TicketsIDList.Add((long) createTicketResponse.Ticket.Id);
            }
        }

        [Then(@"Zendesk operator '(.*)' replied with '(.*)' on created ticket with status ""(.*)""")]
        public void ThenZendeskOperatorRepliedOnCreatedTicket(long operatorId, string replyText, string status)
        {
            _apiZendesk.AddMessageToTicketBehalfUser(_context.TicketsIDList.ToList().Last(), operatorId, replyText, status);
        }


        [Then(@"Zendesk operator '(.*)' puts internal comment '(.*)' on created ticket")]
        public void ThenZendeskOperatorCreatesInternalComment(long operatorId, string replyText)
        {
            _apiZendesk.CreateInternalComment(_context.TicketsIDList.ToList().Last(), operatorId, replyText);
        }

        [Then(@"Zendesk contains created ticket with Priority=""(.*)"" and Title=""(.*)""( with attachment)?")]
        public void ThenUserGoesToZendeskTicket(string Priority, string Subject, string optAttachment, Table table)
        {
            var ticketId = _context.TicketsIDList.Last();

            var comments = _apiZendesk.GetTicketComments(ticketId);
            var ticket = _apiZendesk.GetTicket(ticketId).Ticket;

            Assert.True(ticket.Priority.EqualsIgnoreSpaceAndCase(Priority),
                "Priority fact is: " + ticket.Priority + "expected: " + Priority);
            Assert.True(ticket.Subject.EqualsIgnoreSpaceAndCase(Subject),
                "Title fact is: " + ticket.Subject + "expected: " + Subject);

            var ticketList = table.CreateSet<Comment>().ToList();

            comments.Comments.Select(
                    comment => new
                    {
                        comment.Body,
                        comment.AuthorId
                    })
                .ShouldBeEquivalentTo(
                    ticketList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    $"TicketComments не соответствуют ожидаемым");

            if (!optAttachment.IsNullOrWhiteSpace())
            {
                comments.Comments.Last().Attachments.Should().NotBeEmpty("Zendesk should contains uploaded file");

            }
        }

        [Then(@"User selects records in table 'UserAttachment' for last created ticket:")]
        public void ThenUserSelectsRecordsInTableForLastCreatedTicket(IEnumerable<UserAttachment> expectedList)
        {
            expectedList.First().TicketId = _context.TicketsIDList.ToList().Last();

            new DataBaseSteps(_context)
                .UserSelectsRecordsUserAttachment(expectedList.First().TicketId, expectedList);
        }

        [Then(@"User see (.*) unread comments in ticket")]
        public void ThenUserSeeUnreadMessages(string unreadCount)
        {
            SearchElementByCss(TicketsUnreadCount).Text.Should().Be(unreadCount);
        }

        [Then(@"User clicks on last ticket")]
        public void ThenUserClicksOnLastTicket()
        {
            SearchElementByTextXpath(_context.TicketsIDList.ToList().Last().ToString()).Click();
            WaitElementIsVisibleByCss(ChatMessages);
        }


        [Then(@"User add comment in ticket")]
        public void ThenUserAddCommentTicket(TicketComment comment)
        {


            string filePath = Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory,
                @"..\..\Resources" + comment.File));

            _context.Grid
                .SendText(TicketMessage, comment.Message)
                .SendText(UploadBtn, filePath);

            if (!comment.File.IsNullOrWhiteSpace())
                WaitElementIsVisibleByCss(FileIsUploaded);

        }


        [Given(@"User clicks on (ADD|Отправить|Remove uploaded file)( with attachment)?")]
        public void GivenUserClicksOnAddIcon(string item, string opt)
        {
            switch (item)
            {
                case "ADD":
                    _context.Grid.ClickOnElement(Icons);
                    _context.Grid = SupportPage.FindCreateTicketForm();
                    break;
                case "Отправить":
                    _context.StartDate = DateTime.UtcNow;
                    if (opt.Contains("with attachment"))
                        WaitElementIsVisibleByCss(FileIsUploaded);

                    _context.Grid.ClickOnElement(SendButton);
                    CommonComponentHelper.WaitPreloaderFinish(PreloaderTicketChat);
                    _context.Grid = SupportPage.FindTicketChatForm();

                    _context.TicketsIDList.Add(Convert.ToInt64(new Uri(DriverManager.GetWebDriver().Url).Fragment
                        .Split('/')
                        .Last()));

                    break;
                case "Remove uploaded file":
                    _context.Grid.ClickOnElement(removeUploadedFile);
                    _context.Grid = SupportPage.FindTicketChatForm();
                    break;
                default:
                    throw new Exception("No any case -branch for " + item);
            }
        }

        [When(@"Ftp dir ""(.*)"" contains only (.*)\.jpg file")]
        public void WhenUserCheckFTPFile(string path, string filename)
        {
            new FTPDownloadService(TestConfiguration.Current.FtpUrl)
                .CheckFileSizeInPath(path + DateTime.UtcNow.ToString("yyyyMMdd"), fileSize);
        }

        [Then(@"User fills ticket details:")]
        public void ThenUserFillsTicketDetails(Table table)
        {
            var set = table.CreateDynamicSet().ToList();

            string filePath = Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory,
                @"..\..\Resources" + set[0].File));

            if (!(set[0].File == ""))
            {
                fileSize = new FileInfo(filePath).Length;
            }
            _context.Grid
                .SendText(TicketTitle, set[0].TicketHeader)
                .SendText(TicketMessage, set[0].Message)
                .SendText(UploadBtn, filePath);
        }


        [Then(@"Unread tickets messages ""(.*)"" appears on sidebar and on active tab")]
        public void ThenUnreadTicketsMessagesAppearsOnSidebarAndOnActiveTab(string unreadMessagesCount)
        {
            WaitCssElementContainsText(Sidebar + Support + Counter, unreadMessagesCount);
            WaitCssElementContainsText(TicketsActiveTab, unreadMessagesCount);
        }

        [Then(@"Last ticket comment contains file URL")]
        public void ThenLastTicketCommentContainsFileURL()
        {
            _context.Grid.FindElement(ChatMessages + AttachmentLocator).GetAttribute("href").Should()
                .Contain("api.sandbox.epayments.com/attachments/token/");
        }


        /// <summary>
        /// Возвращает дату комментария по его тексту
        /// </summary>
        /// <param name="comment">текст комментария</param>
        /// <returns>DateTime</returns>
        public static DateTime GetCommentDateByText(string comment)
        {
            DateTime commentTime;

            Assert.True(
                DateTime.TryParseExact(SearchElementByTextXpath(comment).FindElement(By.XPath("./ancestor::li//*[@class='time ng-binding']")).Text,
                    "HH:mm:ss",
                    null,
                    DateTimeStyles.None, out commentTime), "Unable to parse chat date");

            return commentTime;
        }
    }
}