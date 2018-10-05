using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Fragments;
using ePayments.Tests.Web.Pages;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Linq;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Биндинги степов для работы с StatementPage
    /// </summary>
    [Binding]
    public class StatementsSteps
    {
        private readonly Context _context;
        private string statementListLocator = ".accordion";
        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public StatementsSteps(Context context)
        {
            _context = context;
        }
        


        [Given(@"User see transactions list contains:")]
        public void GivenUserSeeTransactionsListContains(List<UITransactionsList> expectedTransactions)
        {
            TransactionsListFragment
                .CheckLastTransactions(
                    ReplaceTable(expectedTransactions, _context.Rate, _context.Amount,null,null,null,_context.Fee));
            CommonComponentSteps.MakeScreenshot();
        }


        public long GetPurseTransactionIdByDestinationAndDirection(string UserId, PurseTransactionDestination destinationId, string direction)
        {
            return new DataBaseSteps(_context)
                .GetPurseTransactionsByUserId(UserId)
                .Where(it => (it.DestinationId == destinationId) && (it.Direction.Equals(direction)))
                .Single().PurseTransactionId;
        }


        [Given(@"User see statement info for the UserId=(.*) where DestinationId='(.*)' row № (.*) direction='(in|out)' without invoice:")]
        public void GivenUserSeeExpandedTransactionInfoWithDestinationNoInvoice(string UserId, PurseTransactionDestination destinationId, int row, string direction, List<UITable> expectedTransactions)
        {
            _context.PurseTransactionId = GetPurseTransactionIdByDestinationAndDirection(UserId, destinationId, direction);
            CheckStatement( row, expectedTransactions);
        }




        [Given(@"User see statement info for the UserId=(.*) where DestinationId='(.*)' row № (.*) direction='(in|out)':")]
        public void GivenUserSeeExpandedTransactionInfoWithDestination(string UserId, PurseTransactionDestination destinationId, int row, string direction, List<UITable> expectedTransactions)
        {
            var lastInvoice = new DataBaseSteps(_context).GetLastInvoiceByUserId(Guid.Parse(UserId));

            _context.InvoiceId = lastInvoice.InvoiceId;
            _context.ExternalTransactionId = lastInvoice.ExternalTransaction;
            _context.PurseTransactionId = GetPurseTransactionIdByDestinationAndDirection(UserId, destinationId, direction);

            CheckStatement(row, expectedTransactions);
        }

        [Given(@"User see statement info for production user where DestinationId='(.*)' row № (.*) direction='(in|out)':")]
        public void GivenUserSeeExpandedTransactionInfoWithDestination( PurseTransactionDestination destinationId, int row, string direction, List<UITable> expectedTransactions)
        {
            //Удаляем из ожидаемой таблицы строку с Датой., т.к. проверяется ниже
            expectedTransactions.RemoveAll(it => it.Column1.Equals("Транзакция №"));

            CheckStatement(row, expectedTransactions);

        }

        public void CheckStatement(int row, List<UITable> expectedTransactions)
        {
            //Удаляем из ожидаемой таблицы строку с Датой., т.к. проверяется ниже
            expectedTransactions.RemoveAll(it => it.Column1.Equals("Дата"));

            //Клик по номеру операции сверху.
            _context.Grid.FindElement(statementListLocator).FindElements(By.CssSelector("ul"))[row].Click();

            //Проверка ожидаемой/фактической таблиц
            TableFragment.CheckTablesWithOrder(_context.Grid, statementListLocator,
                ReplaceTable(expectedTransactions, _context.Rate, _context.Amount, _context.PurseTransactionId, _context.InvoiceId, _context.ExternalTransactionId, null, _context.Email ?? _context.PhoneNumber), row);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User see statement info for ProxyPANCode='(.*)' with last operation row № (.*):")]
        public void ExpandedTransactionInfoCardOperation(string proxypancode, int row,  List<UITable> expectedTransactions)
        {
            expectedTransactions[1].Column2 = new DataBaseSteps(_context).GetEhiLogByToken(proxypancode).Last().Txn_ID.ToString();

            CheckStatement(row, expectedTransactions);
        }
    }
}