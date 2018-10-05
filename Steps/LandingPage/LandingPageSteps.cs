using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.WebDriver;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.AffiliateProgram
{
    /// <summary>
    /// Landing page steps 
    /// </summary>
    [Binding]
    class LandingPageSteps
    {
        private readonly Context _context;
        private string loginLocator = "input[name='username']";
        private string accountDropdown = ".dropdown-content form";
        private string errorMessageLocator = " [state=login] small.error";
        private string landingViewLocator = ".x-main";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public LandingPageSteps(Context context)
        {
            _context = context;
        }

 
        [Given(@"User clicks on ""(.*)"" on Landing Page")]
        public void GivenUserClicksOn(string text)
        {
            WaitElementIsVisibleByXPath($"//header//*[contains(text()[normalize-space()],'{text}')]");
            _context.Grid = new DataGridComponent(SearchElementByCss("header .container"))
                .ClickByText(text, "", ".");
            _context.Grid = new DataGridComponent(SearchElementByCss(".panel"));
        }

        [Given(@"User goes to Landing Page")]
        public void GoToLandingPage()
        {
            DriverManager.GetWebDriver().Navigate().GoToUrl(TestConfiguration.Current.LandingPage);
        }

        [Given(@"User open referral's link ""(.*)""")]
        public void GivenUserGoesByReferralLink(string link)
        {
            DriverManager.GetWebDriver().Navigate().GoToUrl(link);
        }

        [Given(@"User open link ""(.*)""")]
        [Given(@"User open partner's link ""(.*)""")]
        public void GivenUserGoesTo(string link)
        {
            DriverManager.GetWebDriver().Navigate().GoToUrl(link);
        }

        [Given(@"User fills Login ""(.*)"" on Landing Page")]
        public void GivenUserFillsLoginOnLandingPage(string login)
        {
            _context.Grid.SendText(loginLocator, login);
        }

        [Given(@"User fills Password ""(.*)"" on Landing Page")]
        public void GivenUserFillsPasswordOnLandingPage(string pwd)
        {
            WaitElementIsVisibleByCss(".dropdown input[type='password']");
            _context.Grid.SendText(Password, pwd);
        }


        [Given(@"User gets ""(.*)"" message on Landing SignIn form")]
        public void GivenUserGetsMessageOnLandingSignForm(string text)
        {
            WaitElementIsVisibleByCss("#login-container-error");
            WaitCssElementContainsText("#login-container-error", text);
        }


        [Given(@"User gets ""(.*)"" message")]
        public void GivenUserGetsMessage(string text)
        {
            WaitElementIsVisibleByCss(accountDropdown + errorMessageLocator);
            WaitCssElementContainsText(accountDropdown + errorMessageLocator, text);
        }


        [Given(@"User clears password and login fields")]
        public void GivenUserClearsPasswordField()
        {
            _context.Grid
                .ClearText(loginLocator)
                .ClearText(Password);
        }
    }
}