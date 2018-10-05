using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.CardAndAccounts
{
    /// <summary>
    /// UI steps for refilling ewallet from BankCard (FirstData provider)
    /// </summary>
    [Binding]
    class SecureCodeSteps
    {
        public static string PasswordLocator = "input[type=password]";
        public static string SubmitForm = "input[name=submit]";

        [Then(@"User proceed payment on MasterCard side with entering secure code")]
        public void ThenRedirectingToPayPal()
        {
            // hint - is the securecode
            SearchElementByCss(PasswordLocator).SendKeys("hint");
            SearchElementByCss(SubmitForm).Click();
        }


    }
}