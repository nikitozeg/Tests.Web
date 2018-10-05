using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Di;
using ePayments.Tests.Log;
using ePayments.Tests.Services;
using ePayments.Tests.TestRail;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Steps;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions.Common;
using NUnit.Framework;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ePayments.Tests.ApiClient.MasterApiClient.Requests;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;
using TechTalk.SpecFlow.Assist.ValueRetrievers;

namespace ePayments.Tests.Web.Hooks
{
    /// <summary>
    /// Аттрибуты 
    /// </summary>
    [Binding]
    class Hooks
    {
        private readonly Context _context;
        private static string SBTicketUserPath = "/storages/WiredDocs/a92ddb03-2a44-47d5-a5e7-cb1b15b36ff3/";
        private static string IBANUser = "f751650f-2754-4bc1-bf23-ce78f347764e";
        private IEnumerable<LogEntry> previousStepJSerrors = new ReadOnlyCollection<LogEntry>(new List<LogEntry>());
        private static StringBuilder _JSerrorsList;

        string[] excludedErrors = 
        {
            "Failed to load resource: the server responded with a status of 422 ()",
            "Failed to load resource: the server responded with a status of 400 ()",
            "Failed to load resource: the server responded with a status of 401 ()"
        };

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public Hooks(Context context)
        {
            _context = context;
        }

        [BeforeTestRun]
        public static void BeforeTestRun()
        {
            TestRun.Init();
        }


        [AfterTestRun]
        public static void AfterTestRun()
        {
            DiUtils.GetContainer().Dispose();
            //  TestRun.CloseRun();
        }


        [BeforeFeature("Cards")]
        [BeforeFeature("CardDailyService")]
        public static void BeforeFeature()
        {
            var db = new DataBaseSteps(new Context());
            db._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutoCardCreating, true);

            db._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.CardCreate, true);

