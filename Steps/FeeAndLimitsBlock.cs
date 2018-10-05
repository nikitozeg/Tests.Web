using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using ePayments.Tests.Common.Extensions;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;
using TableFragment = ePayments.Tests.Web.Fragments.TableFragment;

using static ePayments.Tests.Web.WebDriver.CommonComponentHelper;

namespace ePayments.Tests.Web.Steps
{
    [Binding]
    public class FeeAndLimitsBlock
    {
        private string amountBlock = ".amount";
        private string limitsBlockLocator = ".action-bar-content";
        private readonly Context _context;

        private string multiformPreloader = ".action-bar-form .multiform-preloader";
        private string regexErrorMessage = "Regex not found a match";

        public FeeAndLimitsBlock(Context context)
        {
            _context = context;
        }


        public DataGridComponent GetFeeAndLimitsSection()
        {
            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();
            return _context.Grid;
        }

        [Given(@"User see limits table in MassPayment")]
        public void GivenUserSeeLimitsTableInMassPayment(List<UIInternalPaymentFeeTable> expectedTable)
        {
            CheckTable(expectedTable);
        }
        

        [Given(@"User see limits table")]
        public void GivenUserSeeTableOnMultiform(List<UITable> expectedTable)
        {
            CheckTable(expectedTable);
        }

        [Given(@"User see limits table at ExternalCard mass payment")]
        [Given(@"User see limits table at YandexMoney mass payment")]
        [Given(@"User see limits table at WebMoney mass payment")]
        public void GivenUserSeeTableAtWMPayment(List<UIMinMaxFeeTableMassPayment> expectedTable)
        {
            CheckTable(expectedTable);
        }

        public void CheckTable<T>(List<T> expectedTable)
        {
            TableFragment.CheckTablesWithOrder(_context.Grid, limitsBlockLocator, expectedTable);
        }


        [Then(@"Section 'Received amount' is: (.*)")]
        public void ReceivedAmountSection(String text)
        {
            WaitCssElementContainsText(amountBlock, "=");
            var ind = GetFeeAndLimitsSection().FindElement(".amount").Text.LastIndexOf(" ");

            _context.Rate =Decimal.Parse(GetFeeAndLimitsSection().FindElement(amountBlock).Text.Substring(ind).Replace(")", ""));
            Assert.True(_context.Rate > 0, "Rate is less than 0");

            text = CommonComponentHelper.ReplaceString(text, _context.Rate, _context.Amount);

            GetFeeAndLimitsSection().FindElement(amountBlock).Text.Replace("\r\n", " ")
                .Should().Be(text);
        }


        [Then(@"Section 'Amount including fees' is: (.*)")]
        public void ThenSectionIsFees(string amountFees)
        {
            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();
            WaitCssElementNotContainsText(amountBlock, "=");
            WaitCssElementContainsText(amountBlock, amountFees);
        }


        [Then(@"Section 'Amount including fees' contains: '(.*)' and '(.*)' for (.*)")]
        public void ThenCryptoSectionFee(string rateDescription, string feesDescription, string crypto)
        {
            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();

            WaitCssElementContainsText(amountBlock, rateDescription);
            WaitCssElementContainsText(amountBlock, feesDescription);

            //Wait for animation
            Thread.Sleep(1000);
            WaitPreloader(multiformPreloader);

            CommonComponentSteps.MakeScreenshot();

            var fees = _context.Grid.FindElement(amountBlock).Text;


            string oneDigitSpace3digitsDot2digits = @"[ ][0-9][ ](\d){3}[.](\d){2};";
            string oneDigitDot4digits = @"[ ][0][.](\d){4}[ ]";
            string oneDigitDot2digits = @"[ ][0-1][.](\d){2};";
            string oneDigitDot1digits = @"[ ][0-9][.](\d){1}[ ]";
            string oneDigitDot3digits = @"[ ][0][.][0-9]{3}[ ]";

            string twoDigitDot2digits = @"[ ](\d){2}[.](\d){2};";

            string threeDigitDot2digits = @"[ ](\d){3}[.](\d){2};";

            switch (crypto)
            {
                case "BTC":
                    Regex.Match(fees, oneDigitSpace3digitsDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot4digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                case "EURS":
                    Regex.Match(fees, oneDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot1digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                case "BTG":
                    Regex.Match(fees, twoDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot4digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;


                case "BCH":
                    Regex.Match(fees, threeDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot4digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                case "ETH":
                    Regex.Match(fees, threeDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot3digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                case "USDT":
                    Regex.Match(fees, oneDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot1digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                case "LTC":
                    Regex.Match(fees, twoDigitDot2digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    Regex.Match(fees, oneDigitDot3digits).Value.Should().NotBeEmpty(regexErrorMessage);
                    break;

                default: throw new Exception("No any case branch for crypto "+ crypto);
            }
            
       }

        /// <summary>
        /// Шаг, используемый при переводе через шаблон.
        /// </summary>
        /// <param name="amountFees"></param>
        /// <param name="fee"></param>
        [Then(@"Section 'Amount including fees' is (.*) multiplied by rate with fee (\d+)%")]
        public void ThenSectionIsFeesGenerated(string amountFees, int fee)
        {
            //Высчитываем актуальную отдаваемую сумму, по рейту и получаемой сумме (в шаблонах хранится только получаемая сумма) 
            _context.Amount = (_context.IncomingAmount / _context.Rate);
           
            //То же самое, но с комиссией
            _context.Fee = _context.Amount * (fee / 100m);

            //Формируем ожидаемую строку
            amountFees = amountFees.Replace("**Amount with fee**", (_context.Amount + _context.Fee).RoundBank().ToString()).Replace("**Fee**", _context.Fee.RoundBank().ToString());

            _context.Grid = MultiFormComponent.FindLimitsAndMultiform();
            WaitCssElementNotContainsText(amountBlock, "=");
            WaitCssElementContainsText(amountBlock, amountFees);
        }
    }
}