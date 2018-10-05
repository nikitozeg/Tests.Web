namespace ePayments.Tests.Web.Data
{
    public class UIAvailableForPaymentTable
    {
        /// <summary>
        ///UI Partner Links Table
        /// </summary>

        public string LinkNames { get; set; }
        public int Transitions { get; set; }
        public int Registrations { get; set; }
        public decimal ForPayment { get; set; }
        public decimal Processing { get; set; }
        public decimal Cancelled { get; set; }

        public decimal Completed { get; set; }

            
    }
}