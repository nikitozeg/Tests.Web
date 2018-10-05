using System;

namespace ePayments.Tests.Web.Data
{
    /// <summary>
    ///epayments.com/#/transfer/mass_payment_to_webmoney
    /// </summary>
    public class UIWMPaymentTable
    {
        public string Number { get; set; }
        public string Recipient { get; set; }
        public string OutgoingAmount { get; set; }
        public string Fees { get; set; }
        public string IncomingAmount { get; set; }
        public string Total { get; set; }
        public string Button { get; set; }
    }
}