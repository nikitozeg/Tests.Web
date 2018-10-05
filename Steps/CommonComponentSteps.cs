using ePayments.Tests.Log;
using ePayments.Tests.Services;
using ePayments.Tests.TestRail;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Fragments;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using ePayments.Tests.ApiClient.EpaymentsApiClient.Utils;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;
using DataGridComponent = ePayments.Tests.Web.WebDriver.DataGridComponent;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Steps with no relation to specific forms / elements (in other words - general steps)
    /// </summary>
    [Binding]
    public class CommonComponentSteps
    {
        private readonly Context _context;
        public static List<string> screenshotList = new List<string>();
        private static HttpClient httpClient = HttpClientUtils.CreateHttpClient(null);
        private  string toolDeployNumber;

        private string selectAllNotificationRing = ".notice-header input";
        private string deleteNotificationRing = ".notice-header a[ng-click*='delete']";
        private string listNotificationRing = ".top-nav .dropdown-content";
        private string titleNotificationRing = "a .title";
        private string countNotificationRing = ".top-nav .count";
        private string EditButton = ".svg-icon-pencil";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public CommonComponentSteps(Context context)
        {
            _context = context;
        }

        private string ModalWindow = ".reveal-modal.open";
        private string ModalWindowUnverifiedUser = ".home-modal";

        string _toolPath = Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory, @"Tools"));


        [Then(@"User clicks on notification ring with count='(.*)' and see text '(.*)'")]
        public void ThenUserClicksOnNotificationRingWithCount(string notificationCount, string title)
        {
            IWebElement notificationRing = SearchElementByCss(countNotificationRing);
            notificationRing.Text.Should().Be(notificationCount);
            notificationRing.Click();
            WaitElementIsVisibleByCss(titleNotificationRing);
            SearchElementByCss(titleNotificationRing).Text.Should().Be(title);


        }

        [Then(@"User delete all notification ring and see text '(.*)'")]
        public void ThenUserDeleteAllNotificationRing(string text)
        {
            SearchElementByCss(selectAllNotificationRing).Click();
            //	sleep because of : EPA-7078
            Thread.Sleep(2000);
            SearchElementByCss(selectAllNotificationRing).Click();
            //EPA-7078
            SearchElementByCss(selectAllNotificationRing).Click();
            SearchElementByCss(deleteNotificationRing).Click();
            WaitCssElementContainsText(listNotificationRing, text);
        }



        [Then(@"Message ""(.*)"" appears on ""(.*)"" view")]
        public void ThenMessageAppearsOnView(string message, string location)
        {
            switch (location)
            {
                case "Служба поддержки":
                    _context.Grid.WaitElementWithText(SupportTitle, message);
                    break;

                default:
                    throw new Exception("No any case -branch for " + location);
            }
        }


        

        [Then(@"Redirected to (.*)")]
        public void ThenRedirectedTo(string url)
        {
            DriverManager.GetWebDriver().Url.Should().Be(TestConfiguration.Current.MyUrl + url, "Wrong URL");
        }

        [Given(@"User lands on ""(Card Registration)""")]
        public void GivenUserLandsOn(string location)
        {
            switch (location)
            {
                case "Card Registration":
                    DriverManager.GetWebDriver().Navigate()
                        .GoToUrl(TestConfiguration.Current.LandingPage + "/card_registration.html");
                    CaptchaAppears();
                    _context.Grid = PromoCardRegistrationPage.FindCardDetailsForm();
                    break;
                default:
                    throw new Exception("No any case -branch for " + location);
            }
        }

        [Then(@"User fills invalid FullPAN '(.*)'")]
        public void FillInvalidFullPAN(string fullpan)
        {
            _context.FullPAN = fullpan;
            FillFullPAN();
        }

        [Then(@"User fills FullPAN")]
        public void FillFullPAN()
        {
            WaitElementIsVisibleByCss($"{PANInputSection}1");

            IEnumerable<string> a = Enumerable.Range(0, _context.FullPAN.Length / 4)
                .Select(i => _context.FullPAN.Substring(i * 4, 4));

            _context.Grid.ClearText($"{PANInputSection}1")
                .SendText($"{PANInputSection}1", a.ElementAt(0))
                .SendText($"{PANInputSection}2", a.ElementAt(1))
                .SendText($"{PANInputSection}3", a.ElementAt(2))
                .SendText($"{PANInputSection}4", a.ElementAt(3));
            MakeScreenshot();
        }

        [Then(@"User refresh the page")]
        public void ThenUserRefreshThePage()
        {
            DriverManager.GetWebDriver().Navigate().Refresh();
            WaitPreloaderFinish(Preloader);
        }

        [Then(@"Redirecting to account page")]
        public DataGridComponent Init()
        {
            return _context.Grid = MultiFormComponent.FindUIView();
        }


        [When(@"User download and executes ""(.*)""")]
        public void WhenUserDownloadAndExecutes(string toolName)
        {
            var loadDir = "/Sandbox/ePayments." + toolName + "/";

            var ftpLoader = new FTPDownloadService(TestConfiguration.Current.FtpUrl, _toolPath);
            toolDeployNumber = ftpLoader.GetLastDirectory(loadDir);

            if(!Directory.Exists(_toolPath + loadDir + toolDeployNumber))
                ftpLoader.LoadFtpFiles(loadDir + toolDeployNumber);

            WhenUserExecutes(toolName );
        }

        [When(@"User executes ""(.*)""")]
        public void WhenUserExecutes(string toolName)
        {
            var dailyServiceExePath =
                Path.GetFullPath(Path.Combine(_toolPath,
                    @"Sandbox\ePayments." + toolName + "\\"+ toolDeployNumber + "\\" + "ePayments." + toolName + ".exe"));

            Process process = Process.Start(dailyServiceExePath);
            Process tempProc = Process.GetProcessById(process.Id);
            tempProc.WaitForExit();
        }

        [Given(@"User clicks on ""(.*)"" in ""(Служба поддержки)"" grid")]
        public void GivenUserClicksOnInGrid(string value, string grid)
        {
            SearchElementByTextXpath(grid).Click();
            SearchElementByTextXpath(value).Click();
            WaitPreloaderFinish(Preloader);
            WaitPreloaderFinish(PreloaderGrid);

            switch (grid)
            {
                
                case "Служба поддержки":
                    _context.Grid = SupportPage.FindTicketsGrid();
                    break;
                default:
                    throw new Exception("No any case -branch for " + grid);
            }
        }


        [Given(@"Captcha submitted")]
        public void ReCaptchaAppears()
        {
            DriverManager.GetWebDriver().SwitchTo().Frame(SearchElementByCss(RecaptchaFrame));
            SearchElementByCss(RecaptchaButton).Click();
            WaitElementIsVisibleByCss(RecaptchaChecked);
            DriverManager.GetWebDriver().SwitchTo().DefaultContent();
        }

        [Given(@"Captcha appears")]
        public void CaptchaIsVisible()
        {
            CaptchaAppears();
        }

        [Given(@"Captcha appears on SignIn Page")]
        [Given(@"Captcha appears on Landing Page")]
        public void GivenCaptchaAppearsOnLandingPage()
        {
            WaitElementIsVisibleByCss(RecaptchaFrame);
        }


        [Given(@"User clicks Submit")]
        public void GivenUserClicksOnSubmit()
        {
            _context.Grid.ClickOnElement(InputSubmit);
        }

        [Given(@"Set StartTime for DB search")]
        public void GivenSetStartTimeForDBSearch()
        {
            _context.StartDate = DateTime.UtcNow;
            TestLogger.Message($"DB start-search time = {_context.StartDate}");
        }

        [Then(@"Wait Ws_CreateCard from GPS")]
        [Then(@"Wait because of different server time")]
        [Then(@"Wait for transactions loading")]
        [Then(@"EPA-6393")]
        public void ThenWaitForTransactionsLoading()
        {
            Thread.Sleep(15000);
        }


        [Then(@"Modal window '(.*)' is opened")]
        public void ModalWindowOpened(string windowId)
        {
            WaitElementIsVisibleByCss($"#{windowId}");
            _context.Grid = new DataGridComponent(SearchElementByCss($"#{windowId}"));
            MakeScreenshot();
        }

        [Then(@"Click on (.*) on Modal Window")]
        public void ModalWindowClickOn(string text)
        {
            ClickOnModalWindow(ModalWindow, text);
        }

        [Then(@"Click on (.*) on Modal Window for unverified user")]
        public void ModalWindowClickOnForUnverified(string text)
        {
            ClickOnModalWindow(ModalWindowUnverifiedUser, text);
        }

        /// <summary>
        /// Метод кликающий на кнопку модального окна
        /// </summary>
        /// <param name="locator">Локатор Модального окна</param>
        /// <param name="text">Текст кнопки в модальном окне</param>
        public void ClickOnModalWindow(string locator, string text)
        {
            WaitElementIsVisibleByCss(locator);
            MakeScreenshot();

            new DataGridComponent(SearchElementByCss(locator)).ClickByText(text, "", ".");
            WaitElementIsInvisibleByCss(locator);
            WaitPreloaderFinish(Preloader);

            _context.Grid = new DataGridComponent(SearchElementByCss(Uiview));
        }

        [Given(@"User clicks on button ""(.*)""")]
        public void GivenUserClicksByText(string location)
        {
            _context.Grid.ClickByText(location, ParentNode + "button");
        }

        [Given(@"Button ""(.*)"" is Disabled")]
        public void GivenUserClicksOsn(string text)
        {   
            _context.Grid.ClickByText(text, "/parent::*[@disabled]", ".");
        }

        [Given(@"Button ""(.*)"" is Disabled on ticket form")]
        public void GivenUserClicksOnDisabledButton(string text)
        {
          WaitElementIsVisibleByXPath($".//*[contains(text()[normalize-space()],'{text}')][@disabled]");
        }

        [Then(@"Set select option to '(.*)'")]
        public void ThenSetSelectOptionTo(string option)
        {
            SelectFragment.SetOption(option);
        }

        [Then(@"User proceed payment by bank card")]
        public void ThenRedirectingToECOMMPAY()
        {
            new DataGridComponent(SearchElementByCss("#card_payment_form"))
                .SendTextByChars("#card_number", "5555555555554444")
                .SendText("#month", "12")
                .SendText("#year", "25")
                .SendText("#cardholder", "NIKITA IVANOV")
                .SendText("#cvv", "777")
                .ClickOnElement("input[type=submit]");
        }




        [Then(@"File ""(.*)"" uploaded")]
        public void ThenFileUploaded(string docName)
        {
            var path = Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory,
                @"..\..\Resources\" + docName));

            _context.Grid.FindElements(UploadBtn).ToList()
                .ForEach(it => it.SendKeys(path));

            WaitPreloader(".action-bar-form .multiform-preloader");

            MakeScreenshot();
        }


        [Then(@"File ""(.*)"" uploaded for verification")]
        public void ThenFileUploadedForVerification(string docName)
        {
            ThenFileUploaded(docName);
            WaitElementIsVisibleByXPath($"//*[normalize-space()='{docName}']");
            WaitCssElementIsNotPresence("[class='loader-spinner']");
        }


        [Given(@"User clicks on ""(.*)""")]
        public void GivenUserClicksOn(string text)
        {
            Thread.Sleep(1000);
            _context.Grid.ClickByText(text, "", ".");
        }

        [Given(@"Button ""(.*)"" is not exist")]
        public void TextIsNotPresenceOnPage(string text)
        {
            _context.Grid.TextIsNotPresence(text);
        }

        [Given(@"User clicks on edit")]
        public void GivenUserClicksOnEdit()
        {
            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();
            WaitElementIsVisibleByCss(EditButton);
            _context.Grid.FindElements(EditButton).Last().Click();
        }


        [Given(@"User clicks on save")]
        public void GivenUserClicksOnSave()
        {
            _context.Grid.ClickOnElement("[name='icon-save']");
        }

        [Then(@"User scrolls down")]
        public void ThenUserClicksOnPagedown()
        {
            SearchElementByCss(".page-index").SendKeys(Keys.PageDown);
        }


        [Given(@"User LogOut")]
        public void GivenUserLogOut()
        {
            DriverManager.GetWebDriver().FindElement(By.CssSelector("[ng-click='ctrl.logout()']")).Click();
            DriverManager.GetWebDriver().Manage().Cookies.DeleteAllCookies();
            _context.Grid = new DataGridComponent(SearchElementByCss(RegistrationView));
        }

        [Then(@"User clicks on Close")]
        public void CloseFieldSet()
        {
            _context.Grid.FindElements(".button.circle.white").Last().Click();
        }

        [Then(@"User clicks on ADD")]
        public void GivenUserClicksOnAdd()
        {
            _context.Grid.ClickOnElement(Icons);
        }

        [Given(@"User see Account Page")]
        public void GivenUserSeeAccountPage()
        {
            WaitElementIsVisibleByCss(".accordion li");
            new MenuPanel().Init();
            _context.Grid = new DataGridComponent(SearchElementByCss(Uiview));
        }

        [Given(@"User see Account Page for new user")]
        public void GivenUserSeeAccountPageNewUser()
        {
            new MenuPanel().Init();
            _context.Grid = new DataGridComponent(SearchElementByCss(Uiview));
        }

        [Then(@"User receive Cookie ""(.*)""")]
        public ICookieJar ThenUserReceiveCookie(string cookieName)
        {
            _context.Cookies = DriverManager.GetWebDriver().Manage().Cookies;


            if (_context.Cookies.GetCookieNamed(cookieName) == null)
            {
                Console.WriteLine("Cookie not received: " + cookieName);
                throw new InvalidDataException(cookieName + " doesn't exists");
            }

            if (String.IsNullOrWhiteSpace(_context.Cookies.GetCookieNamed(cookieName).Value))
            {
                Console.WriteLine("Cookie value is empty or null: " + cookieName);
            }

            return _context.Cookies;
        }


    



        [Then(@"User receive Cookie ""(.*)"" with value (.*)")]
        public void ThenUserReceiveCookieWithValue(string cookieName, string expectedValue)
        {
            var cookieValue = ThenUserReceiveCookie(cookieName).GetCookieNamed(cookieName).Value;

            Assert.True(cookieValue.Equals(expectedValue),
                "Expected" + expectedValue + Environment.NewLine + " Received:" + cookieValue);
        }

        [Then(@"Cookie ""(.*)"" is not received")]
        public ICookieJar ThenUserDoNotReceiveCookie(string cookieName)
        {
            _context.Cookies = DriverManager.GetWebDriver().Manage().Cookies;


            if (!(_context.Cookies.GetCookieNamed(cookieName) == null))
            {
                Console.WriteLine("Cookie shouldn't be received: " + cookieName);
                throw new InvalidDataException(cookieName + " exists");
            }

            return _context.Cookies;
        }

        [Given(@"User clicks on ""(.*)"" on alert message")]
        public void GivenUserClicksOnOnAlertMessage(string text)
        {
            SearchElementByTextXpath(text).Click();
        }

        [Then(@"Make screenshot")]
        public static void MakeScreenshotStep()
        {
            MakeScreenshot();
        }

        /// <summary>
        /// Asynchronous file uploading to cloud storage
        /// </summary>
        /// <param name="path">Directory name</param>
        /// <param name="screenshotName">screenshotName</param>
        /// <returns>Task</returns>
        public static async Task PutFileAsync(string path, string screenshotName)
        {
            FileStream stream = File.OpenRead(path + @"\" + screenshotName);
            byte[] fileBytes = new byte[stream.Length];

            stream.Read(fileBytes, 0, fileBytes.Length);
            stream.Close();

            await
                httpClient.PutAsync
                (
                    $@"{TestConfiguration.Current.ScreenshotsUrl}/{DateTime.UtcNow.ToString("dd.MM.yyyy")}/{screenshotName}",
                    new ByteArrayContent(fileBytes)
                );
        }


        public static string MakeScreenshot(string errorName = null, bool isBeginningMessage = false)
        {
            string screenshotName=null;

            if (TestRun.IsEnabled)
            {
                 screenshotName = errorName + TestContext.CurrentContext.Test.MethodName + "_" +
                                     DateTime.UtcNow.ToString("HH-mm-ss") + ".jpg";

                //Removing unvalid filename symbols
                screenshotName = screenshotName.Replace("/", "-").Replace(":", "").Replace("|", "").Replace("<", "")
                    .Replace(">", "").Replace("?","");

                
                string screenshotPath = @"C:\tools\UI_screenshots\" + DateTime.UtcNow.ToString("dd.MM.yyyy");

                if (!Directory.Exists(screenshotPath))
                {
                    Directory.CreateDirectory(screenshotPath);
                }

               ((ITakesScreenshot) DriverManager.GetWebDriver()).GetScreenshot().SaveAsFile(
                    screenshotPath + @"\" + screenshotName, ScreenshotImageFormat.Jpeg);


                TestLogger.Message(screenshotName, true, isBeginningMessage);
                PutFileAsync(screenshotPath, screenshotName);
                screenshotList.Add(screenshotName);
            }
            return screenshotName;

        }
    }
}