using ePayments.Tests.Web.Data;
using FluentAssertions;
using OpenQA.Selenium;
using System.Collections.Generic;
using System.Linq;

namespace ePayments.Tests.Web.Fragments
{
    using static WebDriver.DriverManagerHelper;

    static class TransactionsListFragment
    {
        public static List<UITransactionsList> GetTransactions()
        {
            var transList = SearchElementByCss(".accordion")
                .FindElements(By.CssSelector("ul"));

            List<UITransactionsList> list = new List<UITransactionsList>();

            foreach (var row in transList)
            {
                list.Add(new UITransactionsList
                {
                    Date = row.FindElement(By.CssSelector(".date")).Text.Replace("\r\n", "."),
                    Name = row.FindElement(By.CssSelector(".dscr")).Text,
                    Amount = row.FindElement(By.CssSelector(".transactions-list-sum")).Text
                });
            }
            return list;
        }


        public static void CheckLastTransactions(List<UITransactionsList> expectedTransactions)
        {
            //Waiting for at least one row appears
            WaitElementIsVisibleByCss(".accordion ul li");
            var actual=GetTransactions().Take(expectedTransactions.Count);
            actual.ShouldBeEquivalentTo(expectedTransactions,
                    $"Transactions List не соответствуют ожидаемым");
        }
    }
}