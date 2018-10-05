using System;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Fragments;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.CardAndAccounts
{
    /// <summary>
    /// UI steps for Merchant payment
    /// </summary>
    [Binding]
    class MerchantSteps
    {
        public string LoginForm = "form[action='/Merchant']";
        public string OrderId = "Yjinqhsxfv";
        public string MerchantPayForm = ".tabs.white";
        public string PartnerId = "#PartnerId";
        public string partner_secret = "#partner_secret";
        public string OrderIdLocator = "#OrderId";
        public string Amount = "#Amount";
        public string Currency = "#Currency";
        public string Details = "#Details";

        public string Submit = "input[type=submit]";
        public string ButtonSubmit = "button[type=submit]";
        public string Login = "#LoginModel_Login";
        public string Password = "#LoginModel_Password";

        public string Commit = "#commit";
        public string MerchantName = "#Invoice_MerchantName";
        public string InvoiceOrderId = "#Invoice_OrderId";
        public string TotalAmount = "[name='total-amount']";
        public string SuccessState = "[value='Успешно']";
        public string ConfirmationCodeLocator = "#confirmView";

        private readonly Context _context;

        public MerchantSteps(Context context)
        {
            _context = context;
        }

        [Then(@"User proceed payment in Merchant page with user (.*) password (.*) from (.*) with amount=(.*)")]
        public void ThenRedirectingToMerchantSteps(string user, string password, string paymentSource, string amount)
        {
            DriverManager.GetWebDriver().Navigate().GoToUrl(TestConfiguration.Current.MerchantUrl);

            //Заполнение формы мерчанта
            new DataGridComponent(SearchElementByCss(MerchantPayForm))
                .ClearText(PartnerId)
                .SendText(PartnerId, "58")
                .SendText(partner_secret, "WQ7kQvMGp5+9KT6BaGBL")
                .SendText(OrderIdLocator, OrderId)
                .ClearText(Amount)
                .SendText(Amount, amount)
                .SendText(Currency, "Usd")
                .SendText(Details, "this is details")
                .ClickOnElement(Submit);

            //Ожидание формы ввода логина пароля
            WaitElementIsVisibleByCss(LoginForm);

           new DataGridComponent(SearchElementByCss(LoginForm))
                .SendText(Login, user)
                .SendText(Password, password)
                .ClickByText("Войти", "", "");

            //Выбор способа оплаты - (кошелек/карта)
            SelectFragment.SetOptionByFieldName("Способ оплаты", "USD", $" [label *= '{paymentSource}']");

            _context.Grid = new DataGridComponent(SearchElementByCss(ConfirmationCodeLocator));
        }

        [Then(@"Check merchant quittance for amount=(.*)")]
        public void ThenCheckMerchantQuittance(string amount)
        {
        //Подтверждение операции
        SearchElementByCss(Commit).Click();
            WaitElementIsVisibleByCss(SuccessState);
            //Проверка квитанции
            SearchElementByCss(MerchantName).GetAttribute("value").Should().Be("Fix test grupe");
            SearchElementByCss(InvoiceOrderId).GetAttribute("value").Should().Be(OrderId);
            SearchElementByCss(TotalAmount).GetAttribute("value").Should().Be(amount);
            SearchElementByCss(ButtonSubmit).Click();
            SearchElementByCss(MerchantPayForm);
        }
    }
}