using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.WebDriver;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;

namespace ePayments.Tests.Web.CatalogContext
{
    /// <summary>
    /// Represents shared data
    /// Context class for injecting to a binding class.
    /// </summary>
    public class Context
    {
        public UIUserPersonalDetails PersDetails { get; set; }
        public UIBusinessDetails BusinessDetails { get; set; }

        public Context()
        {
            PersDetails = new UIUserPersonalDetails();
            BusinessDetails = new UIBusinessDetails();
        }

        public DataGridComponent Grid { get; set; }
        public string FullPAN { get; set; }
        public string VerificationCode { get; set; }
        public string PhoneNumber { get; set; }

        public DateTime? StartDate { get; set; }
        public string Trans_link { get; set; }
        public string Token { get; set; }
        public long Auth_TXn_ID { get; set; }

        public Guid UserId { get; set; }
        public Guid? OperationGuid { get; set; }
        public string Email { get; set; }
        public string RegistrationLogin { get; set; }

        public string InviteLink { get; set; }
        public int CardId { get; set; }

        private string _userExternalCode;
        public string UserExternalCode
        {
            set => _userExternalCode = value;
            get => _userExternalCode ?? throw new Exception("UserExternalCode не заполнен");
        }
        public ICookieJar Cookies { get; set; }
        public Decimal Rate { get; set; } = 1.00M;

        private Decimal _amount;
        public Decimal Amount
        {
            set => _amount = value; 
            get => _amount != null ? _amount : throw new Exception("Amount не заполнен");
        }

        private Decimal _incomingAmount;
        public Decimal IncomingAmount
        {
            set => _incomingAmount = value;
            get => _incomingAmount != null ? _incomingAmount : throw new Exception("IncomingAmount не заполнен");
        }

        private Decimal _fee;
        public Decimal Fee
        {
            set => _fee = value;
            get => _fee != null ? _fee : throw new Exception("Fee не заполнен");
        }

        public List<long> TicketsIDList = new List<long>();
        public int InvoiceId { get; set; }
        
        /// <summary>
        /// Sanction Check table
        /// </summary>
        public long RequestId { get; set; }

        private long _purseTransactionId;
        public long PurseTransactionId
        {
            set => _purseTransactionId = value;
            get => _purseTransactionId != null ? _purseTransactionId : throw new Exception("PurseTransactionId не заполнен");
        }

        public string ExternalTransactionId { get; set; }
        

    }
}