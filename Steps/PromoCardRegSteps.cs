using ePayments.Tests.Helpers;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using OpenQA.Selenium;
using System.Linq;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Promo card registering steps
    /// </summary>
    [Binding]
    public class PromoCardRegSteps
    {
        private readonly Context _context;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public PromoCardRegSteps(Context context)
        {
            _context = context;
        }

        [Given(@"User fills Phone number")]
        public void GivenUserFillsPhone()
        {
            _context.Grid.SendText(PhoneNumber, _context.PhoneNumber = DataBuilderHelper.GenerateMobilePhone());
        }


        [Given(@"User fills VerificationCode")]
        public void GivenUserFillsVerificationCode()
        {
                _context.Grid.SendText(ConfirmCodeInput, _context.VerificationCode);
        }

        [Given(@"User fills Personal Details:")]
        public void GivenUserFillsPersonalDetails(UIUserPersonalDetails table)
        {
            _context.Grid = PromoCardRegistrationPage.FindPersonalDetailsForm();
            _context.Grid
                .SendText(FirstName, table.FirstName)
                .SendText(LastName, table.LastName)
                .SendText(DOB, DataBuilderHelper.GenerateDob())
                .SendText(Email, _context.Email=DataBuilderHelper.GenerateEmail());

            SearchElementByCss(Citizenship)
                .FindElements(By.CssSelector("option"))
                .SingleOrDefault(it => it.Text.Contains(table.Country)).Click();

        }


        [Given(@"User fills Activation Details:")]
        public void GivenUserActivationDetails(Table table)
        {
            _context.Grid = PromoCardRegistrationPage.FindActivationDetailsForm();
            var set = table.CreateDynamicSet().ToList();


            SearchElementByCss(Country)
                .FindElements(By.CssSelector("option"))
                .SingleOrDefault(it => it.Text.Contains(set[0].Country)).Click();

            _context.Grid
                .SendText(State, set[0].State)
                .SendText(City, set[0].City)
                .SendText(Index, set[0].Index.ToString())
                .SendText(Address, set[0].Address)
                .SendText(SecretName, set[0].SecretName)
                .SendText(SecretDate, set[0].SecretDate.ToString())
                .SendText(SecretPlace, set[0].SecretPlace)
                .SendText(SecretCode, set[0].SecretCode.ToString());
            CommonComponentSteps.MakeScreenshot();
        }

        [Then(@"Text message ""(.*)"" appears")]
        public void ThenUserGetsMessage(string msg)
        {
            _context.Grid = PromoCardRegistrationPage.FindSuccessRegistrationForm();
            _context.Grid.WaitElementWithText(SuccessRegistrationForm + SuccessMessage, msg);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User fills password ""(.*)""")]
        public void GivenUserFillsPassword(string password)
        {
            _context.Grid = PromoCardRegistrationPage.FindCreateAccountForm();

            var passwordFields = _context.Grid.FindElements(Password);

            //Type password
            passwordFields.First().SendKeys(password);
            
            //Repeat password
            passwordFields.Last().SendKeys(password);
        }

    }
}