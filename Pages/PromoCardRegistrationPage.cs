using ePayments.Tests.Web.WebDriver;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;
using static ePayments.Tests.Web.Constants.Locators;

namespace ePayments.Tests.Web.Pages
{
    /// <summary>
    /// Support page
    /// </summary>
    public class PromoCardRegistrationPage
    {
        /// <summary>
        /// Find and return "PromoCardRegPage" form
        /// </summary>
        public static DataGridComponent FindCardDetailsForm()
        {
        
            return new DataGridComponent(SearchElementByCss(CardDetailsForm));
        }

        /// <summary>
        /// Find and return "Create Account" form
        /// </summary>
        public static DataGridComponent FindCreateAccountForm()
        {

            return new DataGridComponent(SearchElementByCss(CreateAccountForm));
        }

        /// <summary>
        /// Find and return "Personal Details" form
        /// </summary>
        public static DataGridComponent FindPersonalDetailsForm()
        {

            return new DataGridComponent(SearchElementByCss(PersonalDetailsForm));
        }

        /// <summary>
        /// Find and return "Activation Details" form
        /// </summary>
        public static DataGridComponent FindActivationDetailsForm()
        {

            return new DataGridComponent(SearchElementByCss(ActivationDetailsForm));
        }

        /// <summary>
        /// Find and return "Success registration" form
        /// </summary>
        public static DataGridComponent FindSuccessRegistrationForm()
        {

            return new DataGridComponent(SearchElementByCss(SuccessRegistrationForm));
        }

    }
}