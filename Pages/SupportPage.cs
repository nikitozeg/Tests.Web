using ePayments.Tests.Web.WebDriver;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Pages
{
    /// <summary>
    /// Support page
    /// </summary>
    public class SupportPage
    {
        /// <summary>
        /// Find and return "Support" UI View 
        /// </summary>
        public static DataGridComponent FindTicketsGrid()
        {
            return new DataGridComponent(SearchElementByCss(Uiview));
        }

        /// <summary>
        /// Find and return "Create ticket" form 
        /// </summary>
        public static DataGridComponent FindCreateTicketForm()
        {
            return new DataGridComponent(SearchElementByCss(SupportCreateTicketForm));
        }


        /// <summary>
        /// Find and return "Chat" form 
        /// </summary>
        public static DataGridComponent FindTicketChatForm()
        {
            return new DataGridComponent(SearchElementByCss(SupportChatTicketForm));
        }
    }
}