            db._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.ShowInfoCardForbiddance, false);

            db._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.ShowInfoCardForbiddanceReissue, false);

            db._VATRepository.SetVAT("Russian Federation", 0);
        }


        [BeforeFeature("Financial")]
        public static void BeforeFeatureFinancial()
        {
            var db = new DataBaseSteps(new Context());

            db._VATRepository.SetVAT("Russian Federation", 0);
        }

        #region Scenario hooks

        [BeforeScenario]
        public static void BeforeScenarioRun()
        {
            TestContext.CurrentContext.Test.Properties.SetTestCaseId(
                Int32.Parse(ScenarioContext.Current.ScenarioInfo.Tags.First()));
            _JSerrorsList = new StringBuilder();
        }


        /// <summary>
        /// Выполнение после каждого сценария
        /// </summary>
        [AfterScenario]
        public static void AfterScenarioRun()
        {
            string log = TestLogger.Result;

            //Замена на правильное название скриншота для отображения в логах тестрейла
          
                foreach (var screenshotName in CommonComponentSteps.screenshotList)
                {
                    log = log.Replace
                    (screenshotName, "![Screenshot](" +
                                     $"{TestConfiguration.Current.ScreenshotsUrl}" +
                                     $"/{DateTime.UtcNow.ToString("dd.MM.yyyy")}" +
                                     $"/{screenshotName})");



                    _JSerrorsList = _JSerrorsList.Replace
                    (screenshotName, "![Screenshot](" +
                                     $"{TestConfiguration.Current.ScreenshotsUrl}" +
                                     $"/{DateTime.UtcNow.ToString("dd.MM.yyyy")}" +
                                     $"/{screenshotName})");

                }
            


            try
            {
                TestRun.PushResult(log);

                //3587910 - номер кейса для пуша консольных ошибок браузера
                if (_JSerrorsList.Length != 0)
                {
                    _JSerrorsList.Insert(0, "#================"+ScenarioContext.Current.ScenarioInfo.Title + "  https://qa.swiftcom.uk/index.php?/cases/view/" + ScenarioContext.Current.ScenarioInfo.Tags.First() + " ================"+Environment.NewLine);
                    TestRun.PushResult(_JSerrorsList.ToString(), 3587910);
                    _JSerrorsList.Clear();
                }
                TestLogger.Clear();
            }

            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }

            finally
            {
                DriverManager.QuitWebDriver();
                /// Wait Asynchronous file uploading to cloud storage
                Task.WaitAll();
            }
        }

        [BeforeScenario("RietumuSEPA_out_wire")]
        public void BeforeScenarioRunRietumuSEPA()
        {
            new DataBaseSteps(_context)._bankAccountRepository.UpdateIBANActivity(true, Guid.Parse(IBANUser));
        }

        [BeforeScenario("VAT_Russia_update")]
        public void BeforeScenarioRunScoped()
        {
            new DataBaseSteps(_context)._VATRepository.SetVAT("Russian Federation", 15);
        }

        [BeforeScenario("RefillExternalCardFromPurse_BankQiwi_OFF")]
        public void BeforeScenarioRefillExternalCardFromPurseQIWIOff()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.RefillExternalCardFromPurseBankQiwi, false);
        }

        [BeforeScenario("AutosendWireOut_OFF")]
        public void BeforeScenarioAutosendWireOutOFF()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutosendWireOut, false);
        }


        [BeforeScenario("Card_create_OFF")]
        public void BeforeScenarioCardCreateOff()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.CardCreate, false);
        }

        [BeforeScenario("Ref_card_create_ON")]
        public void BeforeScenarioRefCardCreateON()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.RefCardCreate, true);
        }

        [BeforeScenario("Auto_card_creating_ON")]
        public void BeforeScenarioAutoCardCreatingON()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutoCardCreating, true);
        }


        [BeforeScenario("Auto_card_creating_OFF")]
        public void BeforeScenarioAutoCardCreatingOFF()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutoCardCreating, false);
        }


        [AfterScenario("After_delete_payment_templates")]
        public void AfterScenarioDeletePaymentTemplate()
        {
            new DataBaseSteps(_context)._massPaymentTemplatesrepository
                .DeleteByUserId(Guid.Parse("5da1dc55-198c-4ad3-b4fc-c9917efab251"));
        }


        [AfterScenario("Card_create_OFF")]
        public void AfterScenarioCardCreateOff()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.CardCreate, true);
        }

        [AfterScenario("Auto_card_creating_OFF")]
        public void AfterScenarioAutoCardCreatingOFF()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutoCardCreating, true);
        }


        [AfterScenario("RefillExternalCardFromPurse_BankQiwi_OFF")]
        public void BeforeScenarioRefillExternalCardFromPurseQIWIOn()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.RefillExternalCardFromPurseBankQiwi, true);
        }

        [AfterScenario("Reset_first_name")]
        public void AfterScenarioResetFirstName()
        {
            new DataBaseSteps(_context)._personalDataRepository.SetFirstName(_context.UserId, "ResetFirstName");
        }

        [AfterScenario("AutosendWireOut_OFF")]
        public void AfterScenarioAutosendWireOut()
        {
            new DataBaseSteps(_context)._serviceAvailabilityRepository.SetAvailability(
                ServiceAvailabilityNames.AutosendWireOut, true);
        }

        [AfterScenario("VAT_Russia_update")]
        public void AfterScenarioRunScoped()
        {
            new DataBaseSteps(_context)._VATRepository.SetVAT("Russian Federation", 0);
        }

        [AfterScenario("DeleteFTPTicketDocuments")]
        public static void AfterScenarioDeleteFTPDocs()
        {
            new FTPDownloadService(TestConfiguration.Current.FtpUrl)
                .DeleteFolder(SBTicketUserPath + DateTime.UtcNow.ToString("yyyyMMdd"));
        }

        [AfterScenario("RietumuSEPA_out_wire")]
        public void AfterScenarioRunRietumuSEPA()
        {
            new DataBaseSteps(_context)._bankAccountRepository.UpdateIBANActivity(false, Guid.Parse(IBANUser));
        }

        [AfterScenario("Unfreeze_user")]
        public void AfterScenarioRunScopedFreezingExpiryDate()
        {
            new DataBaseSteps(_context)._userRepository.UpdateFreezingExpiryDate(
                Guid.Parse("70dcac51-8f06-457e-95ec-2ee036702338"));
        }

        [AfterScenario("UserReference_update")]
        public void AfterScenarioRunScopedUserReference_update()
        {
            var response =
                new MasterAPISteps(_context)._masterApiClient.SendPost<string>("UserReferences/Edit",
                    new EditUserReferenceRequest()
                    {
                        RefId = "1417",
                        UserId = "edea918c-407d-4383-8581-40029941c14c",
                        ReferenceString = "6fi0q95w4q",
                        AutoApproveContacts = "false",
                        ManualCardCreating = "false",
                        CoBrand = "LC",
                        CardLightCoBrandId = "10"
                    });

            Assert.True(response.Contains("Reference save success!"), "Reference is not updated: " + response);
        }

        #endregion


        #region Step hooks

        [BeforeStep]
        public void LogStep()
        {
            //Adding step name 
            TestLogger.Message("+ " + ScenarioStepContext.Current.StepInfo.Text, false);

            //Making step table, if exists
            if (ScenarioContext.Current.StepContext.StepInfo.Table != null)
            {
                Table table = ScenarioContext.Current.StepContext.StepInfo.Table;
                TestLogger.Message(
                    "||" + table.ToString().Replace("|\r\n", "\r\n|").Remove(table.ToString().Length - 1), false);
            }
        }


        [AfterStep]
        public void ErrorLog()
        {
            //Make screenshot if step failed
            if (ScenarioContext.Current.TestError != null)
            {
                CommonComponentSteps.MakeScreenshot("FAILED_", true);
                TestLogger.Message("#====> FAILED:" + Environment.NewLine
                                                    + "+ " + ScenarioStepContext.Current.StepInfo.Text +
                                                    Environment.NewLine + Environment.NewLine
                                                    + ScenarioContext.Current.TestError.Message, false, true);
            }


            //Checking for JS errors after every step, if a new errors are detected then make screenshot
            if (previousStepJSerrors.Any())
                if (!previousStepJSerrors.IsSameOrEqualTo(DriverManager.GetWebDriver().Manage().Logs.GetLog(LogType.Browser).Where(it=> it.Level == LogLevel.Severe)))
                {
                    _JSerrorsList.AppendLine(Environment.NewLine + "+ " + ScenarioStepContext.Current.StepInfo.Text +
                                           Environment.NewLine);
                    _JSerrorsList.AppendLine(CommonComponentSteps.MakeScreenshot());
                }


            //Memorize actual console errors
            previousStepJSerrors = DriverManager.GetWebDriver().Manage().Logs.GetLog(LogType.Browser)
                                        //Detect only SEVERE errors
                                        .Where(it => it.Level == LogLevel.Severe)
                                        //Exclude expected errors
                                        .Where(entry => !excludedErrors.Any(s => entry.Message.Contains(s)));


                //Logging NEW JS Errors
               foreach (var entry in previousStepJSerrors)
                   {
                             _JSerrorsList.AppendLine($"{DateTime.UtcNow.ToString("G", new CultureInfo("ru-ru"))}" +
                                                       Environment.NewLine +
                                                       ">>#" + entry + Environment.NewLine);
                   }
        }

        #endregion


        #region Выполнение перед запуском кажого сценария

        /// <summary>
        /// Выполнение перед запуском кажого сценария
        /// </summary>
        [BeforeScenario]
        public void BeforeScenario()
        {
            TestLogger.Message(
                "#================TestCase Id:  " + ScenarioContext.Current.ScenarioInfo.Tags.First() +
                " ================", false);


            var defaultStringValueRetriever =
                Service.Instance.ValueRetrievers.FirstOrDefault(vr => vr is StringValueRetriever);
            if (defaultStringValueRetriever != null)
            {
                Service.Instance.UnregisterValueRetriever(defaultStringValueRetriever);
                Service.Instance.RegisterValueRetriever(new StringValueRetriver());
            }
        }

        /// <summary>
        /// Конвертация из пустых ячеек DataTable -> в NULL
        /// </summary>
        public class StringValueRetriver : IValueRetriever
        {
            public bool CanRetrieve(KeyValuePair<string, string> keyValuePair, Type targetType, Type propertyType)
            {
                return propertyType == typeof(string);
            }

            public object Retrieve(KeyValuePair<string, string> keyValuePair, Type targetType, Type propertyType)
            {
                switch (keyValuePair.Value)
                {
                    case "-":
                        return "";
                    case "":
                        return null;
                    default: return keyValuePair.Value;
                }
            }
        }

        #endregion
    }
}