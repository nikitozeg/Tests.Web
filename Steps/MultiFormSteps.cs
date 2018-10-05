using ePayments.Tests.Common.Extensions;
using ePayments.Tests.Helpers;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Fragments;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading;
using ePayments.Tests.Checkers.ExpectedObjects;
using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Data.Domain.Poco;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps
{
    [Binding]
    public class MultiFormSteps
    {
        private readonly Context _context;


        private static String confirmationCode = "input[name=confirmationCode]";
        private static String deliveryType = "[ng-model='model.deliveryType']";
        private static String button = "/parent::button";
        private static String buttonNext = "button[class*='next']";
        private static String deliveryAddressSelect = "[ng-model='model.deliveryAddressView']";
        private static String paymentSourceSelect = "[ng-model='model.purse'] select";
        private static String inputRate = "[ng-show*='rate']:not([class*='ng-hide'])";
        private static String multiformPreloader = ".action-bar-form .multiform-preloader";
        private static String multiformLocator = ".action-bar-form";
        private static String templateNameInput = "templatefield input";
        private static String pageHeader = ".top-nav-title";
        private static String checkboxLocator = "div[@class='custom-checkbox-indicator']";
        private static String input = "input";
        private static String select = "select";
        private static String disabled = "[@disabled='disabled']";
        private static String payByBankCardLocator = ".icon-bank-card";
        private static String payByPayPalocator = ".icon-paypal";
        private static String payOneTimePasswordCodeLocator = "input[name=payOneTimePasswordCode],#confirmCode";

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public MultiFormSteps(Context context)
        {
            _context = context;
        }


        [Then(@"User redirected to account page")]
        [Then(@"Card template appears")]
        public DataGridComponent Init()
        {
            return _context.Grid = MultiFormComponent.FindMultiform();
        }


        public void CheckSelectElement(SelectElement selectElement, Table table, string defaultOption)
        {
            var expectedOptions = table.Rows.ToList().Select(it =>
                it.Values.FirstOrDefault());

            var actualOptions = SelectFragment
                .CheckSelectedOption(selectElement, defaultOption)
                .Options.ToList().Select(it => it.Text).ToList();

            actualOptions.Count.Should().Be(expectedOptions.Count());

            int i = 0;
            foreach (string expOption in expectedOptions)
            {
                actualOptions[i].Should().Contain(expOption);
                i++;
            }
        }

        [Given(@"User clicks on button ""(.*)"" in table")]
        public void GivenUserClicksOnButtonInTable(string text)
        {
            _context.Grid.ClickByText(text, "", "//*[contains(@class, 'action-bar-form')]");
        }


        [Then(@"Currency rate placeholder appears")]
        public void ReceivedAmount()
        {

            WaitElementIsVisibleByCss(inputRate);
            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();

            var rateElement = _context.Grid.FindElement(inputRate);
            var index = rateElement.Text.LastIndexOf(" ");


            _context.Rate = Decimal.Parse(rateElement.Text.Substring(index).Replace(")", "").TrimEnd('0'));
            Assert.True(_context.Rate > 0, "Rate is less than 0");
        }

        [Given(@"'(.*)' selector is ""(.*)"" and contains:")]
        public void GivenFromSelectorContains(string fieldName, string defaultOption, Table expectedOptions)
        {
            CheckSelectElement(SelectFragment.FindSelectByFieldName(fieldName), expectedOptions, defaultOption);
        }


        [Then(@"'(.*)' selector set to '(.*)' in EPA cards section")]
        public void SetSelectorOptionByFieldNameInEpaCardSection(string fieldName, string optionText)
        {
            SelectFragment.SetOptionByFieldName(fieldName, optionText, " [label *= 'ePayments Card']");
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"'(.*)' selector set to '(.*)' in eWallet section")]
        public void SetSelectorOptionByFieldNameInOptGroup(string fieldName, string optionText)
        {
            SelectFragment.SetOptionByFieldName(fieldName, optionText, " [label *= 'e-Wallet']");
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"'(.*)' selector set to '(.*)'")]
        public void SetSelectorOptionByFieldName(string fieldName, string optionText)
        {
            SelectFragment.SetOptionByFieldName(fieldName, optionText);
            WaitPreloader(multiformPreloader);
        }

        [Then(@"'(.*)' details set to '(.*)'")]
        public void ThenDetailsSetTo(string fieldName, string value)
        {
            var input = _context.Grid.FindElementByText(fieldName, "textarea");
            input.Clear();
            input.SendKeys(value);
            SearchElementByCss(pageHeader).Click();
        }



        [Then(@"'(.*)' set FirstName to random text")]
        public void FillFirstNameWithRandomText(string fieldName)
        {
            _context.PersDetails.FirstName=DataBuilderHelper.GenerateStringValue(10);
            FillInput(fieldName, _context.PersDetails.FirstName);
        }

        [Then(@"'(.*)' set LastName to random text")]
        public void FillLastNameWithRandomText(string fieldName)
        {
            _context.PersDetails.LastName = DataBuilderHelper.GenerateStringValue(10);
            FillInput(fieldName, _context.PersDetails.LastName);
        }

        [Then(@"'(.*)' set to random (email|Email)")]
        public void FillRandomEmail(string fieldName, string opt=null)
        {
            _context.Email = DataBuilderHelper.GenerateEmail();
            FillInput(fieldName, _context.Email);
        }

        [Then(@"'(.*)' set to email '(.*)'")]
        public void FillWithEmail(string fieldName, string email)
        {
            _context.Email = email;
            FillInput(fieldName, _context.Email);
        }

        [Then(@"'(.*)' set to random (phone|Phone)")]
        public void FillRandomPhone(string fieldName, string opt=null)
        {
            _context.PhoneNumber = DataBuilderHelper.GenerateMobilePhone();
            FillInput(fieldName, _context.PhoneNumber);
        }

        [Then(@"'(.*)' set to phone '(.*)'")]
        public void FillWithPhone(string fieldName, string phone)
        {
            _context.PhoneNumber = phone;
            FillInput(fieldName, _context.PhoneNumber);
        }

        [Then(@"'(.*)' set confirmation code")]
        public void FillConfirmationCode(string fieldName)
        {
            WaitElementWithTextByXpath(fieldName);
            _context.Grid.FindElementByText(fieldName, input).Click();
            FillInput(fieldName, _context.VerificationCode);
        }

        [Then(@"Click on input field '(.*)'")]
        public void ClickOnInputField(string fieldName)
        {
            _context.Grid.FindElementByText(fieldName, input).Click();
        }

        [Then(@"'(.*)' set to '(.*)'")]
        public void FillInput(string fieldName, string value)
        {
            var field = _context.Grid.FindElementByText(fieldName, input);

            //If numeric, assign value to _context.Amount
            if (Decimal.TryParse(value, out Decimal amount))
                _context.Amount = amount;

            field.Click();
            field.Clear();
            field.SendKeys(value);

            // To-DO
            //    WaitJsElementContainsText("[name=\"totalAmount\"]",
            //      Decimal.Round(_context.OutAmount * _context.Rate, 2, MidpointRounding.ToEven).ToString());
        }

        [Then(@"'(.*)' set to '(.*)' and unfocus")]
        public void FillInputAndUnfocus(string fieldName, string value)
        {
            FillInput(fieldName, value);
            SearchElementByCss(pageHeader).Click();
        }


        [Then(@"'(.*)' UI selector set to '(.*)'")]
        public void UISelectSet(string fieldName, string value)
        {
            new DataGridComponent(_context.Grid.FindElementByText(fieldName, "*[contains(@class,'ui-select-container')]"))
                .SendText(UISelectSearch, value)
                .ClickOnElement(UISelectSearch)
                .SelectUISearchOption(value);

            WaitPreloader(multiformPreloader);
        }

        [Then(@"Select checkbox '(.*)'")]
        public void CheckBoxClick(string checkboxText)
        {
           _context.Grid
                .FindElementByText(checkboxText, checkboxLocator)
                .Click();
        }

        [Then(@"'(.*)' value is '(.*)'")]
        public void CheckInputValue(string fieldName, string value)
        {
            WaitElementWithValueByXpathInContext(_context.Grid, fieldName, value, input);
        }

        [Then(@"'(.*)' value is '(.*)' and disabled")]
        public void CheckDisabledInputValue(string fieldName, string value)
        {
            WaitElementWithValueByXpathInContext(_context.Grid, fieldName, value, input + disabled);
        }

        [Then(@"'(.*)' selector is '(.*)' and disabled")]
        public void CheckDisabledSelectorValue(string fieldName, string value)
        {
            WaitElementContainsValueTextByXpath(_context.Grid, fieldName, value, select + disabled);
        }


        [Then(@"'(.*)' value is '(.*)' multiplied by rate")]
        public void CheckInputValueWithRate(string fieldName, Decimal value)
        {
            _context.IncomingAmount = (value * _context.Rate).RoundBank();
            ThenValueShouldBeTheSameWhenTemplateWasSaved(fieldName);
        }

        [Then(@"'(.*)' value should be the same when template was saved")]
        public void ThenValueShouldBeTheSameWhenTemplateWasSaved(string fieldName)
        {
            WaitElementWithValueByXpathInContext(_context.Grid, fieldName, _context.IncomingAmount.ToString(), input);
        }
        
        [Then(@"'(.*)' details value is '(.*)'")]
        public void CheckDetailsValue(string fieldName, string value)
        {
            _context.Grid.FindElementByText(fieldName, "textarea").GetAttribute("value").Should().Be(value);
        }

        [Then(@"Placeholder for '(.*)' is '(.*)'")]
        public void ThenPlaceholderForIs(string fieldName, string placeholder)
        {
            _context.Grid.FindElementByText(fieldName, "input").GetAttribute("placeholder").Should().Be(placeholder);
        }

        [Then(@"Currency for '(.*)' is '(.*)'")]
        public void CurrencyIs(string fieldName, string value)
        {
            _context.Grid.FindElementByText(fieldName, "span[contains(@class,'postfix')]").Text.Should().Be(value);
        }


        [Then(@"Validating message '(.*)' appears on MultiForm")]
        public void ThenValidatingMessageAppearsOnMultiForm(string errMessage)
        {
            _context.Grid.TextIsPresence(errMessage);
        }

        [Then(@"Validating message '(.*)' count is (\d+)")]
        public void CheckCountOfValidatingMessages(string errMessage, int messageCount)
        {
            _context.Grid.FindElementsContainsText(errMessage).Count().Should().Be(messageCount);
        }


        [Then(@"User selects delivery address=""(.*)"" on Multiform")]
        public void ThenUserSetdeliveryaddress(string address)
        {
            Init()
                .SelectDropdownOption(deliveryAddressSelect, address, 1);
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"User selects payment eWallet ""(.*)"" on Multiform")]
        public void ThenUserSetPaymentWallet(string ewallet)
        {
            _context.Grid.SelectDropdownOption(paymentSourceSelect, ewallet, 1);
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"User selects bank card payment on Multiform")]
        public void ThenUserSetPaymentWalletp()
        {
            WaitElementIsVisibleByCss(".icon-bank-card");
            _context.Grid.ClickOnElement(payByBankCardLocator);
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"User selects PayPal payment on Multiform")]
        public void ThenUserSetPaypPalPayment()
        {
            _context.Grid.ClickOnElement(payByPayPalocator);
            WaitPreloaderFinish(PreloaderGrid);
        }

        [Given(@"User see quittance table")]
        public void GivenUserSeeQuittance(List<UITable> expectedTable)
        {
            expectedTable.RemoveAll(it => it.Column1.Equals("Дата"));

            CheckTable(expectedTable, 1);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User see quittance table for the UserId=(.*) where DestinationId='(.*)'")]
        public void GivenUserSeeQuittanceWithTransactionNumber(string userId, PurseTransactionDestination destinationId, List<UITable> expectedTable)
        {
            expectedTable[0].Column2 = new StatementsSteps(_context).GetPurseTransactionIdByDestinationAndDirection(userId, destinationId, "out").ToString();
            GivenUserSeeQuittance(expectedTable);
        }

        [Given(@"User see quittance YandexMoney receivers table")]
        public void UserSeeQuittanceReceiverTable(List<UIWMPaymentTable> expectedTable)
        {
            expectedTable = ReplaceTable(expectedTable, _context.Rate, _context.Amount, null, null, null, _context.Fee, _context.Email);
            TableFragment.CheckTables(_context.Grid, multiformLocator, expectedTable, 2);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User see ExternalCard receivers table")]
        [Given(@"User see YandexMoney receivers table")]
        [Given(@"User see WM receivers table")]
        [Given(@"User see VISA QIWI Wallet receivers table")]
        public void GivenUserSeeReceiverTable(List<UIWMPaymentTable> expectedTable)
        {
            CheckTable(expectedTable);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User see table")]
        public void GivenUserSeeTableOnMultiform(List<UITable> expectedTable)
        {
            CheckTable(expectedTable);
        }

        [Given(@"User see Receiver table")]
        public void GivenUserSeeRecipientTable(List<UIInternalPaymentReceiverTable> expectedTable)
        {
            CheckTable(expectedTable, 1);
            CommonComponentSteps.MakeScreenshot();
        }

        public void CheckTable<T>(List<T> expectedTable, int tableIndex = 0)
        {
            expectedTable = ReplaceTable(expectedTable, _context.Rate, _context.Amount,null,null,null,_context.Fee, _context.Email ?? _context.PhoneNumber);
            TableFragment.CheckTablesWithOrder(_context.Grid, multiformLocator, expectedTable, tableIndex);
        }
        
        [Given(@"User clicks on ""(.*)"" on Multiform")]
        public void GivenUserClicksOnOnMultiform(string text)
        {
            GivenUserClosesMultiform(text);
            Init();
        }


        [Given(@"User closes multiform by clicking on ""(.*)""")]
        public void GivenUserClosesMultiform(string text)
        {
            //Wait button animation EPA-5377
            Thread.Sleep(1000);
            WaitPreloader(multiformPreloader);
            _context.Grid.ClickByText(text, ")[last()]", "(.");
            WaitPreloader(multiformPreloader);
        }


        [Then(@"User choose ewallet to pay for card order")]
        public void GivenUserClicksOnAdd()
        {
            WaitElementIsVisibleByCss(".icon-epayments");
            _context.Grid.ClickOnElement(".icon-epayments");
        }

        

   
        [Given(@"User fills User activation details for Business user:")]
        public void GivenUserFillsUserActivationDetailsWithForBusinessUser(UIBusinessDetails expectedList)
        {
            _context.BusinessDetails = expectedList;

            Init()
                .SendText("[name='fullname']", expectedList.CompanyName)
                .SendText("[name='website']", expectedList.WebSite)
                .SendText("[name='registrationNumber']", expectedList.RegNumber.ToString())
                .SendText(UISelectSearch, expectedList.Country)
                .ClickOnElement(UISelectSearch)
                .SelectUISearchOption(expectedList.Country)
                .SendText("[name='tradingAddress']", expectedList.TradingAddress);
            CommonComponentSteps.MakeScreenshot();
        }




        [Then(@"User set Country ""(.*)""")]
        public void ThenUserSetCountry(string country)
        {
            _context.Grid
                .SendText(UISelectSearch, country)
                .ClickOnElement(UISelectSearch)
                .SelectUISearchOption(country);

            WaitPreloaderFinish(PreloaderGrid);
        }

        [Then(@"User set Country ""(.*)"" in address of residence")]
        public void ThenUserSetCountryInAddressOfResidence(string country)
        {
            string addressLocator = "[name='addressform'] ";

            _context.Grid
                .SendText(addressLocator + UISelectSearch, country)
                .ClickOnElement(addressLocator + UISelectSearch);

            new DataGridComponent(SearchElementByCss(addressLocator + UISelectChoices))
                .ClickByText(country, "", "//form[@name='addressform']");

            WaitPreloaderFinish(PreloaderGrid);
        }


        [Then(@"User change Country to (.*)")]
        public void ThenUserChangeCountryTo(string country)
        {
            
            _context.Grid.ClickOnElement(UISelectedInput);

            WaitElementIsVisibleByCss(UISelectChoices);
            _context.Grid
                .ClearText(UISelectSearch)
                .SendText(UISelectSearch, country)
                .SelectUISearchOption(country);
        }


        [Then(@"User sets City to (.*)")]
        public void ThenUserSetCity(string city)
        {
            _context.Grid.SendText("[name=city]", city);
        }

        [Then(@"User sets State to (.*)")]
        public void ThenUserSetState(string state)
        {
            _context.Grid.SendText("[name=county]", state);
        }

        [Then(@"User sets Postal Code to (.*)")]
        public void ThenUserSetPostalCode(string code)
        {
            _context.Grid.SendText("[name=postalCode]", code);
        }

        [Then(@"User sets Address to (.*)")]
        public void ThenUserSetAddress(string address)
        {
            _context.Grid.SendText("[name=addressLine1]", address);
        }

        [Then(@"User sets optional Address2 to (.*)")]
        public void ThenUserSetsOptionalAddress2To(string address2)
        {
            _context.Grid.SendText("[name=addressLine2]", address2);
        }

        [Then(@"User sets optional Address3 to (.*)")]
        public void ThenUserSetsOptionalAddress3To(string address3)
        {
            _context.Grid.SendText("[name=addressLine3]", address3);
        }


        [Given(@"User fills Secret Details on Multifrom:")]
        public void GivenUserFillsSecretDetailsOnMultifrom(UISecretDetails details)
        {
            _context.Grid.SendText("[ng-model = 'epModel.memorablePlace']", details.SecretPlace)
                .SendText("[ng-model = 'epModel.activationCode']", details.SecretCode)
                .ClickOnElement("[name=memorableDate]")
                .SendTextByChars("[name=memorableDate]", details.SecretDate)
                .SendText("[name=memorableName]", details.SecretName);

            //To hide calendar and click next;
            SearchElementByCss(pageHeader).Click();
        }

        [Then(@"User gets message ""(.*)"" on Multiform")]
        public void ThenUserGetsMessageOnMultiform(string text)
        {
            WaitPreloader(".action-bar-form .multiform-preloader");
            WaitElementIsVisibleByXPath($".//*[contains(text()[normalize-space()],'{text}')]", 120);
            CommonComponentSteps.MakeScreenshot();
        }

        [Then(@"User see PIN code")]
        public void UserGetsPINCode()
        {
            Assert.True(_context.Grid.FindElement("[ng-if='model.showNewPin()']").Text.Contains("PIN:"));

            int PIN = Int32.Parse(_context.Grid.FindElement("[ng-if='model.showNewPin()'] b").Text);
           
            PIN.Should().BeInRange(0, 9999,"PIN code is not valid: "+PIN);
            CommonComponentSteps.MakeScreenshot();
        }

        [Then(@"User fill create ""(.*)"" invite link ""(.*)"" with currency ""(.*)"" on Multiform")]
        public void ThenCreateInviteLink(string count, string link, string currency)
        {
            MultiFormComponent.FindLimitsAndMultiform()
                .SelectDropdownOption("[name=refLink]", link)
                .SendText("[name=count]", count)
                .SelectDropdownOption("[name=currency]", currency);
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User fills ConfirmationCode on activation details")]
        public void GivenUserFillsConfirmationCode()
        {
            WaitPreloaderFinish(LimitsAndMultiForm + MultiFormPreloader);
            _context.Grid = Init().SendText(confirmationCode, _context.VerificationCode);
        }


        [Then(@"User set payment password ""(.*)""")]
        public void ThenUserConfirmsOperationByPaymentPassword(String paymentPassword)
        {
                    WaitPreloader(multiformPreloader);

                    IList<IWebElement> list = SearchElementsByCss(PaymentPasswordLocator);
                    var paymentChars = paymentPassword.ToCharArray();

                    foreach (var select in list.Select((value, i) => new {i, value}).Where(it => it.value.Enabled))
                    {
                        select.value.SendKeys(paymentChars.GetValue(select.i).ToString());
                    }

        }


        [Then(@"User type (PushCode|SMSCode|SMS) sent to:")]
        public void ThenUserConfirmsOperationBy(string confirmPasswordType, List<ExpectedConfirmationCode> expectedConfirmationCode)
        {
            WaitPreloader(multiformPreloader);
            var confirmationCode = new DataBaseSteps(_context).CheckAndReturnConfirmationCode(expectedConfirmationCode.First().UserId, expectedConfirmationCode);

            _context.Grid.SendText(payOneTimePasswordCodeLocator, confirmationCode);
        }


        [Then(@"New fieldset appears")]
        public void ThenNewFieldsetAppears()
        {
            _context.Grid.FindElements("fieldset .ng-form").Count.Should().Be(2);
        }

        [Then(@"User See EPA card masked PAN and owner info")]
        public void ThenUserSeeEPACardMaskedPANAndOwnerInfo()
        {

            CheckEPACardUnblockInfo(_context.FullPAN, _context.PersDetails.FirstName, _context.PersDetails.LastName);

        }

        [Then(@"User See EPA card masked PAN='(.*)' firstName='(.*)' lastName='(.*)'")]
        public void CheckEPACardUnblockInfo(string FullPAN, string firstName, string lastName)
        {
            var maskedPan = FullPAN.Substring(0, 4) + " xxxx xxxx " + FullPAN.Substring(12, 4);

            string rowPAN = _context.Grid.FindElement(".form-card-activate .row.pan").Text;
            rowPAN.Should().Be(maskedPan);

            string ownerInfo = _context.Grid.FindElement(".form-card-activate .name").Text;
            ownerInfo.Should().Be(firstName + " " + lastName);

            CommonComponentSteps.MakeScreenshot();
        }

        [Then(@"User fills CardDetails:")]
        public void ThenUserFillsCardDetails(CardDetails cardDetails)
        {
            _context.Grid
                .SendText("input[name=cardNumber]", cardDetails.CardNumber)
                .SendText("input[name=cardExpireAt]", cardDetails.CardExpireAt)
                .SendText("input[name=cvc_new]", cardDetails.CVC)
                .SendText("input[name=cardHolder]", cardDetails.CardHolder);

        }

        [Given(@"User sets new template name ""(.*)""")]
        public void GivenUserClicksOnEdit(string templateName)
        {
            _context.Grid
                .ClearText(templateNameInput)
                .SendText(templateNameInput, templateName);
        }

    }
}