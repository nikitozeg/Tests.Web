using ePayments.Tests.Helpers;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Pages;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using TechTalk.SpecFlow;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.Steps.AffiliateProgram
{
    /// <summary>
    /// Affiliate Program UI steps 
    /// </summary>
    [Binding]
    class AffiliateProgramSteps
    {
        private readonly Context _context;
        private IEnumerable<UIPartnerLinksTable> memorizedPartnerTable;
        private IEnumerable<UIAvailableForPaymentTable> firstLevelReffererPaymentTable;
        private IEnumerable<UIAvailableForPaymentTable> zeroLevelReffererPaymentTable;
        private string BonusLinkGroup = ".content .bonus-link-item-group";
        private string ExpandTableLocator = ".bonus-payoff-summary";
        private string AvlblPaymentTable = ".bonus-payoff-table-body";
        private string AffiliateLink;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public AffiliateProgramSteps(Context context)
        {
            _context = context;
        }



        [Then(@"User expands Payment Table")]
        public void ThenUserExpandsPaymentTable()
        {
            _context.Grid.ClickOnVisibleElement("", ExpandTableLocator);
        }


        [Given(@"Memorize 0-level refferer 'Available for payment' table")]
        public void MemorizeZeroAvailableForPaymentTable()
        {
            zeroLevelReffererPaymentTable = CreateAvailableForPaymentList(_context.Grid.FindElement(AvlblPaymentTable));
        }

        [Given(@"Memorize 1-level refferer 'Available for payment' table")]
        public void MemorizeFirstAvailableForPaymentTable()
        {
            firstLevelReffererPaymentTable = CreateAvailableForPaymentList(_context.Grid.FindElement(AvlblPaymentTable));
        }

        [Given(@"User see 0-level refferer 'AvailableForPayment' table with updated columns:")]
        public void UserSeeAvailableForPayment(List<UIAvailableForPaymentTable> payTable)
        {
            CheckUpdatedAvailableForPaymentTable(payTable, zeroLevelReffererPaymentTable);
        }

        [Given(@"User see 1-level refferer 'AvailableForPayment' table with updated columns:")]
        public void UserSeeAvailableForPaymentLevelTwo(List<UIAvailableForPaymentTable> payTable)
        {
            CheckUpdatedAvailableForPaymentTable(payTable, firstLevelReffererPaymentTable);
        }


        public void CheckUpdatedAvailableForPaymentTable(List<UIAvailableForPaymentTable> payTable,
            IEnumerable<UIAvailableForPaymentTable> availableForPaymentTable)
        {
            int index = 0;

            foreach (var row in payTable)
            {
                row.Completed += availableForPaymentTable.ElementAt(index).Completed;
                row.ForPayment += availableForPaymentTable.ElementAt(index).ForPayment;
                row.Cancelled += availableForPaymentTable.ElementAt(index).Cancelled;
                row.Processing += availableForPaymentTable.ElementAt(index).Processing;
                index++;
            }
            CheckAvailableForPaymentList(payTable);
        }


        [Given(@"Memorize partner link table with (\d+) links")]
        public void UserSeePartner(int rows)
        {
            memorizedPartnerTable = CreatePartnerLinkList(_context.Grid.DataGridContent(BonusLinkGroup, rows));
            CommonComponentSteps.MakeScreenshot();
        }

        [Given(@"User see partner links with updated columns:")]
        public void UserSeePartnerLinksWhere(List<UIPartnerLinksTable> linksTable)
        {
            int index = 0;

            foreach (var row in linksTable)
            {
                row.Registrations += memorizedPartnerTable.ElementAt(index).Registrations;
                row.Transitions += memorizedPartnerTable.ElementAt(index).Transitions;
                index++;
            }
            CheckPartnerLinkList(linksTable);
            CommonComponentSteps.MakeScreenshot();
        }


        [Given(@"Available for payment table:")]
        public void UserSeeAvailableForPaymentTable(List<UIAvailableForPaymentTable> list)
        {
            _context.Grid.ClickOnElement(ExpandTableLocator);
            CheckAvailableForPaymentList(list);
        }


        [Given(@"User see partner links:")]
        public void CheckPartnerLinkList(List<UIPartnerLinksTable> expectedPartnerLinks)
        {
            CreatePartnerLinkList(_context.Grid.DataGridContent(BonusLinkGroup, expectedPartnerLinks.Count))
                .Select(
                    row => new
                    {
                        row.Transitions,
                        row.Registrations,
                        row.ForPayment,
                        row.Processing,
                        row.Cancelled
                    })
                .ShouldBeEquivalentTo(expectedPartnerLinks, options => options.WithStrictOrdering(),
                    $"Partner Links не соответствуют ожидаемым");
        }

        [Given(@"User see active partner links contains:")]
        public void CheckPartnerLinkListContains(List<UIPartnerLinksTable> expectedPartnerLink)
        {
            expectedPartnerLink.First().LinkNames = AffiliateLink;
            CreatePartnerLinkList(_context.Grid.FindElements(".accordion .li:not([class*='remove'])"))
                .Where(it => it.LinkNames == AffiliateLink)
                .ShouldBeEquivalentTo(expectedPartnerLink, $"Partner Link не соответствуют ожидаемым");
        }

        /// <summary>
        /// Check Available for payment table in Affiliate program page
        /// </summary>
        /// <param name="expectedAvlblForPaymentList">Expected table</param>
        private void CheckAvailableForPaymentList(List<UIAvailableForPaymentTable> expectedAvlblForPaymentList)
        {
            CreateAvailableForPaymentList(_context.Grid.FindElement(AvlblPaymentTable))
                .ShouldBeEquivalentTo(expectedAvlblForPaymentList, options => options.WithStrictOrdering(),
                    $"Available For Payment List не соответствуют ожидаемым");
        }

        /// <summary>
        /// Find and return Partner link table in Affilate program page
        /// </summary>
        /// <param name="tableLocator">tableLocator</param>
        /// <returns>List of UIPartnerLinksTable obj</returns>
        private List<UIPartnerLinksTable> CreatePartnerLinkList(IList<IWebElement> tableLocator)
        {
            List<UIPartnerLinksTable> list = new List<UIPartnerLinksTable>();

            foreach (var row in tableLocator)
            {
                var dic = new UIPartnerLinksTable
                {
                    LinkNames = row.FindElement(By.CssSelector(" .title")).Text,
                    Transitions = Int32.Parse(row.FindElement(By.CssSelector(".bonus-link-item-prop.ng-binding")).Text),
                    Registrations = Int32.Parse(row.FindElement(By.CssSelector("[class=bonus-link-item-prop]")).Text),
                    ForPayment = Decimal.Parse(row.FindElement(By.CssSelector(".link-balance")).Text.Replace("$", "")
                        .Replace("€", "").Replace("₽", "").Replace("~", "")),
                    Processing = Decimal.Parse(row.FindElement(By.CssSelector(".link-hold")).Text.Replace("$", "")
                        .Replace("€", "").Replace("₽", "").Replace("~", "")),
                    Cancelled = Decimal.Parse(row.FindElement(By.CssSelector(".link-canceled")).Text.Replace("$", "")
                        .Replace("€", "").Replace("₽", "").Replace("~", ""))
                };


                Assert.True(dic.LinkNames.Length == 10,
                    "LinkName should contain 10 chars, but actual is:" + dic.LinkNames);
                list.Add(dic);
            }

            return list;
        }

        /// <summary>
        /// Trim and convert to Decimal table content
        /// </summary>
        /// <param name="table">Unconverted table</param>
        private static List<List<Decimal>> convertToDecimal(List<List<string>> table)
        {
            return table.ConvertAll(row =>
                row.ConvertAll(cell => Decimal.Parse(cell.Replace("$", "").Replace("€", "").Replace("₽", "").Replace(" ", ""),
                    CultureInfo.InvariantCulture)));
        }

        /// <summary>
        /// Find and return Available for Payment table in Affilate program page
        /// </summary>
        /// <param name="tableLocator">Locator that contains UL tag</param>
        /// <returns></returns>
        private IEnumerable<UIAvailableForPaymentTable> CreateAvailableForPaymentList(IWebElement tableLocator)
        {
            List<UIAvailableForPaymentTable> list = new List<UIAvailableForPaymentTable>();

            List<List<string>> table = _context.Grid.CreateULRows(tableLocator);


            foreach (var cells in convertToDecimal(table))
            {
                var dic = new UIAvailableForPaymentTable
                {
                    ForPayment = cells[0],
                    Processing = cells[1],
                    Cancelled = cells[2],
                    Completed = cells[3]
                };

                list.Add(dic);
            }

            return list;
        }

        [Then(@"User type Link reference")]
        public void ThenUserTypeLinkReference()
        {
            AffiliateLink = DataBuilderHelper.GenerateStringValue(10);
            MultiFormComponent.FindMultiformSection()
                .ClearText("[name*='nameLink']")
                .SendText("[name*='nameLink']", AffiliateLink);
        }

     
        [Given(@"Affiliate link value is ""(.*)""\+AffiliateLink")]
        public void GivenAffiliateLinkValueIs(string value)
        {
            WaitCssElementContainsText("#linkBonus", value + AffiliateLink);
        }


        [Given(@"User clicks on edited partner link")]
        [Given(@"User clicks on created partner link")]
        public void GivenUserClicksOnCreatedLink()
        {
            _context.Grid.ClickByText(AffiliateLink, "[@title]");
        }

        [Then(@"User clicks on ""(.*)"" on Partner Link")]
        public void GivenUserClicksOnPartnerLink(string text)
        {
            new DataGridComponent(_context.Grid.FindElement(".li.active"))
                .ClickByText(text, "", ".");
        }

        [Then(@"Deleted Partner link is inactive")]
        public void ThenPartnerLinkIsInactive()
        {
            _context.Grid.FindElements(".li.remove .title").ToList().Select(it => it.Text)
                .ShouldBeEquivalentTo(new[] {AffiliateLink}, "More than 1 removed links");
        }
    }
}