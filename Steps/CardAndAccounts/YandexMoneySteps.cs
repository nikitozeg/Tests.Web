using System;
using System.Linq;
using System.Text.RegularExpressions;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using OpenQA.Selenium;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.CardAndAccounts
{
    /// <summary>
    /// UI steps for the first EPA card payment by YandexMoney
    /// </summary>
    [Binding]
    class YandexMoneySteps
    {
        public static string paymentForm = ".island";
        public static string authLink = "[href*= 'authLink']";
        public static string login = "input[name=login]";
        public static string passwordLocator = "input[name=passwd]";
        public static string submit = "button[type=submit]";

        public static string confirm = "div[class*=island]> button";
        public static string smsinput = ".secure-auth__sms input[name=answer]";
        public static string smsGateInput = "#secret";
        public static string smsGateRefresh = "[data-icon=refresh]";
        public static string yandexMoneySmsLocator = "//*[contains(.,'YandexMoney')]";
        public static string lastSms = "(//a[contains(.,'YandexMoney')]/../..//li[contains(@id,'message')]/div[contains(@class,'ui-icon')]) [last()]";
       

        [Then(@"User proceed payment in YandexMoney with user (.*) password (.*)")]
        public void ThenRedirectingToYandexMoney(string user, string password)
        {
            WaitElementIsVisibleByCss(paymentForm);
            SearchElementByCss(authLink).Click();

            SearchElementByCss(login).SendKeys(user);
            SearchElementByCss(passwordLocator).SendKeys(password);
            SearchElementByCss(submit).Click();

            SearchElementByCss(confirm).Click();
            WaitElementIsVisibleByCss(smsinput);

            //Open new tab for SMS accessing
            IJavaScriptExecutor js = (IJavaScriptExecutor)DriverManager.GetWebDriver();
            string title = (string)js.ExecuteScript("window.open()");

            DriverManager.GetWebDriver().SwitchTo().Window(DriverManager.GetWebDriver().WindowHandles.Last());
            DriverManager.GetWebDriver().Navigate().GoToUrl(TestConfiguration.Current.SmsGate);
            SearchElementByCss(smsGateInput).SendKeys(TestConfiguration.Current.SmsGateSecretKey);
            SearchElementByCss(smsGateRefresh).Click();

            WaitElementIsVisibleByXPath(yandexMoneySmsLocator);
            SearchElementByTextXpath("YandexMoney").Click();
            var sms = SearchElementByXpath(lastSms).Text;


            DriverManager.GetWebDriver().SwitchTo().Window(DriverManager.GetWebDriver().WindowHandles.First());
           // WaitElementIsInvisibleByCss(Preloader);
            SearchElementByCss(smsinput).SendKeys(Regex.Match(sms, @"(\d+){4}").Value);
            SearchElementByCss(confirm).Click();


        }


    }
}