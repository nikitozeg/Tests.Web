using ePayments.Tests.Checkers.ExpectedObjects;
using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using System;
using System.Collections.Generic;
using System.Linq;
using ePayments.Tests.Checkers;
using TechTalk.SpecFlow;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Internal Payment Steps
    /// </summary>
    [Binding]
    public class InternalPaymentStep
    {
        private readonly Context _context;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public InternalPaymentStep(Context context)
        {
            _context = context;
        }

        [Given(@"Reset Email")]
        public void GivenResetEmail()
        {
            _context.Email = null;
        }

        [Given(@"Reset PhoneNumber")]
        public void GivenResetPhoneNumber()
        {
            _context.PhoneNumber = null;
        }


        /// <summary>
        /// Проверяльщик уведомлений по userid
        /// </summary>
        /// 
        [Then(@"User selects records in table 'Notification' for UserId=""(.*)"" internal payment")]
        public void ThenUserSelectsRecordsInTableInternalPayment(Guid UserId, List<ExpectedNotificationWithBody> expectedNotifications)
        {
            expectedNotifications.Select(x =>
            {
                x.Receiver = x.Receiver.Replace("**Receiver**", _context.Email ?? _context.PhoneNumber);
                return x;
            }).ToList();

            DataBaseSteps dbInstance = new DataBaseSteps(_context);

            dbInstance._notificationChecker = new NotificationChecker(_context.StartDate);
            dbInstance._notificationChecker.AddExpected(expectedNotifications.ToArray()).AssertAll(UserId);
        }




        [Then(@"'(.*)' set to (random|Email) when receiver specify his email")]
        public void FillWithReceiverEmail(string fieldName, string opt)
        {
            if (opt.Equals("random"))
                new MultiFormSteps(_context).FillRandomEmail(fieldName);

            if (opt.Equals("Email"))
                new MultiFormSteps(_context).FillWithEmail(fieldName, _context.Email);
        }


        [Then(@"'(.*)' set to (random|Phone) when receiver specify his phone")]
        public void FillWithReceiverPhone(string fieldName, string opt)
        { 
            if (opt.Equals("random"))
                new MultiFormSteps(_context).FillRandomPhone(fieldName);

            if (opt.Equals("Phone"))
                new MultiFormSteps(_context).FillWithPhone(fieldName, _context.PhoneNumber);
           
        }



        [Given(@"User see statement info for created user where DestinationId='(.*)' row № (.*) direction='(in)' internal payment:")]
        public void ExpandedTransactionInfoWithDestinationForCreatedUser(PurseTransactionDestination destinationId, int row, string direction, List<UITable> expectedTransactions)
        {
            var purseId = new MenuPanel().GetPurseId();

            expectedTransactions.Select(x =>
            {
                x.Column2 = x.Column2.Replace("**ReceiverPurse**", purseId);
                x.Column2 = x.Column2.Replace("Email", _context.Email);
                x.Column2 = x.Column2.Replace("Phone", _context.PhoneNumber);
                return x;
            }).ToList();

            _context.InvoiceId = new DataBaseSteps(_context).GetLastInvoiceByUserId(Guid.Parse(_context.UserId.ToString())).InvoiceId;

            _context.PurseTransactionId = new StatementsSteps(_context).GetPurseTransactionIdByDestinationAndDirection(_context.UserId.ToString(), destinationId, direction);

            new StatementsSteps(_context).CheckStatement(row,  expectedTransactions);
        }



        [Then(@"User selects last record in 'Invoices and InvoicePositions' where UserId=""(.*)"" internal payment:")]
        public void WhenUserSelectsInvoices(Guid UserId, IEnumerable<ExpectedInvoice> expectedList)
        {
            expectedList.Select(x =>
            {
                x.ReceiverIdentity = x.ReceiverIdentity.Replace("**Receiver**", _context.Email ?? _context.PhoneNumber);
                return x;
            }).ToList();

            new DataBaseSteps(_context).WhenUserSelectsInvoices(UserId, expectedList);
        }



    }
}