using ePayments.Tests.Web.CatalogContext;
using FluentAssertions;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.CardAndAccounts
{
    /// <summary>
    /// UI steps for the first EPA card payment by PayPal
    /// </summary>
    [Binding]
    class PayPalSteps
    {
        public static string PaymentForm = "form[name=buyNowForm]";
        public static string Preloader = "#preloaderSpinner";
        public static string Amount = "#itemPrice";
        public static string SubmitForm = "input[type=submit]";
        public static string Email = "#email";
        public static string Password = "#password";
        public static string Next = "#btnNext";
        public static string SignIn = "#btnLogin";
        public static string ConfirmButtonTop = "#confirmButtonTop";
        public static string Receipt = ".receipt.basics";
       

        [Then(@"User proceed payment in PayPal with user (.*) password (.*)")]
        public void ThenRedirectingToPayPal(string user, string password)
        {
            WaitElementIsVisibleByCss(PaymentForm);
            WaitElementIsInvisibleByCss(Preloader);
            SearchElementByCss(Amount).GetAttribute("value").Should().Be("5.95","Paypal payment amount doesn't match with amount received from EPA");
            SearchElementByCss(SubmitForm).Click();

            SearchElementByCss(Email).SendKeys(user);
            SearchElementByCss(Next).Click();
            WaitElementIsVisibleByCss(Password);

            SearchElementByCss(Password).SendKeys(password);
            SearchElementByCss(SignIn).Click();
            WaitElementIsInvisibleByCss(Preloader);
            SearchElementByCss(ConfirmButtonTop).Click();

            WaitElementIsVisibleByCss(Receipt);
            WaitElementIsInvisibleByCss(Preloader);

            WaitElementWithTextByXpath("You paid $5.95 USD");

        }


    }
}