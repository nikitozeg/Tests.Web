using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using FluentFTP;
using TechTalk.SpecFlow.Assist;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.WebDriver
{
    public class DataGridComponent
    {
        private IWebElement _gridElement;

        public DataGridComponent(IWebElement gridElement)
        {
            _gridElement = gridElement;
        }

        public IWebElement FindElement(string locator)
        {
            return _gridElement.FindElement(By.CssSelector(locator));
        }

        public IWebElement FindElementByText(string text, string append)
        {
            ReadOnlyCollection<IWebElement> foundElements = null;
            int counter=0;

            while (foundElements.IsBlank() && counter != 5)
            {
                foundElements= _gridElement.FindElements(By.XPath($"(//label[normalize-space()='{text}'])[last()]/ancestor::*[contains(@class,'row')][1]//{append}"));
                Thread.Sleep(500);
                counter++;
            }

            return foundElements.Single();
        }
        
        public IList<IWebElement> FindElements(string locator)
        {
            return _gridElement.FindElements(By.CssSelector(locator));
        }

        public DataGridComponent ClickOnElement(String locator)
        {
            _gridElement.FindElement(By.CssSelector(locator)).Click();
            return this;
        }

        public DataGridComponent ClickOnVisibleElement(string parent, string locator)
        {
            WaitElementIsVisibleByCss(parent + locator);
            try
            {
                ClickOnElement(locator);
            }
            catch (StaleElementReferenceException)
            {
                DriverManager.GetWebDriver().FindElement(By.CssSelector(locator)).Click();
            }
            return this;
        }


        public DataGridComponent ClickByText(String text, string append = null, string appendToBegin = "")
        {
            var locator = appendToBegin + $"//*[contains(text()[normalize-space()],'{text}')]{append}";

            try
            {
                _gridElement.FindElement(By.XPath(locator)).Click();
            }
            catch (StaleElementReferenceException)
            {
                DriverManager.GetWebDriver().FindElement(By.XPath(locator)).Click();
            }
            return this;
        }


        public DataGridComponent SendText(String CssLocator, String text, long? delay=null)
        {
            _gridElement.FindElement(By.CssSelector(CssLocator)).SendKeys(text);

            return this;
        }

        /// <summary>
        /// Метод для введения текста в поле с задержкой 
        /// </summary>
        /// <param name="CssLocator">Локатор элемента</param>
        /// <param name="text">Текст для инпута</param>
        /// <returns></returns>
        public DataGridComponent SendTextByChars(String CssLocator, String text)
        {
            IWebElement inputField = _gridElement.FindElement(By.CssSelector(CssLocator));
            text.ToCharArray().ToList().ForEach(it =>
            {
                Thread.Sleep(200);
                inputField.SendKeys(it.ToString());
            });


            return this;
        }



        public DataGridComponent ClearText(String CssLocator)
        {
            _gridElement.FindElement(By.CssSelector(CssLocator)).Clear();
            return this;
        }


        public DataGridComponent SelectUISearchOption(String text)
        {
            new DataGridComponent(SearchElementByCss(UISelectChoices))
                .ClickByText(text,"",".");
            return this;
        }
        
        public DataGridComponent SelectDropdownOption(String CssSelectLocator, String text, int optionsCount = 2,
            string optGroup = null)
        {
            WaitCountOfCssElements(CssSelectLocator + " option", optionsCount);

            FindElements(CssSelectLocator + optGroup + $" [label*='{text}']").SingleOrDefault().Click();

            return this;
        }


        public void WaitElementWithText(String locator, string message)
        {
            WaitCssElementContainsText(_gridElement, locator, message);
            Assert.True(FindElement(locator).Displayed);
        }

        /// <summary>
        /// Ожидание элемента с текстом чреез xpath
        /// </summary>
        /// <param name="locator">Локатор</param>
        /// <param name="message">Текст</param>
        public void WaitElementWithTextByXPath(String locator, string message)
        {
            WaitXpathElementContainsText(_gridElement, locator, message);
        }

        public IEnumerable<IWebElement> FindElementsContainsText(string message, string append = "")
        {
            return _gridElement.FindElements(
                By.XPath($".//*[contains(text()[normalize-space()],'{message}')]{append}"));
        }

        public DataGridComponent TextIsNotPresence(string message)
        {
            FindElementsContainsText(message).Should().BeEmpty();
            return this;
        }

        public DataGridComponent TextIsPresence(string message)
        {
            FindElementsContainsText(message).First().Displayed.Should().BeTrue();
            return this;
        }


        /// <summary>
        /// Waiting element with expected size of content
        /// </summary>
        /// <param name="gridLocator">Element containing other elements</param>
        /// <param name="expectedContentSize">Expected size of it's element</param>
        /// <returns>Found WebElements</returns>
        public IList<IWebElement> DataGridContent(String gridLocator, int expectedContentSize)
        {
            try
            {
                WebDriverWait wait = new WebDriverWait(DriverManager.GetWebDriver(), TimeSpan.FromSeconds(10));
                wait.IgnoreExceptionTypes(typeof(StaleElementReferenceException)); // ignore stale exception issues
                wait.Until(d => d.FindElements(By.CssSelector(gridLocator)).Count == expectedContentSize);
            }
            catch (WebDriverTimeoutException)
            {
                Console.WriteLine("Size assert exception");
                throw new ComparisonException(
                    "Expected content size = " + expectedContentSize + ", actual = " +
                    _gridElement.FindElements(By.CssSelector(gridLocator)).Count);
            }

            var elems = _gridElement.FindElements(By.CssSelector(gridLocator));
            return elems;
        }











        /// <summary>
        /// Convert UL tag to List of Lists
        /// </summary>
        /// <param name="element">Element containing UL tag</param>
        /// <returns>Converted table</returns>
        public List<List<string>> CreateULRows(IWebElement element)
        {
            List<List<string>> list = new List<List<string>>();

            foreach (var row in element.FindElements(By.CssSelector("ul")))
            {
                var cells = row.FindElements(By.CssSelector("li"));

                List<string> listcells = new List<string>();

                foreach (var cell in cells)
                {
                    listcells.Add(cell.Text);
                }
                list.Add(listcells);
            }

            return list;
        }
    }
}