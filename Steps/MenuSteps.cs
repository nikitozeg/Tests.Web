using System.Collections.Generic;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Data.UITables;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using OpenQA.Selenium;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;
using static ePayments.Tests.Web.Constants.Locators;

namespace ePayments.Tests.Web.Steps
{/// <summary>
/// Биндинги степов для работы с меню
/// </summary>
    [Binding]
    public class MenuSteps
    {
        IWebElement _paymentForm;
        private readonly Context _context;
        private IEnumerable<UIAvailableForPaymentTable> firstLevelReffererPaymentTable;
        private EWalletSection memoEWalletValues;
        private EPACardsSection memoEPACardsSection;
        private string affiliateProgramLocator="a[href*='#/affiliate_program']";
        private string epaCardsLocator= ".sidebar-nav-item.card-order";
        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public MenuSteps(Context context)
        {
            _context = context;
        }


        [Then(@"User order (usd|eur) card")]
        public void ThenUserOrderUSDCard(string currency)
        {
            _context.Grid = new MenuPanel().ClickOnOrderCard(currency);
            CommonComponentSteps.MakeScreenshot();
        }


        [Then(@"User clicks on CardAndAccounts")]
        public void ThenUserClicksOnCardAndAccounts()
        {
            _context.Grid = new MenuPanel().ClickOnCardsAndAccounts();

        }

        [Then(@"User clicks on (.*) on Menu")]
        public void ThenUserClicksOnAccountVerification(string text)
        {
            _context.Grid = new MenuPanel().ClickOnAccountVerification(text);

        }

        [Then(@"EPA card block contains (.*)")]
        public void CheckCardStatus(string status)
        {
            WaitCssElementContainsText(SearchElementByCss(Sidebar), ".sidebar-nav-item.card-order", status);
        }

        [Then(@"User clicks '(.*)' on Menu")]
        public void ClickByTextOnMenu(string text)
        {
           new MenuPanel().ClickOn(text);
        }

        [Then(@"Memorize eWallet section")]
        public void MemorizeEWalletSection()
        {
            memoEWalletValues=new MenuPanel().GetEwalletTable(); 
        }


        [Then(@"eWallet updated sections are:")]
        public void ThenEWalletSectionsAre(EWalletSection updEWalletSection)
        {
            memoEWalletValues.USD += updEWalletSection.USD;
            memoEWalletValues.EUR += updEWalletSection.EUR;
            memoEWalletValues.RUB += updEWalletSection.RUB;

            new MenuPanel().GetEwalletTable()
                .ShouldBeEquivalentTo(memoEWalletValues, options => options.WithStrictOrdering(),
                $"EWallet section не соответствуют ожидаемым");
        }


        [Then(@"eWallet updated USD section is:")]
        public void ThenEWalletUSDSectionUpdatedIs(EWalletSection updEWalletSection)
        {
            memoEWalletValues.USD += updEWalletSection.USD;

            new MenuPanel().GetEwalletTable()
                .ShouldBeEquivalentTo(memoEWalletValues, options => options.Including(ewallet=> ewallet.USD),
                    $"EWallet USD section не соответствуют ожидаемым");
        }


        [Then(@"Memorize EPACards section")]
        public void MemorizeEPACardsSection()
        {
            memoEPACardsSection = new MenuPanel().GetEPACardsTable();
        }

        [Then(@"EPA cards updated sections are:")]
        public void ThenEPACardsSectionUpdated(EPACardsSection updEPACardsSection)
        {
            memoEPACardsSection.USD += updEPACardsSection.USD;
            memoEPACardsSection.EUR += updEPACardsSection.EUR;

            new MenuPanel().GetEPACardsTable()
                .ShouldBeEquivalentTo(memoEPACardsSection, options => options.WithStrictOrdering(),
                    $"EPA cards section не соответствуют ожидаемым");
        }


        [Then(@"No EPA cards section in menu")]
        public void NoEpaCardsBlockMenu()
        {
            new DataGridComponent(SearchElementByCss(Sidebar)).FindElements(epaCardsLocator).Should().BeEmpty("KYC1 should not have EPA cards");
        }


        [Then(@"No Affiliate Program section in menu")]
        public void NoAffiliateProgramMenu()
        {
            new DataGridComponent(SearchElementByCss(Sidebar)).FindElements(affiliateProgramLocator).Should().BeEmpty("KYC1 should not have Affiliate Program menu");
        }

    }
}