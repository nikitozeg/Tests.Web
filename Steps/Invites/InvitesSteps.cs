using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using System.Linq;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.AffiliateProgram
{
    /// <summary>
    /// Invites menu UI steps 
    /// </summary>
    [Binding]
    class InvitesSteps
    {
        private readonly Context _context;
        private string Invites = "[domain='model.invites']";
        private string href = " li a[href]";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public InvitesSteps(Context context)
        {
            _context = context;
        }


        [Then(@"User clicks on Invite")]
        public void ThenUserOrderUSDCard()
        {
            _context.Grid = new MenuPanel().ClickOnInvites();
            WaitCssElementIsNotPresence(Uiview + PreloaderMain);

        }

        [Then(@"User clicks on last created invite link")]
        public void ThenUserClicksOnCreatedInviteLink()
        {
            WaitCountOfCssElements(Invites+ href);

            _context.Grid = new DataGridComponent(SearchElementByCss(Invites));

            var lastCreatedLink = _context.Grid.FindElements(href).First().Text;
            _context.InviteLink = lastCreatedLink.Substring(lastCreatedLink.IndexOf("promo=") + "promo=".Length);

            _context.Grid.FindElements(href).First().Click();
        }



    }
}

