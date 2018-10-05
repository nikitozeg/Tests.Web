namespace ePayments.Tests.Web.Data
{
    /// <summary>
    ///Table for CardDetails
    /// </summary>
    /// 
    public class CardDetails
    {

        public string CardNumber { get; set; }
        public string CardExpireAt { get; set; }
        public string CVC { get; set; }
        public string CardHolder { get; set; }
    }
}