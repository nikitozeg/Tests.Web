using System;
using System.Collections.Generic;
using System.Linq;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;

namespace ePayments.Tests.Web.WebDriver
{
    /// <summary>
    /// Явные ожидания элементов в DOM:
    /// Search* методы - ждет и возвращает найденный элемент по локатору 
    /// Wait* методы - ожидание элемента по условию
    /// </summary>
    public class DriverManagerHelper
    {
        public static IWebElement SearchElementByCss(String cssSelector, long timeout = 30)
        {
            new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout)).Until(
                ExpectedConditions.PresenceOfAllElementsLocatedBy(By.CssSelector(cssSelector)));
            return DriverManager.GetWebDriver().FindElement(By.CssSelector(cssSelector));
        }

        public static IWebElement SearchElementByXpath(String xpath, long timeout = 30)
        {
            new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout)).Until(
                ExpectedConditions.PresenceOfAllElementsLocatedBy(By.XPath(xpath)));
            return DriverManager.GetWebDriver().FindElements(By.XPath(xpath)).SingleOrDefault();
        }

        public static IList<IWebElement> SearchElementsByCss(String cssSelector, long timeout = 30)
        {
            new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout)).Until(
                ExpectedConditions.PresenceOfAllElementsLocatedBy(By.CssSelector(cssSelector)));
            return DriverManager.GetWebDriver().FindElements(By.CssSelector(cssSelector));
        }

        public static IWebElement SearchElementByTextXpath(String text, long timeout = 20)
        {
            new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout)).Until(
                ExpectedConditions.PresenceOfAllElementsLocatedBy(By.XPath("//*[contains(.,'" + text + "')]")));
            return DriverManager.GetWebDriver().FindElements(By.XPath("//*[contains(.,'" + text + "')]")).Last();
        }

        public static void WaitElementIsInvisibleByCss(String cssSelector, long timeout = 60)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.PollingInterval = TimeSpan.FromSeconds(1);
            wait.Until(ExpectedConditions.InvisibilityOfElementLocated(By.CssSelector(cssSelector)));
        }

        public static void WaitElementIsVisibleByCss(String cssSelector, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(ExpectedConditions.VisibilityOfAllElementsLocatedBy(By.CssSelector(cssSelector)));
        }

        public static void WaitElementIsClickable(String cssSelector, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(ExpectedConditions.ElementToBeClickable(By.CssSelector(cssSelector)));
        }


        public static void WaitElementIsVisibleByCssInContext(DataGridComponent el, String cssSelector, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => el.FindElement(cssSelector).Displayed);
        }

        public static void WaitElementIsVisibleByXPath(String xpathSelector, long timeout = 30)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(ExpectedConditions.VisibilityOfAllElementsLocatedBy(By.XPath(xpathSelector)));
        }

        public static void WaitElementWithTextByXpath(String text, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.IgnoreExceptionTypes(typeof(NoSuchElementException)); // ignore stale exception issues
            wait.Until(d => d.FindElement(By.XPath($"//*[normalize-space()='{text}']")).Displayed);
        }

        /// <summary>
        /// Ждать элемент содержащий значение value в element
        /// </summary>
        /// <param name="component">Обернутый в DataGridComponent родитель</param>
        /// <param name="fieldName">Название поля</param>
        /// <param name="value">Ожидаемое значение поля</param>
        /// <param name="element">Искомый элемент</param>
        /// <param name="timeout">Таймаут ожидания</param>
        public static void WaitElementWithValueByXpathInContext(DataGridComponent component, String fieldName,string value, string element, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => component.FindElementByText(fieldName, element).GetAttribute("value").Equals(value));
        }

        /// <summary>
        /// Ждать элемент содержащий text
        /// </summary>
        /// <param name="component">Обернутый в DataGridComponent родитель</param>
        /// <param name="fieldName">Название поля</param>
        /// <param name="text">Ожидаемый текст элемента</param>
        /// <param name="element">Искомый элемент</param>
        /// <param name="timeout">Таймаут ожидания</param>
        public static void WaitElementContainsValueTextByXpath(DataGridComponent component, String fieldName, string text, string element, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => component.FindElementByText(fieldName, element).Text.Contains(text));
        }

        public static void WaitCssElementContainsText(String cssSelector, String text, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => d.FindElement(By.CssSelector(cssSelector)).Text.Replace("\r\n", " ").Contains(text));
        }

        public static void WaitCssElementNotContainsText(String cssSelector, String text, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => d.FindElement(By.CssSelector(cssSelector)).Text.Contains(text)==false);
        }

        public static void WaitCssElementIsNotPresence(String cssSelector, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => d.FindElements(By.CssSelector(cssSelector)).Count == 0);
        }

        public static void WaitCountOfCssElements(String cssSelector, int count = 1, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
            wait.Until(d => d.FindElements(By.CssSelector(cssSelector)).Count >= count);
        }

        /// <summary>
        /// Метод для ожидания появления текста в заданном элементе через css selector
        /// </summary>
        /// <param name="el">Элемент в котором будет присходить поиск</param>
        /// <param name="cssSelector">селектор css</param>
        /// <param name="text">Необходимый текст</param>
        /// <param name="timeout">таймаут для поиска</param>
        public static void WaitCssElementContainsText(IWebElement el, String cssSelector, String text,long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues

            wait.Until(d =>
            {
                var actual = el.FindElement(By.CssSelector(cssSelector)).Text;
                return actual.Contains(text);
            });
        }


        /// <summary>
        /// Метод для ожидания появления текста в заданном элементе через xpath selector
        /// </summary>
        /// <param name="el">Элемент в котором будет присходить поиск</param>
        /// <param name="xpathSelector">селектор xpath</param>
        /// <param name="text">Необходимый текст</param>
        /// <param name="timeout">таймаут для поиска</param>
        public static void WaitXpathElementContainsText(IWebElement el, String xpathSelector, String text, long timeout = 20)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues

            wait.Until(d =>
            {
                var actual = el.FindElement(By.XPath(xpathSelector)).Text;
                return actual.Contains(text);
            });
        }


        public static void WaitElementIsPresenceByCss(String cssSelector, long timeout = 30)
        {
            WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(timeout));
            wait.PollingInterval = TimeSpan.FromSeconds(1);
            wait.Until(ExpectedConditions.PresenceOfAllElementsLocatedBy(By.CssSelector(cssSelector)));
        }


    }
}