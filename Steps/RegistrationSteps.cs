using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using System;
using System.IO;
using ePayments.Tests.Web.Fragments;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// User registering steps
    /// </summary>
    [Binding]
    public class RegistrationSteps
    {
        private readonly Context _context;
        private string confirmationCodeLocator = "input[name=confirmationCode]";
        private static String email = "input[name = email]";
        private static String phone = "input[name = phone]";
        private static String firstName = "[name=firstname]";
        private static String lastname = "[name=lastname]";
        private static String resendCodeButton = "[ng-click='ctrl.restartTimer()']";


        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public RegistrationSteps(Context context)
        {
            _context = context;
        }

        [Given(@"User lands on registration form")]
        private DataGridComponent InitPage()
        {
            _context.Grid = new DataGridComponent(SearchElementByCss(RegistrationView));
            _context.Grid.FindElement(RegistrationBtn);

            return _context.Grid;
        }

        [Given(@"User goes to registration page")]
        public void GivenUserGoesToRegistrationPage()
        {
                DriverManager.GetWebDriver().Navigate().GoToUrl(TestConfiguration.Current.MyUrl + "#/registration?type=0");
            InitPage();
        }

        [Given(@"User open (.*) from resources")]
        public void Open(string docName)
        {
            var path = Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory,
                @"..\..\Resources\" + docName));
            DriverManager.GetWebDriver().Navigate().GoToUrl("file:///"+path);
            SelectFragment.SetOption("Sandbox");

            DataGridComponent partnerRegistrationPage = new DataGridComponent(SearchElementByCss("tbody"));
            _context.UserExternalCode = partnerRegistrationPage.FindElement("#clientID").GetAttribute("value");

            partnerRegistrationPage
                .ClearText("#partnerSecretKey")
                .SendText("#partnerSecretKey", "WQ7kQvMGp5+9KT6BaGBL")
                .ClearText("#partnerId")
                .SendText("#partnerId", "58")
                .ClickOnElement("input[type=submit]");
            InitPage();
        }

        [Given(@"User clicks on ""(.*)"" on restore password page")]
        public void GivenUserClicksOnOnRegistrationPage(string buttonText)
        {
            WaitElementIsVisibleByCss(resendCodeButton, 35);
            _context.Grid.ClickByText(buttonText, "", ".");
            WaitPreloaderFinish(PreloaderGrid);
        }


        [Then(@"User clears confirmation code field")]
        public void ThenUserClearsPasswordField()
        {
            _context.Grid.ClearText(confirmationCodeLocator);
        }


        [Given(@"User goes to SignIn page")]
        [Given(@"User goes to Account page")]
        public void GoToSignIn()
        {
            DriverManager.GetWebDriver().Navigate().GoToUrl(TestConfiguration.Current.MyUrl);
            _context.Grid = new DataGridComponent(SearchElementByCss(".panel"));
        }

        [Then(@"User choose Business Account")]
        public void ThenUserChooseBusinessAccount()
        {
            _context.Grid.ClickByText(RegistrationBtn + Disabled);
        }

       
        [Then(@"Checkbox ""(.*)"" is unchecked")]
        public void ThenPromoCodeFieldIsEmpty(string checkboxText)
        {
            Assert.False(GetCheckbox(checkboxText).Selected,
                "Promocode checkbox should be unchecked");

            WaitCssElementIsNotPresence(".promo-bar");
        }

        [Then(@"Checkbox ""(.*)"" is checked")]
        public void ThenPromoCodeFieldIsFilled(string checkboxText)
        {
            Assert.True(GetCheckbox(checkboxText).Selected,
                "Promocode checkbox should be checked");
        }

        public IWebElement GetCheckbox(string checkboxText)
        {
            return _context.Grid.FindElementByText(checkboxText, "input");
        }

        [Then(@"(.*) field contains ID of created link")]
        public void ThenPromoCodeFieldIsFilledByCreatedLink(string checkboxText)
        {
            GetCheckbox(checkboxText).GetAttribute("value").Should().Be(_context.InviteLink);
        }



        [Given(@"User SIGNUP ""(.*)"" with (email|phone) (.*)")]
        public void GivenUserSignUPByPhone(string by, string type, string contact)
        {
            _context.StartDate = DateTime.UtcNow.AddSeconds(-5);

            InitPage();

            switch (by)
            {
                case "по номеру телефона":
                    _context.Grid.ClickByText(by);
                    GoToRegistrationForm(".phoneField", _context.PhoneNumber = contact);
                    break;
                case "по e-mail":
                    _context.Grid.ClickByText(by);
                    GoToRegistrationForm(Login, _context.Email = contact);
                    break;
            }

        }


        private void GoToRegistrationForm(string field, string text)
        {

            _context.Grid
                .SendText(field, text)
                .ClickOnElement(RegistrationBtn + NotDisabled);

            WaitPreloader(RegistrationView + PreloaderMain);
            _context.Grid = new DataGridComponent(SearchElementByCss(RegistrationView));
        }

   

        [Given(@"User fills ConfirmationCode to bind the phone")]
        [Given(@"User fills ConfirmationCode for restoring password")]
        public void GivenUserFillsConfirmationCode()
        {
            _context.Grid.SendText(confirmationCodeLocator, _context.VerificationCode);
        }

        [Then(@"Validating message ""(.*)"" appears")]
        public void ThenValidatingMessageAppears(string errMessage)
        {
            WaitPreloader(RegistrationView + PreloaderMain);
            _context.Grid.WaitElementWithText(".panel:not([class~='ng-hide']) small.error.ng-scope", errMessage);
        }

   



    }
}