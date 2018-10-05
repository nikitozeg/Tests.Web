using ePayments.Tests.Checkers.ExpectedObjects;
using ePayments.Tests.Data.Domain.Poco;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Data.UITables;
using FluentAssertions;
using NUnit.Framework;
using System.Collections.Generic;
using System.Linq;
using ePayments.Tests.ApiClient.MasterApiClient.Requests;
using ePayments.Tests.Web.Checkers;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Step Argument Conversions
    /// </summary>
    [Binding]
    public class ArgumentTransformations
    {

        private IEnumerable<T> ConvertTable<T>(Table table)
        {
            var tableHeaders = table.Header.ToList();
            var dtoProperties = typeof(T).GetProperties().Select(p => p.Name);

            tableHeaders.ForEach(
                header => Assert.True(dtoProperties.Contains(header), $"{header} is not found in DTO")
            );

            return table.CreateSet<T>();
        }
        
        [StepArgumentTransformation]
        public Ws_CreateCard ProviderLog(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<Ws_CreateCard>(table).First();
        }


        [StepArgumentTransformation]
        public BankWiresInTemp BankWiresInTempConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<BankWiresInTemp>(table).First();
        }

        [StepArgumentTransformation]
        public CreateWire CreateWireConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<CreateWire>(table).First();
        }

        [StepArgumentTransformation]
        public BankWireInRequest BankWireInRequestConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<BankWireInRequest>(table).First();
        }
        


      [StepArgumentTransformation]
        public Ws_Update_Cardholder_Details ProviderLogUpdateCardHolderDetails(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<Ws_Update_Cardholder_Details>(table).First();
        }

        [StepArgumentTransformation]
        public Ws_CardHolder_Details_Enquiry_V2Result ProviderLogCardHolderDetailsEnquiryV2(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<Ws_CardHolder_Details_Enquiry_V2Result>(table).First();
        }

        [StepArgumentTransformation]
        public EditUserReferenceRequest EditUserReferenceRequestConverter(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<EditUserReferenceRequest>(table).First();
        }

        [StepArgumentTransformation]
        public BonusProgramClients BonusProgramClientsConverter(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<BonusProgramClients>(table).First();
        }

        [StepArgumentTransformation]
        public UIIdentityConfirmation VerifyIdentityConverter(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<UIIdentityConfirmation>(table).First();
        }

  

        [StepArgumentTransformation]
        public ExpectedSanctionCheck ExpectedSanctionCheck(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<ExpectedSanctionCheck>(table).First();
        }

        [StepArgumentTransformation]
        public List<ExpectedSanctionCheck> ExpectedSanctionCheckList(Table table)
        {
            return ConvertTable<ExpectedSanctionCheck>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedMassPaymentTemplates> MassPaymentTemplatesConvert(Table table)
        {
            return ConvertTable<ExpectedMassPaymentTemplates>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedPaymentTemplates> PaymentTemplatesConvert(Table table)
        {
            return ConvertTable<ExpectedPaymentTemplates>(table).ToList();
        }

        [StepArgumentTransformation]
        public UISecretDetails SecretDetails(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<UISecretDetails>(table).First();
        }

        [StepArgumentTransformation]
        public List<ExpectedFraudOperationCheckLog> FraudOperationCheckLogs(Table table)
        {
            return ConvertTable<ExpectedFraudOperationCheckLog>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UITransactionsList> TransactionList(Table table)
        {
            return ConvertTable<UITransactionsList>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UIWMPaymentTable> WMMassPayment(Table table)
        {
            return ConvertTable<UIWMPaymentTable>(table).ToList();
        }
        
        [StepArgumentTransformation]
        public UIBusinessDetails UIBusinessDetailsConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<UIBusinessDetails>(table).First();
        }


        [StepArgumentTransformation]
        public List<UIPartnerLinksTable> PartLink(Table table)
        {
            return ConvertTable<UIPartnerLinksTable>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UIMinMaxFeeTableMassPayment> WMMassPaymentConvert(Table table)
        {
            return ConvertTable<UIMinMaxFeeTableMassPayment>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UITable> ConfirmCardOrder(Table table)
        {
            return ConvertTable<UITable>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UIInternalPaymentReceiverTable> InternalPaymentReceiverConvert(Table table)
        {
            return ConvertTable<UIInternalPaymentReceiverTable>(table).ToList();
        }

        [StepArgumentTransformation]
        public EWalletSection EWalletSections(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<EWalletSection>(table).First();
        }

        [StepArgumentTransformation]
        public EPACardsSection EpaCardsSection(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<EPACardsSection>(table).First();
        }

        [StepArgumentTransformation]
        public List<UIAvailableForPaymentTable> AvailableForPaymentTableConvert(Table table)
        {
            return ConvertTable<UIAvailableForPaymentTable>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<UIInternalPaymentFeeTable> InternalPaymentFeesConvert(Table table)
        {
            return ConvertTable<UIInternalPaymentFeeTable>(table).ToList();
        }

        [StepArgumentTransformation]
        public UIUserPersonalDetails UIUserPersonalDetails(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<UIUserPersonalDetails>(table).First();
        }
        

        [StepArgumentTransformation]
        public ExpectedInvoicePosition[] ExpectedInvoicePositionConvert(Table table)
        {
            return ConvertTable<ExpectedInvoicePosition>(table).ToArray();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedUITestPurseTransaction> ExpectedUITestPurseTransactionConvert(Table table)
        {
            return ConvertTable<ExpectedUITestPurseTransaction>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedExternalTransaction> ExpectedExternalTransactionConvert(Table table)
        {
            return ConvertTable<ExpectedExternalTransaction>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedLimitRecord> ExpectedLimitRecordConvert(Table table)
        {
            return ConvertTable<ExpectedLimitRecord>(table).ToList();
        }


        [StepArgumentTransformation]
        public IEnumerable<Invoice> InvoiceConvert(Table table)
        {
            return ConvertTable<Invoice>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<ExpectedInvoice> ExpectedInvoiceConvert(Table table)
        {
            return ConvertTable<ExpectedInvoice>(table).ToList();
        }


        [StepArgumentTransformation]
        public Invoice InvoiceSingleConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<Invoice>(table).First();
        }

        [StepArgumentTransformation]
        public IEnumerable<InvoicePosition> InvoicePositionConvert(Table table)
        {
            return ConvertTable<InvoicePosition>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<EpaZendeskUser> EpaZendeskUserConvert(Table table)
        {
            return ConvertTable<EpaZendeskUser>(table).ToList();
        }

        [StepArgumentTransformation]
        public CardDetails CardDetailsConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<CardDetails>(table).First();
        }

        [StepArgumentTransformation]
        public ExpectedUser UserConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<ExpectedUser>(table).First();
        }
     

        [StepArgumentTransformation]
        public IEnumerable<EpaUserZendeskTicket> UserZendeskTicketConvert(Table table)
        {
            return ConvertTable<EpaUserZendeskTicket>(table).ToList();
        }

        [StepArgumentTransformation]
        public IEnumerable<UserAttachment> UserAttachmentConvert(Table table)
        {
            return ConvertTable<UserAttachment>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<Card> CardConvert(Table table)
        {
            return ConvertTable<Card>(table).ToList();
        }


        [StepArgumentTransformation]
        public List<ExpectedCards> ExpectedCardsConvert(Table table)
        {
            return ConvertTable<ExpectedCards>(table).ToList();
        }

        [StepArgumentTransformation]
        public Card Card(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<Card>(table).First();
        }


        [StepArgumentTransformation]
        public IEnumerable<CardServicePeriods> CardServicePeriodsConvert(Table table)
        {
            return ConvertTable<CardServicePeriods>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<CardTransaction> CardTransactionConvert(Table table)
        {
            return ConvertTable<CardTransaction>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<ExpectedNotification> ExpectedNotificationConvert(Table table)
        {
            return ConvertTable<ExpectedNotification>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<ExpectedConfirmationCode> ExpectedConfirmationConvert(Table table)
        {
            return ConvertTable<ExpectedConfirmationCode>(table).ToList();
        }

        [StepArgumentTransformation]
        public List<ExpectedNotificationWithBody> ExpectedNotificationWithBodyConvert(Table table)
        {
            return ConvertTable<ExpectedNotificationWithBody>(table).ToList();
        }


        [StepArgumentTransformation]
        public ExpectedConfirmationCode ExpectedConfirmCodeConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<ExpectedConfirmationCode>(table).First();
        }

        [StepArgumentTransformation]
        public PersonalData PersonalDataConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<PersonalData>(table).First();
        }

        [StepArgumentTransformation]
        public TicketComment TicketCommentConvert(Table table)
        {
            table.Rows.Count.Should().Be(1, "Should be single instance");
            return ConvertTable<TicketComment>(table).First();
        }

    }
}