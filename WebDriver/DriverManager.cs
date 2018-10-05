using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using System.IO;
using ePayments.Tests.TestRail;

namespace ePayments.Tests.Web.WebDriver

{
    /// <summary>
    /// Инициализация WD
    /// </summary>
    public class DriverManager
    {
        private static IWebDriver _webDriver;

        public static IWebDriver GetWebDriver()
        {
            if (_webDriver == null)
            {
                ChromeOptions options = new ChromeOptions();
                #if SANDBOXCI
                options.AddArgument("--headless");
                options.AddArgument("--disable-gpu");
                options.AddArgument("--lang=ru");
                options.AddArgument("--window-size=1920,1080");   
                #endif

                if (TestRun.IsEnabled)
                {
                    options.SetLoggingPreference(LogType.Browser, LogLevel.Severe);
                }

                _webDriver = new ChromeDriver(Path.GetFullPath(Path.Combine(TestContext.CurrentContext.TestDirectory, @"..\..\Chromedriver")), options);
                _webDriver.Manage().Window.Maximize();
                _webDriver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(20);   
            }

            return _webDriver;
        }

        public static void QuitWebDriver()
        {
            if (_webDriver != null)
            {
                _webDriver.Quit();
                _webDriver = null;
            }
        }
    }
}