using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.WebDriver;
using System;
using System.Linq;
using ePayments.Tests.Helpers;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    [Binding]
    public class SignInSteps
    {
        private readonly Context _context;
        private static String firstName = "[name=firstname]";
        private static String lastname = "[name=lastname]";
        private static String email = "input[name = email]";
        private static String phone = "input[name = phone]";
        private static String confirmationCode = "input[name=confirmationCode]";
        private static String LoginName = "input[name ='login']";
        private static String PanelLocator = ".panel";
        private string newPassword;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public SignInSteps(Context context)
        {
            _context = context;
        }

        private DataGridComponent initPage()
        {
            WaitElementIsPresenceByCss(".multiform-preloader[style='display: none;']");
            return _context.Grid = new DataGridComponent(SearchElementByCss(".panel:not([class~='ng-hide'])"));
        }

        [Given(@"User fills new password")]
        public void GivenUserFillsNewPassword()
        {
            newPassword = DataBuilderHelper.GenerateStringValue() + DataBuilderHelper.GetRandomDigits(1);
            WaitElementIsVisibleByCss(Password);
            initPage();
            var passwordFields = _context.Grid.FindElements(Password);
            passwordFields.First().SendKeys(newPassword);
            passwordFields.Last().SendKeys(newPassword);
        }

        [Given(@"User signin ""Epayments"" with ""(.*)"" restored password")]
        public void GivenUserLoginWithRestoredPwd(string login)
        {
            GivenUserLoginIs(login, newPassword);
        }

        [Given(@"User signin ""Epayments"" with ""(.*)"" password ""(.*)""")]
        public void GivenUserLoginIs(string login, string password)
        {
            _context.Email = login;
            initPage();

            _context.Grid = new DataGridComponent(SearchElementByCss(PanelLocator));
          

            TypeLogin(login);
            TypePwd(password);
            _context.Grid.ClickOnElement(LoginBtn);
        }

        [Given(@"User signin production ""Epayments"" with ""(.*)""")]
        public void GivenUserLoginProd(string login)
        {
            GivenUserLoginIs(login, Environment.GetEnvironmentVariable("sazykin"));
        }

        [Given(@"User type login (.*)")]
        public DataGridComponent TypeLogin(string login)
        {
            return initPage().SendText(LoginName, login);
        }


        [Then(@"User clears password login field")]
        public void GivenUserClearsPasswordField()
        {
            initPage().ClearText(LoginName);
        }


        private void TypePwd(string pwd)
        {
            _context.Grid.SendText(Password, pwd);
        }


        [Given(@"User gets ""(.*)"" message on SignIn form")]
        public void GivenUserGetsMessageOnSignInForm(string text)
        {
            WaitElementIsVisibleByCss(ErrorMsg);
            WaitCssElementContainsText(ErrorMsg, text);
        }

        [Given(@"User type password ""(.*)""")]
        public void GivenUserTypePwd(string password)
        {
            initPage();
            SearchElementByCss(Password).SendKeys(password);
        }
    }
}