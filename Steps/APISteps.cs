using ePayments.ApplicationEvents.Common;
using ePayments.ApplicationEvents.Common.Finance;
using ePayments.Infrastructure.RabbitMQ;
using ePayments.Tests.ApiClient.EpaymentsApiClient;
using ePayments.Tests.ApiClient.EpaymentsApiClient.Requests.v1.Partners.Card;
using ePayments.Tests.ApiClient.EpaymentsApiClient.Responses.v1.Partners.Card;
using ePayments.Tests.Di;
using ePayments.Tests.Ehi.Helpers;
using ePayments.Tests.Helpers;
using ePayments.Tests.Web.CatalogContext;
using FluentAssertions;
using StructureMap;
using System;
using System.Linq;
using System.Net;
using TechTalk.SpecFlow;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Bindings for API requests  
    /// </summary>
    [Binding]
    class APISteps
    {
        private readonly Context _context;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public APISteps(Context context)
        {
            _context = context;
        }



        [Then(@"Send event to epacash for UserId = (.*) with last InvoiceId")]
        public void ThenSendEventsToEpacash(Guid UserId)
        {
            DiUtils.GetContainer().GetInstance<IMessageSender<MoneyTransferMessage>>()
                .Send(new MoneyTransferMessage
                {
                    Type = "Finance/Internal Payment",
                    UserId = UserId,
                    Date = DateTime.UtcNow,
                    Status = "Confirmed".ToEnum<EventStatus>(),
                    ServiceName = "WaveCrest",

                    InvoiceId = new DataBaseSteps(_context).GetLastInvoiceByUserId(UserId).InvoiceId,
                    Amount = (decimal) 1000.00,
                    Fee = 100,
                    FixFee = 100,
                    MinProfit = 0,
                    MaxProfit = 0,
                    PercentFee = 0,
                    Currency = 643
                });
        }


        [When(@"User executed POS transaction with amount (.*) for user ""(.*)"" with Token ""(.*)""")]
        public void WhenUserExecutedPOSTransactionWithAmountForUserWithTrans_Link(int amount, string p1, string token)
        {
            _context.StartDate = DateTime.UtcNow;

            var foundCard = new DataBaseSteps(_context).GetCardByToken(token);
            var posRequest = EhiTransactionHelper.SendEhiTransaction(foundCard, EhiTransactionHelper.OperationTypes.Pos, amount);
            _context.Trans_link = posRequest.Trans_link;
            _context.Auth_TXn_ID = Convert.ToInt32(posRequest.TXn_ID) - 1;
        }


        protected IContainer Container => DiUtils.GetContainer();
        protected Authenticator Authenticator;
        protected EpaymentsApiClient EpaymentsApiClient;

        private const string Url = "v1/partners/card/load";

        [Then(@"Partner load on Token = (.*)")]
        public void ThenPartnerLoad(string proxyPanCode)
        {
            var ip = "145.255.232.62";

            var headersWithRealIp = HttpHeaderHelper.GetHeaderWithIp(ip);

            var card = new DataBaseSteps(_context)._cardRepository.GetCardByToken(proxyPanCode);


            var partnerGrant = new PartnerGrant
            {
                PartnerId = 58,
                PartnerSecret = "WQ7kQvMGp5+9KT6BaGBL"
            };

            Authenticator = Container.GetInstance<Authenticator>("Authenticator");
            EpaymentsApiClient = Container.GetInstance<EpaymentsApiClient>("EpaymentsApiClient");

            var token = Authenticator.Authenticate(partnerGrant, ip).Token;


            var request = new PartnerCardLoadRequest
            {
                Amount = 100,
                CardFirstName = card.EmbossingName.Split(' ').First(),
                CardLastName = card.EmbossingName.Split(' ').Last(),
                CardId = card.PanCode,
                Currency = card.CurrencyId.ToString(),
                ExternalId = "nikitaUItestLoadPartner",
                PaymentId = long.Parse(DataBuilderHelper.GetRandomDigits(6)),
                SourcePurse = "000-749103"
            };
       
            var response = EpaymentsApiClient.SendPut<PartnerCardLoadResponse>(Url, token, request, headersWithRealIp);

            response.ErrorCode.Should().Be(0);
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

    }
}