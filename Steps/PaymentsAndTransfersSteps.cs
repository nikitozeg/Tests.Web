using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using OpenQA.Selenium;
using System;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Биндинги степов для формы перевода 
    /// </summary>
    [Binding]
    public class PaymentsAndTransfersSteps
    {
        IWebElement _paymentForm;
        private readonly Context _context;
  

        public PaymentsAndTransfersSteps(Context context)
        {
            _context = context;
        }

       
       

        [Given(@"User clicks on (.*) menu")]
        public DataGridComponent ChooseMenu(string menu)
        {
            return _context.Grid = new MenuPanel().ClickOnMenu(menu);
        }


        [When(@"User sets (fullpan|cardholder)? to (.*)")]
        public void WhenUserSetsFullpanTo(String destination, String text)
        {
            switch (destination)
            {
                case "fullpan":
                    _paymentForm.FindElement(By.CssSelector(CardFullpan)).SendKeys(text);
                    break;
                case "cardholder":
                    _paymentForm.FindElement(By.CssSelector(CardCardholder)).SendKeys(text);
                    break;
                default:
                    throw new Exception("No any case -branch for " + destination);
            }
        }

     
    }
}