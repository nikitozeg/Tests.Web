using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using System;
using System.Globalization;
using System.Linq;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.CardAndAccounts
{
    /// <summary>
    /// Card And Accounts UI steps 
    /// </summary>
    [Binding]
    class CardAndAccountsSteps
    {
        //Cards and Accounts 
        public static string EpaymentsCardBlock = ".cards";

        public static string Cards = ".cards-item-content";
        public static string MaintenanceDetails = ".dropdown.expires";
        public static string CardOptions = ".svg-icon-card-more";

        private readonly Context _context;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public CardAndAccountsSteps(Context context)
        {
            _context = context;
        }

        [Then(@"Message ""(.*)"" with replacing (month|date|today-2d|on current month|currentDate)")]
        public void ThenMessageReplacedAppears(string expectedFeeServiceDate, string replacedValue)
        {
            DateTime _date;
            var expectedText = expectedFeeServiceDate.Split(':');

            switch (replacedValue)
            {
                case "month":
                    DateTime.TryParseExact(
                        expectedText[1],
                        "dd.MM.yy",
                        null,
                        DateTimeStyles.None,
                        out _date);

                    if (_date.Day >= DateTime.UtcNow.Day)
                        _date = new DateTime(_date.Year, DateTime.UtcNow.Month , _date.Day);
                    else
                        _date = new DateTime(_date.Year, DateTime.UtcNow.Month + 1, _date.Day);

                    break;
                case "on current month":
                    DateTime.TryParseExact(
                        expectedText[1],
                        "dd.MM.yy",
                        null,
                        DateTimeStyles.None,
                        out _date);

                        _date = new DateTime(_date.Year, DateTime.UtcNow.Month, _date.Day);
                    break;

                case "date":
                    _date = DateTime.UtcNow.AddMonths(2);
                    break;

                case "currentDate":
                    _date = DateTime.UtcNow.Date;
                    break;
                   
                case "today-2d":
                    _date = DateTime.UtcNow.AddDays(-2);
                    break;
                default:
                    throw new Exception("No any case -branch for " + replacedValue);
            }

            ThenMessageAppearsOnDropdown("Message", expectedText[0] + ":" + _date.Date.ToString("dd.MM.yy"), "USD");
        }

        [Then(@"(Text Message|Warning message|Success message|Alert Message|Text) ""(.*)"" appears")]
        public void ThenMessageAppearsOnDropdown(string location, string text)
        {
            switch (location)
            {
                case "Text":
                    _context.Grid.TextIsPresence(text);
                    break;
                case "Text Message":
                case "Alert Message":
                    SearchElementByTextXpath(text,60).Displayed.Should().BeTrue();
                    break;
                case "Success message":
                    SearchElementByCss(AlertBoxSuccess, 60).Text.Replace("\r\n", "").Should().Be(text);
                    break;
                case "Warning message":
                    SearchElementByCss(AlertBoxWarning, 60).Text.Replace("\r\n", "").Should().Be(text);
                    break;
                default:
                    throw new Exception("No any case -branch for " + location);
            }
        }

        [Then(@"(Message|Scale) ""(.*)"" appears on ""(.*)"" card")]
        public void ThenMessageAppearsOnDropdown(string location, string text, string currency)
        {
            var cardSection = $"//*[normalize-space()='{currency}']/..//*[contains(@class,'dropdown expires')]";

            switch (location)
            {
                case "Message":
                    _context.Grid.WaitElementWithTextByXPath(cardSection, text);
                    break;
                case "Scale":
                    WaitElementIsVisibleByXPath(cardSection);
                    break;
                default:
                    throw new Exception("No any case -branch for " + location);
            }
        }


        private DataGridComponent FindEpaCard(string card)
        {
            var cardEPA = new DataGridComponent(SearchElementByCss(EpaymentsCardBlock))
                .FindElementsContainsText(card, "/ancestor::*[@card='card']")
                .SingleOrDefault();

            return new DataGridComponent(cardEPA);
        }

        [Given(@"User clicks on ""(Разблокировать|Заблокировать|Активировать|Оплатить|Обслуживание:|Перевыпустить|Пополнить|Снять)"" ""(.*)"" 'Epayments Cards' at CardAndAccounts grid")]
        public void GivenUserClicksOnInGrid2(string value, string card)
        {
            switch (value)
            {
                case "Активировать":
                    _context.Grid=MultiFormComponent.FindUIView();
                    break;
                case "Заблокировать":
                    WaitElementIsVisibleByCss(CardOptions);
                    FindEpaCard(card).ClickOnElement(CardOptions);
                    WaitElementWithTextByXpath(value);
                    break;
                case "Разблокировать":
                    WaitElementWithTextByXpath(value);
                    _context.Grid = MultiFormComponent.FindUIView();
                    break;
            }
            CommonComponentSteps.MakeScreenshot();
            FindEpaCard(card).ClickByText(value, "", ".");
        }

        [Then(@"User order '(.*)'")]
        private void UserOrder(string labelText)
        {
           new DataGridComponent(SearchElementByCss(EpaymentsCardBlock))
                .ClickOnElement(Icons);

            WaitElementIsVisibleByXPath($".//*[contains(@label,'{labelText}')]");
            SearchElementByXpath($".//*[contains(@label,'{labelText}')]").Click();
        }
        
    }
}