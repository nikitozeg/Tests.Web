using ePayments.Tests.Common.Extensions;
using ePayments.Tests.Web.WebDriver;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using System;
using System.Linq;

namespace ePayments.Tests.Web.Fragments
{
    using static DriverManagerHelper;

    /// <summary>
    ///  'Select' webelement wrapper
    /// </summary>
    public static class SelectFragment
    {
  

        /// <summary>
        /// Checking default option if select element
        /// </summary>
        /// <param name="selectEl">SelectElement</param>
        /// <param name="text">defaul option</param>
        /// <returns></returns>
        public static SelectElement CheckSelectedOption(SelectElement selectEl, String text)
        {
            Assert.True(
                selectEl
                    .SelectedOption.Text
                    .Contains(text),
                "Default select option is:" + selectEl.SelectedOption.Text + " but expected: " + text);
            return selectEl;
        }

     

        /// <summary>
        /// FindSelectByFieldName
        /// </summary>
        /// <param name="text">fieldName</param>
        /// <returns></returns>
        public static SelectElement FindSelectByFieldName(string text)
        {
            return new SelectElement(SearchElementByXpath(
                $"//label[normalize-space()='{text}']/ancestor::*[contains(@class,'row')][1]//select"));
        }

        /// <summary>
        /// Select option by it's field name
        /// </summary>
        /// <param name="optionText">Option name</param>
        public static void SetOption(String optionText)
        {
            SelectElement selectEl = new SelectElement(SearchElementByXpath($"//option[normalize-space()='{optionText}']/ancestor::select"));
            selectEl.Options
                .SingleOrDefault(it => it.Text.Contains(optionText)).Click();

        }

        /// <summary>
        /// Select option by it's field name
        /// </summary>
        /// <param name="optionText">Option name</param>
        /// <param name="optGroup">Element that contains options</param>
        /// <param name="fieldName">Field Name</param>
        public static void SetOptionByFieldName(String fieldName, String optionText, string optGroup = null)
        {
            SelectElement selectEl = FindSelectByFieldName(fieldName);
            IWebElement option;


            option = optGroup.IsNullOrWhiteSpace()
                ? selectEl.Options
                    .SingleOrDefault(it => it.Text.Contains(optionText))
                : selectEl.WrappedElement.FindElement(By.CssSelector(optGroup)).FindElements(By.CssSelector("option"))
                    .SingleOrDefault(it => it.Text.Contains(optionText));

            option.Click();
        }
    }
}