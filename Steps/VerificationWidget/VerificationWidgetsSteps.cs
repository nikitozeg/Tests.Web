using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Биндинги степов для работы виджетом верификации
    /// </summary>
    [Binding]
    public class VerificationWidgetsSteps
    {
        private readonly Context _context;
        private string widgetContent= ".widget-content";
        private string widgetChecklist= ".widget-checklist";
        private string widgetCurrentStepLocator= ".//section[not(contains(@class,'ng-hide'))]";
        private string widgetWindow= ".verification-initial";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public VerificationWidgetsSteps(Context context)
        {
            _context = context;
        }


        [Then(@"User clicks on '(.*)' on VerificationWidget")]
        public void ThenUserClicksOnVerificateAccount(string text)
        {
            WaitElementIsPresenceByCss(widgetContent);
            _context.Grid = new DataGridComponent(SearchElementByCss(Uiview))
                .ClickByText(text, "", ".");

             WaitElementIsVisibleByCss(widgetChecklist);
            _context.Grid = new DataGridComponent(SearchElementByCss(widgetContent));
        }

        [Then(@"Verification widget contains '(.*)'")]
        public void ThenFileUploaded(string text)
        {
            WaitCssElementContainsText(widgetContent, text);
        }

        [Then(@"Verification widget appears")]
        public void ThenFileUploaded()
        {
            WaitElementIsVisibleByCss(widgetWindow);
        }

        [Then(@"User clicks on '(.*)' on Verification Widget")]
        public void ThenUserSendVerificationRequest(string text)
        {
            _context.Grid.ClickByText(text, ")[last()]", "(.");
        }

        [Then(@"'(.*)' citizenship set to '(.*)'")]
        public void UISelectSet(string fieldName, string value)
        {
            new DataGridComponent(_context.Grid.FindElementByText(fieldName, "*[contains(@class,'ui-select-container')]"))
                .ClickOnElement(UISelectedInput)
                .SendText(UISelectSearch, value)
                .SelectUISearchOption(value);

        }

        [Given(@"User clicks on ""(.*)"" on verification widget")]
        public void GivenUserClicksOnVerificationWidget(string text)
        {
            _context.Grid.ClickByText(text, "", widgetCurrentStepLocator);
        }

    }
}