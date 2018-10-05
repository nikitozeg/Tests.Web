namespace ePayments.Tests.Web.Data
{
    /// <summary>
    ///epayments.com/#/transfer/masspayment
    /// </summary>
    public class UIInternalPaymentReceiverTable
    {
        public string Number { get; set; }

        public string Recipient { get; set; }
        public string Amount { get; set; }
        public string Fees { get; set; }
        public string Total { get; set; }
        public string Details { get; set; }
    }
}