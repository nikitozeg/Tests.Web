using ePayments.Tests.Web.WebDriver;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;
using static ePayments.Tests.Web.Constants.Locators;

namespace ePayments.Tests.Web.Pages
{
    /// <summary>
    /// MultiForm
    /// </summary>
    public class MultiFormComponent
    {
        private static string MultiformSection = ".action-bar-form-section";
        private static string WidgetContent = ".widget-content";
        /// <summary>
        /// Common MultiForm view
        /// </summary>
        public static DataGridComponent FindLimitsAndMultiform()
        {
            return new DataGridComponent(SearchElementByCss(LimitsAndMultiForm));
        }

        public static DataGridComponent FindUIView()
        {
            return new DataGridComponent(SearchElementByCss(Uiview));
        }

        public static DataGridComponent FindMultiformSection()
        {
            return new DataGridComponent(SearchElementByCss(MultiformSection));
        }

        public static DataGridComponent FindMultiform()
        {
            return new DataGridComponent(SearchElementByCss(".action-bar-form"));
        }

    }
}