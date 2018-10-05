using ePayments.Tests.Web.Data.UITables;
using ePayments.Tests.Web.WebDriver;
using System;
using System.Linq;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Pages
{
    /// <summary>
    /// Menu Panel
    /// </summary>
    public class MenuPanel
    {
        /// <summary>
        /// Common MenuPanel
        /// </summary>
        private static DataGridComponent menu;
        public static string CardAccountsLocator = "[href='#/cards/']";
        public static string PurseIdLocator = ".title .right";
        public static string eWalletBlock = "[class='sidebar-nav-item']";
        public static string EPACardsBlock = ".sidebar-nav-item.card-order";
        public static string eWalletBalance = ".is-balance";
        public static string EPACardBlock = ".sidebar-nav-item.card-order";
        public static string AffiliateProgramLocator = "[href='#/affiliate_program']";
        public static string CardOrder = "[href='#/cards/order/";

        public MenuPanel()
        {
            menu = new DataGridComponent(SearchElementByCss(Sidebar));
        }

        public void ClickOn(string text)
        {
            menu.ClickByText(text,"",".");
            WaitPreloaderFinish(Preloader);
        }

        public void Init()
        {
            new DataGridComponent(menu.FindElement(eWalletBlock))
                .TextIsPresence("USD")
                .TextIsPresence("$")
                .TextIsPresence("EUR")
                .TextIsPresence("€")
                .TextIsPresence("RUB")
                .TextIsPresence("₽");

            new DataGridComponent(menu.FindElement(EPACardBlock))
                .TextIsPresence("USD")
                .TextIsPresence("EUR");
        }

        public EWalletSection GetEwalletTable()
        {
            var ewalletValues = new DataGridComponent(menu.FindElement(eWalletBlock))
                .FindElements(eWalletBalance).ToList()
                .Select(it => it.Text.Replace("$", "").Replace("€", "").Replace("₽", "").Replace(" ", ""));

            return new EWalletSection
            {
                USD = Decimal.Parse(ewalletValues.ToList()[0]),
                EUR = Decimal.Parse(ewalletValues.ToList()[1]),
                RUB = Decimal.Parse(ewalletValues.ToList()[2])
            };

        }

        public string GetPurseId()
        {
            return menu.FindElement(PurseIdLocator).Text;
        }

        public EPACardsSection GetEPACardsTable()
        {
            var epaCardsValues = new DataGridComponent(menu.FindElement(EPACardsBlock))
                .FindElements(eWalletBalance).ToList()
                .Select(it => it.Text.Replace("$", "").Replace("€", "").Replace("₽", "").Replace(" ", ""));

            return new EPACardsSection
            {
                USD = Decimal.Parse(epaCardsValues.ToList()[0]),
                //Check if EUR section exists
                EUR = Decimal.Parse(epaCardsValues.Count() > 1 ? epaCardsValues.ToList()[1] : "0"),
            };

        }

        public DataGridComponent ClickOnCardsAndAccounts()
        {
            menu.ClickOnElement(CardAccountsLocator);
            WaitPreloaderFinish(Preloader);

            return new DataGridComponent(SearchElementByCss(Uiview));
        }

        public DataGridComponent ClickOnAccountVerification(string text)
        {

            menu.TextIsNotPresence("USD")
                .TextIsNotPresence("EUR")
                .TextIsNotPresence("RUB")
                .ClickByText(text);
            WaitPreloaderFinish(Preloader);

            return new DataGridComponent(SearchElementByCss(Uiview));
        }

        public DataGridComponent ClickOnOrderCard(string currency)
        {
            string orderLocator = CardOrder + currency + "']";

            WaitElementIsClickable(orderLocator);
            menu.ClickOnElement(orderLocator);
            WaitPreloaderFinish(Preloader);

            return MultiFormComponent.FindLimitsAndMultiform();
        }

        public DataGridComponent ClickOnInvites()
        {
            menu.ClickOnElement(InvitesLocator);
            WaitCssElementIsNotPresence(Uiview + PreloaderMain);

            return new DataGridComponent(SearchElementByCss(Uiview));
        }

    


        public DataGridComponent ClickOnMenu(string menuName)
        {
            menu.ClickByText(menuName, "", ".");
            WaitPreloaderFinish(Preloader);
            return new DataGridComponent(SearchElementByCss(Uiview));
        }

      
    }
}