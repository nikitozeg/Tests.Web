using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using NUnit.Framework;
using OpenQA.Selenium;
using System.IO;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Биндинги степов для работы с VerificationPage
    /// </summary>
    [Binding]
    public class VerificationSteps
    {
        private readonly Context _context;
        private string next = " [ng-click='model.next()']";
        private string close = "[ng-click='model.exit()']";
        private string uploadedFile = ".file-list li .title";
        private string multiformPreloader = ".action-bar-form .multiform-preloader";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public VerificationSteps(Context context)
        {
            _context = context;
        }

        public DataGridComponent Init()
        {
            WaitPreloader(multiformPreloader);
            WaitPreloaderFinish(PreloaderGrid);
            return MultiFormComponent.FindMultiform();
        }


        public void UploadDocument(string documentName)
        {
            WaitPreloaderFinish(PreloaderGrid);

            _context.Grid
                .SendText(UploadBtn,
                    Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory,
                        @"..\..\Resources\" + documentName)));

            WaitElementIsVisibleByCss(uploadedFile);
            _context.Grid.FindElement(uploadedFile).Text.Equals(documentName);
            _context.Grid.ClickOnElement(next);

            WaitElementIsVisibleByCss(AlertBoxSuccess);
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"User confirms Identity")]
        public void ThenUserConfirmsIdentity(UIIdentityConfirmation table)
        {
            _context.Grid.ClickOnElement("[ng-hide*='Identity']");
            _context.Grid = Init();

            var persDetailsTable = _context.Grid.FindElement("table").Text;
            Assert.True(persDetailsTable.Contains(_context.PersDetails.FirstName));
            Assert.True(persDetailsTable.Contains(_context.PersDetails.LastName));

            _context.Grid
                .SendText(UISelectSearch, table.Citizenship)
                .ClickOnElement(UISelectSearch)
                .SelectUISearchOption(table.Citizenship);

            _context.Grid
                .SendText("[name='documentNumber']", table.DocumentNumber)
                .SendText("#docExpireAt", table.ValidUntil);

            UploadDocument(table.DocumentUpload);
            WaitPreloader(multiformPreloader);
            _context.Grid.ClickOnElement(close);
            CommonComponentSteps.MakeScreenshot();
            _context.Grid = Init();
        }


        [Then(@"User confirms Company details with document (.*)")]
        public void ThenUserConfirmsCompanyDetails(string image)
        {
            _context.Grid.ClickOnVisibleElement(LimitsAndMultiForm, " [class='row'] [ng-hide*='CompanyDocument']");
            _context.Grid = Init();

            var companyDetailsTable = _context.Grid.FindElement("table").Text;

            Assert.True(companyDetailsTable.Contains(_context.BusinessDetails.CompanyName));
            Assert.True(companyDetailsTable.Contains(_context.BusinessDetails.WebSite));
            Assert.True(companyDetailsTable.Contains(_context.BusinessDetails.Country));
            Assert.True(companyDetailsTable.Contains(_context.BusinessDetails.RegNumber.ToString()));
            Assert.True(companyDetailsTable.Contains(_context.BusinessDetails.TradingAddress));


            UploadDocument(image);
            _context.Grid.ClickOnElement(close);
        }


        [Then(@"User confirms Address ""(.*)"" with document (.*)")]
        public void ThenUserConfirmsAddress(string address, string image)
        {
            _context.Grid.ClickOnVisibleElement(LimitsAndMultiForm, " [ng-hide*='Addresses']");
            _context.Grid = Init();
            WaitPreloader(multiformPreloader);

            Assert.True(_context.Grid.FindElement("table td").Text.Contains(address));

            _context.Grid.ClickOnElement("[name='icon-pencil']");

            UploadDocument(image);
            WaitPreloader(multiformPreloader);

            _context.Grid.ClickOnElement(close);
            _context.Grid = Init();
        }

        [Then(@"User fill Financial activity questionnaire")]
        public void ThenUserFillFinancialActivityQuestionnaire()
        {

            Init().ClickOnElement("[ng-hide*='questionary']");

            Init().SendText("textarea", "Describe in detail the company's type of activity:")
                .ClickOnElement(next)
                .ClickOnVisibleElement(LimitsAndMultiForm, " [id='91']")
                .ClickOnElement(next)
                .ClickOnVisibleElement(LimitsAndMultiForm, " [id='96']")
                .ClickOnElement(next)
                .ClickOnVisibleElement(LimitsAndMultiForm, " [id='101']")
                .ClickOnElement(next);
            
            _context.Grid = Init();
        }


        [Then(@"User send verification request")]
        public void ThenUserSendVerificationRequest()
        {
            _context.Grid = Init();
            _context.Grid.ClickOnVisibleElement(LimitsAndMultiForm, " [ng-click*='sendVerificationRequest']");
        }
    }
}