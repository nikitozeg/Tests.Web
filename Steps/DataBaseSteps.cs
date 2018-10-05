using ePayments.Tests.Checkers;
using ePayments.Tests.Checkers.ExpectedObjects;
using ePayments.Tests.Common.Extensions;
using ePayments.Tests.Data.Domain.Ehi;
using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Data.Domain.Poco;
using ePayments.Tests.Data.Repositories;
using ePayments.Tests.Di;
using ePayments.Tests.Web.CatalogContext;
using ePayments.Tests.Web.Checkers;
using ePayments.Tests.Web.Data;
using ePayments.Tests.Web.Steps.Zendesk;
using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Xml.Serialization;
using TechTalk.SpecFlow;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Биндинги степов для работы с БД
    /// </summary>
    [Binding]
    public class DataBaseSteps
    {
        protected CardTransactionRepository _cardTransactionRepository;

        public ConfirmationCodeRepository _confirmationCodeRepository;

        public CardRepository _cardRepository;

        public UserRepository _userRepository;

        public AddressRepository _addressRepository;

        protected EpaZendeskUserRepository _epaZendeskUserRepository;

        protected UserAttachmentRepository _userAttachmentRepository;

        public PersonalDataRepository _personalDataRepository;

        protected ProviderOperationRepository ProviderOperationRepository;

        public InvoiceRepository _invoiceRepository;

        protected PurseTransactionRepository _purseTransactionRepository;

        protected PurseTransactionChecker _purseTransactionChecker;

        public ConfirmationCodeChecker _confirmationCodeChecker;

        protected LimitRecordChecker _limitRecordChecker;

        protected ExternalTransactionChecker _externalTransactionChecker;

        protected ExternalTransactionRepository _externalTransactionRepository;

        protected CurrencyRateHistoryRepository _currencyRateHistoryRepository;

        protected InvoicePositionRepository _invoicePositionRepository;

        protected PurseRepository _purseRepository;

        protected PurseSectionRepository _purseSectionRepository;

        public CountriesRepository _VATRepository;

        public BonusProgramClientsRepository _bonusProgramRepository;

        public EhiLogRepository _ehiLogRepository;

        public NotificationChecker _notificationChecker = new NotificationChecker();

        public ConfirmationCodeChecker _confirmationChecker;

        public InvoiceChecker _invoiceChecker;

        public SanctionCheckChecker _sanctionCheckChecker;

        public ServiceAvailabilityRepository _serviceAvailabilityRepository;

        public BankWireOutRepository _banksWireOutRepository;

        public BankWireInRepository _banksWireInRepository;

        public BankWiresInTempRepository _banksWiresInTempRepository;

        public SanctionCheckRepository _sanctionCheckRepository;

        public BankAccountRepository _bankAccountRepository;

        public FraudOperationLogRepository _fraudoperationLogRepository;

        public FraudOperationCheckLogsRepository _fraudoperationCheckLogsRepository;

        public FraudOperationCheckRepository _fraudoperationCheckRepository;

        public MassPaymentTemplatesChecker _masspaymentTemplatesChecker;

        public MassPaymentTemplatesRepository _massPaymentTemplatesrepository;

        public CardLoadQueueProcessedRepository _cardLoadQueueProcessedRepository;

        public PurseSpecialSectionRepository _purseSpecialSectionRepository;
        private decimal factAmountFromEarthPort;


        private static ExpectedInvoicePosition[] _expInvPositions;
        private readonly Context _context;

        /// <summary>
        /// Context injection (for sharing data between classes) and init repos
        /// </summary>
        /// <param name="context">Passed context</param>
        public DataBaseSteps(Context context)
        {
            _context = context;
            var container = DiUtils.GetContainer();

            _cardTransactionRepository = container.GetInstance<CardTransactionRepository>();
            _cardRepository = container.GetInstance<CardRepository>();
            _userRepository = container.GetInstance<UserRepository>();
            _addressRepository = container.GetInstance<AddressRepository>();
            _confirmationCodeRepository = container.GetInstance<ConfirmationCodeRepository>();
            _epaZendeskUserRepository = container.GetInstance<EpaZendeskUserRepository>();
            _userAttachmentRepository = container.GetInstance<UserAttachmentRepository>();
            _personalDataRepository = container.GetInstance<PersonalDataRepository>();
            ProviderOperationRepository = container.GetInstance<ProviderOperationRepository>();
            _invoiceRepository = container.GetInstance<InvoiceRepository>();
            _purseTransactionRepository = container.GetInstance<PurseTransactionRepository>();
            _purseTransactionChecker = container.GetInstance<PurseTransactionChecker>();
            _limitRecordChecker = container.GetInstance<LimitRecordChecker>();
            _externalTransactionChecker = container.GetInstance<ExternalTransactionChecker>();
            _currencyRateHistoryRepository = container.GetInstance<CurrencyRateHistoryRepository>();
            _invoicePositionRepository = container.GetInstance<InvoicePositionRepository>();
            _purseRepository = container.GetInstance<PurseRepository>();
            _VATRepository = container.GetInstance<CountriesRepository>();
            _purseSectionRepository = container.GetInstance<PurseSectionRepository>();
            _bonusProgramRepository = container.GetInstance<BonusProgramClientsRepository>();
            _ehiLogRepository = container.GetInstance<EhiLogRepository>();
            _serviceAvailabilityRepository = container.GetInstance<ServiceAvailabilityRepository>();
            _banksWireOutRepository = container.GetInstance<BankWireOutRepository>();
            _banksWireInRepository = container.GetInstance<BankWireInRepository>();
            _banksWiresInTempRepository = container.GetInstance<BankWiresInTempRepository>();
            _sanctionCheckRepository = container.GetInstance<SanctionCheckRepository>();
            _bankAccountRepository = container.GetInstance<BankAccountRepository>();
            _fraudoperationLogRepository = container.GetInstance<FraudOperationLogRepository>();
            _fraudoperationCheckRepository = container.GetInstance<FraudOperationCheckRepository>();
            _fraudoperationCheckLogsRepository = container.GetInstance<FraudOperationCheckLogsRepository>();
            _masspaymentTemplatesChecker = container.GetInstance<MassPaymentTemplatesChecker>();
            _massPaymentTemplatesrepository = container.GetInstance<MassPaymentTemplatesRepository>();
            _cardLoadQueueProcessedRepository = container.GetInstance<CardLoadQueueProcessedRepository>();
            _purseSpecialSectionRepository = container.GetInstance<PurseSpecialSectionRepository>();
        }

      
        public void WaitDbRecordInCardTransaction(String id)
        {
            int timeout = 0;

            while (true)
            {
                if (_cardTransactionRepository.GetTransactionsByOriginalLink(id).Count() == 1)
                {
                    break;
                }
                Thread.Sleep(TimeSpan.FromSeconds(1));

                if (timeout > 10)
                    Assert.True(false, "Timeout while waiting transaction appears");

                timeout++;
            }
        }


        public Card GetCardByToken(string token)
        {
            return _cardRepository.GetCardByToken(token);
        }


        #region DB UPDATE 

        [Then(@"Mark cardload as failed")]
        public void ThenMarkCardloadAsFailed()
        {
            _cardLoadQueueProcessedRepository.UpdateCardLoadStatus(_context.OperationGuid.Value,false);
        }


        [Then(@"ServiceAvailability '(.*)' set to true")]
        public void ServiceAvailabilitySet(string serviceName)
        {
            _serviceAvailabilityRepository.SetAvailability(serviceName, true);
        }


        [Then(@"User updates records in table 'CardTransaction':")]
        public void WhenUserUpdatesRecordsInCardTransaction(List<CardTransaction> rows)
        {
            rows[0].OriginalLink = _context.Trans_link;
            foreach (var row in rows)
            {
                row.Created = DateTime.Today.AddSeconds(-1);
                WaitDbRecordInCardTransaction(row.OriginalLink);
                var updatedRows =
                    _cardTransactionRepository.UpdateCreatedDateByOriginalLink(row.OriginalLink, row.Created);
                Assert.True(updatedRows == 1, $"Updated rows !=1 for OriginalLink = {row.OriginalLink}");
            }
        }

        [Then(@"User updates records in table 'CardServicePeriods':")]
        public void WhenUserUpdatesRecordsInCardServicePeriods(IEnumerable<CardServicePeriods> rows)
        {
            foreach (var row in rows)
            {
                row.StartDate = DateTime.Today.AddDays(-31);
                row.EndDate = DateTime.Today.AddDays(-1);
                var updatedRows =
                    _cardTransactionRepository.UpdateStartAndEndDatesByToken(row.Token, row.StartDate, row.EndDate);
                Assert.True(updatedRows > 0, $"Updated rows ={updatedRows} for token = {row.Token}");
            }
        }

        [Then(@"User updates records in table 'Invoices' for UserId=""(.*)"":")]
        public void WhenUserUpdatesInvoices(Guid userId, Invoice invoice )
        {
            _context.OperationGuid = GetLastInvoiceByUserId(userId).OperationGuid;

            invoice.PayDate = DateTime.Today.AddDays(-14);
            invoice.CreationDate = DateTime.Today.AddDays(-14);

            var updatedRows =
                    _invoiceRepository.UpdateCreationAndPayDates(_context.OperationGuid.Value,invoice);

                Assert.True(updatedRows > 0, $"Updated rows ={updatedRows} for token = { _context.OperationGuid }");
        }

        [Then(@"User updates records in table 'Cards' on '(CurrentDate|yesterday-1d time 00.00.00|CurrentDate[+]3days)':")]
        public void WhenUserUpdatesRecordsInCards(string date, List<Card> rows)
        {
            foreach (var row in rows)
            {

                switch (date)
                {
                    case "CurrentDate":
                        row.CardServiceExpireAt = DateTime.UtcNow.AddHours(1);
                        break;
                    case "yesterday-1d time 00.00.00":
                        row.CardServiceExpireAt = DateTime.Today.AddDays(-2);
                        break;
                    case "CurrentDate+3days":
                        row.CardServiceExpireAt = DateTime.Today.AddDays(3);
                        break; 
                }

                var updatedRows =
                    _cardRepository.UpdateCardServiceExpireAt(row.ProxyPANCode, row.CardServiceExpireAt.Value);
                Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");
            }
        }


        [Then(@"User updates records in table 'Cards' and set LastActivityDate to ""(.*)"":")]
        public void WhenUserUpdatesRecordsInCardsActivity(string dateOffset, Card row)
        {
            switch (dateOffset)
            {
                case "*today-7m-1d*":
                    row.LastActivityDate = DateTime.UtcNow.ToLocalTime().AddMonths(-7).AddDays(-1);
                    break;
                case "*today-7m-7d*":
                    row.LastActivityDate = DateTime.UtcNow.ToLocalTime().AddMonths(-7).AddDays(-7);
                    break;

            }
           
                var updatedRows =
                    _cardRepository.UpdateLastActivityDate(row.ProxyPANCode, row.LastActivityDate);
                Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");
            
        }

        [Then(@"User updates records in table 'Cards' and set ActivationDate to ""(.*)"":")]
        public void WhenUserUpdatesRecordsInCardsActivationDate(string dateOffset, Card row)
        {
            switch (dateOffset)
            {
                case "*today-6m*":
                    row.ActivationDate = DateTime.UtcNow.ToLocalTime().AddMonths(-6);
                    break;
                case "*today-7m+7d*":
                    row.ActivationDate = DateTime.UtcNow.ToLocalTime().AddMonths(-7).AddDays(7);
                    break;
            }

            var updatedRows =
                _cardRepository.UpdateActivationDate(row.ProxyPANCode, row.ActivationDate.Value);
            Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");

        }

        [Then(@"User updates records in table 'Cards' and set LastDebitForInactivityDate to ""(.*)"":")]
        public void WhenUserUpdatesRecordsCards(string dateOffset, Card row)
        {

            switch (dateOffset)
            {
                case "*today*":
                    row.LastDebitForInactivityDate = DateTime.Today;
                    break;

            }

            var updatedRows =
                _cardRepository.UpdateLastDebitForInactivityDate(row.ProxyPANCode, row.LastDebitForInactivityDate);
            Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");

        }

        [Then(@"User updates records in table 'Cards' and set CardServicePaid:")]
        public void WhenUserUpdatesCardServicePaid( Card row)
        {

            var updatedRows =
                _cardRepository.UpdateCardServicePaid(row.ProxyPANCode, row.CardServicePaid.Value);

            Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");

        }

        [Then(@"User updates records in table 'Cards' and set CardServicePeriod:")]
        public void WhenUserUpdatesCardServicePeriod(Card row)
        {

            var updatedRows =
                _cardRepository.UpdateCardServicePeriod(row.ProxyPANCode, row.CardServicePeriod);

            Assert.True(updatedRows == 1, $"Updated rows !=1 for token = {row.ProxyPANCode}");

        }



        [Then(@"User updates balance=""(.*)"" ""(.*)"" in table 'TPurseSections' for created user")]
        public void WhenUserUpdatesBalanceInCards(decimal balance, Currency currency)
        {
            _purseSectionRepository.SetBalance(balance, _context.UserId, currency);
        }

        [Then(@"Operator set address verified for created user")]
        public void WhenOperatorSetAddressVerifieds()
        {
            _addressRepository.SetAddressVerified(_context.UserId);
        }

        [Then(@"User updates last comment in table 'EpaUserZendeskTicket' on comment='(.*)':")]
        public void WhenUserUpdatesRecordsInEpaUserZendeskTicket(string updateOn)
        {
            _epaZendeskUserRepository.UpdateUpdatedAt(_context.TicketsIDList.ToList().Last(), ZendeskSteps.GetCommentDateByText(updateOn).AddHours(-3));
            _epaZendeskUserRepository.UpdateLastMessage(_context.TicketsIDList.ToList().Last(), updateOn);
        }

        [Then(@"User updates TransactionConfirmationType=""(.*)"" for UserId=""(.*)"" in table 'TUsers'")]
        public void WhenUserUpdatesTransactionConfirmationType( TransactionConfirmationType type, Guid userId)
        {
            _userRepository.UpdateTransactionConfirmationType(userId,type);
        }

        [Then(@"User updates SpecialBalance=""(.*)"" ""(.*)"" in table 'TUsers' for created user")]
        public void WhenUserUpdatesSpecialBalance( int amount, Currency currency)
        {
            var userPurseSections=_purseSectionRepository.FindByUserId(_context.UserId);

            _purseSpecialSectionRepository.Add(new PurseSpecialSection
            {
                PurseSectionId = userPurseSections.Where(it=>it.CurrencyId.Equals((int)currency)).Single().PurseSectionId,
                UserId = _context.UserId,
                SpecialBalance = amount,
                CurrencyId = Currency.Usd,
                SpecialBalanceHold = 0,
                OperationTypeId = 20,
                LastUpdatedDate = DateTime.UtcNow
            });

        }
        #endregion

        #region DB DELETE

        [Then(@"User deletes records in table 'EpaZendeskUser':")]
        public void WhenUserDeletesRecordsInEpaZendeskUser(IEnumerable<EpaZendeskUser> rows)
        {
            foreach (var row in rows)
            {
                _epaZendeskUserRepository.DeleteByEpaId(row.EpaId);
            }
        }

        [Then(@"User deletes records in table 'EpaUserZendeskTicket':")]
        public void WhenUserDeletesRecordsInEpaUserZendeskTicket(IEnumerable<EpaUserZendeskTicket> rows)
        {
            foreach (var row in rows)
            {
                _epaZendeskUserRepository.DeleteByEpaUserId(row.EpaUserId);
            }
        }

        #endregion

        #region DB SELECT

        public IEnumerable<BankWireOut> GetBankWireOut(Guid userId)
        {
            return _banksWireOutRepository.GetByUserId(userId);
        }

        public IEnumerable<BankWiresInTemp> GetBankWiresInTemp(string beneficiaryAccountNumber)
        {
            return _banksWiresInTempRepository.GetByReference(beneficiaryAccountNumber);
        }

        [Then(@"User gets record in 'EhiLog' where Token=""(.*)""")]
        public IEnumerable<EhiLog> GetEhiLogByToken(string token)
        {
            var Txn_ID = _ehiLogRepository.GetByCardToken(token, _context.StartDate);
            _context.Auth_TXn_ID = Txn_ID.First().Txn_ID;
            return Txn_ID;
        }

        public IEnumerable<PurseTransaction> GetPurseTransactionsByUserId(string UserId)
        {
            if (_context.StartDate == null)
            {
                throw new Exception("StarDate is not assigned");
            }

            return _purseTransactionRepository.FindBy("UserId", UserId).Where(t => t.CreationDate >= _context.StartDate);
        }

        [Then(@"No records in 'TPurseTransactions'")]
        public void NoTPurseTransactions()
        {
              _purseTransactionChecker.ClearExpected();
              _purseTransactionChecker.AssertAll(_context.OperationGuid.Value);
        }

        [Then(@"No records in 'LimitRecords'")]
        public void NoLimitRecords()
        {
            _limitRecordChecker.ClearExpected();
            _limitRecordChecker.AssertAll(_context.OperationGuid.Value);
        }


        [Then(@"No new records in 'TExternalTransactions'")]
        [Then(@"No records in 'TExternalTransactions'")]
        public void NoRecordsInTExternalTransactions()
        {
            WhenUserSelectsTExternalTransactions(new List<ExpectedExternalTransaction>());
        }

       

        [Then(@"User selects records in 'TPurseTransactions' for incoming wire where BeneficiaryAccountNumber=""(.*)"":")]
        public void WhenUserSelectsTPurseTransactionsIncomingWire( string receiver,IEnumerable<ExpectedUITestPurseTransaction> expectedList)
        {
            _context.OperationGuid = _banksWireInRepository
                    .GetByBeneficiaryAccountNumber(receiver)
                    .Where(it => it.CreationDate > _context.StartDate).Single().OperationGuid;

            WhenUserSelectsTPurseTransactions("", expectedList);
        }

        [Then(@"User selects records in 'TPurseTransactions' for undefined wire:")]
        public void WhenUserSelectsTPurseTransactionsUndefinedWire(IEnumerable<ExpectedUITestPurseTransaction> expectedList)
        {
            WhenUserSelectsTPurseTransactions("", expectedList);
        }

        [Then(@"New records appears in 'TPurseTransactions' for UserId=""(.*)"":")]
        [Then(@"User selects records in 'TPurseTransactions' by last OperationGuid where UserId=""(.*)"":")]
        public void WhenUserSelectsTPurseTransactions(string UserId, IEnumerable<ExpectedUITestPurseTransaction> expectedList)
        {
            // Check if OperationGiud is not assigned
            if (_context.OperationGuid == null)
            {
                _context.OperationGuid = GetPurseTransactionsByUserId(UserId).OrderByDescending(it => it.CreationDate)
                    .First().OperationGuid;
            }

            expectedList = CommonComponentHelper.ReplaceTable(expectedList.ToList(), _context.Rate, _context.Amount);

            //Getting PurseSectionId instead of CurrencyId
            _purseTransactionChecker.AddExpected(
                expectedList.ToList().Select(e => new ExpectedPurseTransaction
                    {
                        Amount = e.Amount,
                        DestinationId = e.DestinationId,
                        Direction = e.Direction,
                        UserId = e.UserId,
                        PurseSectionId = _purseSectionRepository.FindByPurseId(e.PurseId, e.CurrencyId).PurseSectionId,
                        PurseId = e.PurseId,
                        RefundCount = e.RefundCount
                    }).ToArray())
                .AssertAll(_context.OperationGuid.Value);
        }

        [Then(@"User selects records in 'TPurseTransactions' by last OperationGuid where UserId=""(.*)"" for EarthPort with ""(.*)""")]
        public void WhenUserSelectsTPurseTransactionsForEarthPort(string UserId, Guid systemPurseUserId, IEnumerable<ExpectedUITestPurseTransaction> expectedList)
        {
            factAmountFromEarthPort = _purseTransactionRepository.GetByOperationGuid(_context.OperationGuid.Value).Where(it=> it.DestinationId == PurseTransactionDestination.WireOut 
                                                                                                             && it.UserId.Equals(systemPurseUserId)
                                                                                                             && it.Direction.Equals("out")).Single().Amount;

            //Replace expectedList.Amount on fact values
            expectedList.Select(x =>
            {
                if (x.DestinationId == PurseTransactionDestination.WireOut
                    && x.UserId.Equals(systemPurseUserId)
                    && x.Direction.Equals("out"))
                {
                    x.Amount = factAmountFromEarthPort;
                }

                if (x.DestinationId == PurseTransactionDestination.ExternalCurrencyExchangeLoss)
                {
                    x.Amount = factAmountFromEarthPort - _context.Amount;
                }

                x.Amount.Should().BePositive();
                return x;
            }).ToList();


            WhenUserSelectsTPurseTransactions(UserId, expectedList);

        }


        [Given(@"Reset checkers")]
        public void GivenResetCheckers()
        {
                _invoiceChecker?.ClearExpected();
                 _purseTransactionChecker?.ClearExpected();
                _limitRecordChecker?.ClearExpected();
                _externalTransactionChecker?.ClearExpected();
        }


        [Given(@"Check (.*) of (.*) transaction for last BatchOperationGuid where UserId=""(.*)"" and ReceiverIdentity=""(.*)""")]
        public void GivenCheckTransaction(int row, int count, Guid userId, string receiverIdentity)
        {
           var batchGuid= GetLastInvoiceByUserId(userId).BatchOperationGuid;
            
           var invoicesList= _invoiceRepository.GetByBatchOperationGuid(batchGuid);

           invoicesList.Count().Should().Be(count);
            
           _context.OperationGuid = invoicesList
                                        .Where(it => it.ReceiverIdentity.EqualsIgnoreSpaceAndCase(receiverIdentity))
                                        .FirstOrDefault()
                                        .OperationGuid;
        }
        
  
        [Then(@"User selects records in 'LimitRecords' by last OperationGuid where UserId=""(.*)"":")]
        public void WhenUserSelectsLimitRecords(string UserId, IEnumerable<ExpectedLimitRecord> expectedList)
        {
            expectedList = CommonComponentHelper.ReplaceTable(expectedList.ToList(), _context.Rate, _context.Amount);
            var expectedAmountInUsd = GetAmountInUsd(expectedList.First().CurrencyId, expectedList.First().Amount.Value ).RoundBank();
            
            //Replace expectedList with expectedAmountInUsd
            expectedList.ToList().ForEach(it=> it.AmountInUsd = expectedAmountInUsd);

            _limitRecordChecker.ClearExpected();
            _limitRecordChecker.AddExpected(expectedList.ToArray()).AssertAll(_context.OperationGuid.Value);
        }

        public decimal GetAmountInUsd(Currency sell, decimal amount)
        {
            decimal quote;

            if (sell == Currency.Usd)
            {
                return amount;
            }

            //Taking actual currency on operation time
             quote = _currencyRateHistoryRepository
                .GetRateHistoryInfo(sell, Currency.Usd, _context.StartDate.Value).Rate;

            return amount * quote;
        }

        [Then(@"User selects records in 'TExternalTransactions' for UndefinedWire")]
        public void RecordsInTExternalTransactionsForUndefinedWire(IEnumerable<ExpectedExternalTransaction> expectedList)
        {
            WhenUserSelectsTExternalTransactions(expectedList);
        }


        [Then(@"User selects records in 'TExternalTransactions' by OperationGuid")]
        public void WhenUserSelectsTExternalTransactions(IEnumerable<ExpectedExternalTransaction> expectedList)
        {
            expectedList = CommonComponentHelper.ReplaceTable(expectedList.ToList(), _context.Rate, _context.Amount);
            _externalTransactionChecker.AddExpected(expectedList.ToArray()).AssertAll(_context.OperationGuid.Value);
        }

        [Then(@"User selects records in 'TExternalTransactions' by OperationGuid for EarthPort")]
        public void WhenUserSelectsTExternalTransactionsEarthPort(IEnumerable<ExpectedExternalTransaction> expectedList)
        {
            expectedList.Single().Amount = factAmountFromEarthPort;
            WhenUserSelectsTExternalTransactions(expectedList);
        }

        [Then(@"Preparing records in 'InvoicePositions':")]
        [Then(@"And records in 'InvoicePositions' for created user by phone:")]
        public static void ThenAndRecordsInForCreatedUserByPhone(ExpectedInvoicePosition[] expectedList)
        {
            _expInvPositions = expectedList;
        }


        [Then(@"Get Invoice Id for UserId=""(.*)""")]
        public Invoice GetLastInvoiceByUserId(Guid UserId)
        {
            if (_context.StartDate==null)
            {
                throw new Exception("StarDate is not assigned");
            }

        return _invoiceRepository.FindBy("UserId", UserId)
                .Where(t => t.CreationDate >= _context.StartDate)
                .OrderBy(it => it.CreationDate).Last();
        }

      

        [Then(@"User selects records in 'Invoices' for created user by email with replacing fields:")]
        public void WhenUserSelectsRecordsInvoicesWithReplacingFields(IEnumerable<ExpectedInvoice> expectedInvoice)
        {
            _context.UserId = _userRepository.GetByUserEmail(_context.Email).UserId;

            foreach (var invoice in expectedInvoice)
            {
               invoice.UserId=_context.UserId;
                invoice.SenderIdentity = _purseRepository.GetPurses(_context.UserId).First().Id.ToString("000-000000");
            } 

            _context.OperationGuid = GetLastInvoiceByUserId(_context.UserId).OperationGuid;

            WhenUserSelectsInvoices(_context.UserId, expectedInvoice);
        }

        [Then(@"User selects records in 'Invoices' for created user by email:")]
        public void WhenUserSelectsRecordsInvoicesByEmail(IEnumerable<ExpectedInvoice> expectedInvoice)
        {
            _context.UserId = _userRepository.GetByUserEmail(_context.Email).UserId;

            foreach (var invoice in expectedInvoice)
            {
                invoice.UserId = _context.UserId;
            }

            _context.OperationGuid = GetLastInvoiceByUserId(_context.UserId).OperationGuid;

            WhenUserSelectsInvoices(_context.UserId, expectedInvoice);
        }

        //ToDo Temporarily hack because of EPA-6127
        [Then(@"User selects last record in 'Invoices and InvoicePositions' where UserId=""(.*)"" with ExternalTransaction:")]
        public void WhenUserSelectsInvoicesWithExtTransaction(Guid UserId, IEnumerable<ExpectedInvoice> expectedList)
        {
            // ToDo требования к полю собираются. Пока мы не можем проверять поле к которому нет явных требований
            //expectedList.First().ExternalTransaction = GetLastInvoiceByUserId(UserId).InvoiceId.ToString();
            //WhenUserSelectsInvoices(UserId, expectedList);
        }

        [Then(@"User selects last record in 'Invoices and InvoicePositions' where UserId=""(.*)"":")]
        public void WhenUserSelectsInvoices(Guid UserId, IEnumerable<ExpectedInvoice> expectedList)
        {
            _invoiceChecker = new InvoiceChecker();

            var actualList = GetLastInvoiceByUserId(UserId);


            // Check if OperationGiud is not assigned
            if (_context.OperationGuid == null)
            {
                _context.OperationGuid = actualList.OperationGuid;
            }
    
            _context.UserId = actualList.UserId;

            expectedList.First().Positions = _expInvPositions;

            _invoiceChecker.AddExpected(expectedList.ToArray()).AssertAll(_context.OperationGuid.Value);
        }

        [Then(@"Wait invoice closing with (.*) sec timeout for UserId=""(.*)""")]
        public void WhenUserInvoicesClosing(int timeout, Guid userId)
        {
            _context.UserId = userId;
            _context.OperationGuid = GetLastInvoiceByUserId(_context.UserId).OperationGuid;

            int counter = 0;

            while (!(_invoiceRepository.GetByOperationGuid(_context.OperationGuid.Value).Single().State == InvoiceState.Successed))
             {
                 Thread.Sleep(1000);

                 if (counter > timeout)
                 {
                     Assert.True(false, "Timeout while waiting transaction appears");
                 }

                 counter++;
             }
        }

        [Then(@"User selects records in 'Cards' for created user with replacing ProxyPANCode:")]
        public void WhenUserSelectsRecordsUsersWithReplacing(List<ExpectedCards> expectedList)
        {
            foreach (var expectedCards in expectedList)
            {
                expectedCards.ProxyPANCode = _context.Token;
            }

            WhenUserSelectsRecordsUsersWithSanction(expectedList);
        }

        /// <summary>
        /// Select and check records in table Cards by ID in Context
        /// </summary>
        [Then(@"User selects records in 'Cards' for created user:")]
        public void WhenUserSelectsRecordsUsers(List<ExpectedCards> expectedList)
        {
            foreach (var expectedCard in expectedList)
            {
                expectedCard.ProxyPANCode = _context.Token;
                SetActivationAndExpireDate(expectedCard);
            }

            WhenUserSelectsRecordsUsersWithSanction(expectedList);
        }
        
        /// <summary>
        /// Select and check records in table Cards by ID in Context
        /// </summary>
        [Then(@"User selects records in 'Cards' for created user with not-activated card:")]
        public void WhenUserSelectsRecordsUsersWithSanction(List<ExpectedCards> expectedList)
        {
            var actualList = _cardRepository.FindBy("UserId", _context.UserId);
            CheckTCards(actualList,expectedList);
        }

        [Then(@"User selects records in 'Cards' for created user with blocked card and ManualRequest:")]
        public void CheckBlockedCardWithManualRequest(List<Card> expectedList)
        {
            var actualList = _cardRepository.FindBy("UserId", _context.UserId);

            var firstCard = actualList.Where(it => it.CreationType.ToString().EqualsIgnoreSpaceAndCase("First")).First();
            var reissueCard = actualList.Where(it => it.CreationType.ToString().EqualsIgnoreSpaceAndCase("Reissue")).First();

            firstCard.ProxyPANCode.Should().HaveLength(9);
            reissueCard.ProxyPANCode.Should().BeNullOrEmpty();

            actualList.Select(
                    row => new
                    {
                        row.CardStateId,
                        row.MemorableName,
                        MemorableDate = row.MemorableDate.Value.Date,
                        row.MemorablePlace,
                        row.ActivationCode,

                        ActivationDate = row.ActivationDate.HasValue ? row.ActivationDate.Value.Date : (DateTime?)null,
                        CardServiceExpireAt = row.CardServiceExpireAt.HasValue ? row.CardServiceExpireAt.Value.Date : (DateTime?)null
                    })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "Card не соответствуют ожидаемым");
        }



        [Then(@"User selects records in 'Cards' for created user with blocked inactivated card and 2nd inactivated card:")]
        public void UserWithBlockedNotActiveAndReactivatedCard(List<ExpectedCards> expectedList)
        {
            var actualList = _cardRepository.GetByUserId(_context.UserId);

            SetProxyPanCode(expectedList);

            CheckTCards(actualList, expectedList);
        }

        [Then(@"User selects records in 'Cards' for created user with blocked and reactivated card:")]
        public void UserWithBlockedAndReactivatedCard(List<ExpectedCards> expectedList)
        {
            foreach (var expectedCard in expectedList)
            {
                if (expectedCard.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Active"))
                    SetActivationAndExpireDate(expectedCard);
            }

            UserWithBlockedCard(expectedList);
        }

        [Then(@"User selects records in 'Cards' for created user with blocked card:")]
        public void UserWithBlockedCard(List<ExpectedCards> expectedList)
        {
            var actualList = _cardRepository.GetByUserId(_context.UserId);
         
            foreach (var expectedCard in expectedList)
            {
                if (expectedCard.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Blocked"))
                    SetActivationAndExpireDate(expectedCard);
            }

            SetProxyPanCode(expectedList);

            CheckTCards(actualList, expectedList);
        }

        public void SetProxyPanCode(List<ExpectedCards> expectedList)
        {
            //Присваиваем заблокированной карте Токен, дату активации карты и дату истечения срока обслуживания
            // Присваиваем токен для карты в статусе Request (неактивированная)
            foreach (var expectedCard in expectedList)
            {
                if (expectedCard.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Blocked"))
                {
                    expectedCard.ProxyPANCode = GetProxyPANCodeByCreationType(_context.UserId, "First");
                }

                if (expectedCard.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Active") || expectedCard.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Request"))
                {
                    expectedCard.ProxyPANCode = GetProxyPANCodeByCreationType(_context.UserId, "Reissue");
                    
                }
            }
        }

        public string GetProxyPANCodeByCreationType(Guid userId, string creationType)
        {

            var proxyPANCode = _cardRepository.GetByUserId(userId)
                .Where(it => it.CreationType.ToString().EqualsIgnoreSpaceAndCase(creationType))
                .Single().ProxyPANCode;

            proxyPANCode.Should().HaveLength(9, "ProxyPANCode should exist");

            return proxyPANCode;
        }

        private void SetActivationAndExpireDate(ExpectedCards expectedCard)
        {
            expectedCard.ActivationDate = DateTime.UtcNow.Date;
            expectedCard.CardServiceExpireAt = DateTime.UtcNow.Date.AddMonths(2);
        }


        public void CheckTCards(IEnumerable<Card> actualList, List<ExpectedCards> expectedList)
        {
            actualList.Select(
                    row => new ExpectedCards
                    {
                        CardStateId = row.CardStateId,
                        ProxyPANCode = row.ProxyPANCode,
                        MemorableName = row.MemorableName,
                        MemorableDate = row.MemorableDate.Value.Date,
                        MemorablePlace = row.MemorablePlace,
                        ActivationCode = row.ActivationCode,

                        ActivationDate = row.ActivationDate.HasValue ? row.ActivationDate.Value.Date : (DateTime?)null,
                        CardServiceExpireAt = row.CardServiceExpireAt.HasValue ? row.CardServiceExpireAt.Value.Date : (DateTime?)null
                    })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "Card не соответствуют ожидаемым");
        }



        /// <summary>
        /// Select and check records in table SanctionCheck by userId
        /// </summary>
        [Then(@"User selects record in 'SanctionCheck' for created user:")]
        public void SelectsRecordsInSanctionCheckForCreatedUser(List<ExpectedSanctionCheck> expectedSanctionCheck)
        {
            WhenUserSelectsRecordsInSanctionCheck(_context.UserId, expectedSanctionCheck);
        }



        /// <summary>
        /// Select and check records in table SanctionCheck for created user
        /// </summary>
        [Then(@"No records in 'SanctionCheck' for created user")]
        public void NoRecordsInSanctionCheckForUser()
        {
            _sanctionCheckChecker = new SanctionCheckChecker(_context.StartDate);
            _sanctionCheckChecker.AssertAll(_context.UserId);
        }

        /// <summary>
        /// Select and check records in table SanctionCheck by userId
        /// </summary>
        [Then(@"User selects record in 'SanctionCheck' where UserId =""(.*)"":")]
        public void WhenUserSelectsRecordsInSanctionCheck(Guid userId, List<ExpectedSanctionCheck> expectedSanctionCheck)
        {
            _sanctionCheckChecker=new SanctionCheckChecker(_context.StartDate);

          

            _sanctionCheckChecker.AddExpected(expectedSanctionCheck.ToArray()).AssertAll(userId);

            //Get Request ID (Compliance assist)
            _context.RequestId = _sanctionCheckRepository
                .FindAllByUserId(userId)
                .Where(it=>it.ParentSanctionCheckId==null)
                .OrderByDescending(it => it.Id)
                .First().RequestId;

        }

        /// <summary>
        /// Select and check records in table Cards by token
        /// </summary>
        [Then(@"User selects record in 'Cards' where token =""(.*)"":")]
        public void WhenUserSelectsRecordsInCards(string token, Card expectedList)
        {
            expectedList.LastDebitForInactivityDate = DateTime.Today;

            var actualList = _cardRepository.GetCardByToken(token);
                    new
                     {
                         actualList.LastDebitForInactivityDate
                     }
                 .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.ExcludingMissingMembers(),
                    "Card не соответствуют ожидаемым");
        }

        /// <summary>
        /// <typeparam name="T">XML DTO</typeparam>
        /// <param name="method">Name of GPS method</param>
        /// <returns>UpdateCardHolderDetails</returns>
        /// <returns>CreateCard</returns>
        /// </summary>
        public T DeserializeXML<T>(string xml)
        {
            StreamReader sr = new StreamReader(new MemoryStream(Encoding.UTF8.GetBytes(xml)));
            XmlSerializer serializer = new XmlSerializer(typeof(T));
            T crCard = (T) serializer.Deserialize(sr);
            sr.Close();

            return (T) Convert.ChangeType(crCard, typeof(T));
        }


        [Then(
            @"User selects records in 'ProviderOperations' and check XML values in Request Ws_Update_Cardholder_Details:")]
        public void WhenUserSelectsRecordsInUpdateCardHolderDetails(Ws_Update_Cardholder_Details expectedList)
        {
            _context.CardId = _cardRepository.FindBy("UserId", _context.UserId)
                .Where(it => it.CardStateId.ToString().EqualsIgnoreSpaceAndCase("Request")).First().CardId;

            var providerOperationList = ProviderOperationRepository
                .GetLogByNameAndRequest("Ws_Update_Cardholder_Details", "%" + _context.PhoneNumber + "%");


            Assert.True(providerOperationList.First()
                    .Response.Contains("<ActionCode>000</ActionCode>"),
                "Action code != 000" + providerOperationList.First().Response);


            Ws_Update_Cardholder_Details ws =
                DeserializeXML<UpdateCardHolderDetails>(providerOperationList.First().Request)
                    .Body.Ws_Update_Cardholder_Details;

            new
                {
                    ws.dlvMethod,
                    ws.dlvaddr1,
                    ws.dlvaddr2,
                    ws.dlvaddr3,
                    ws.dlvcity,
                    ws.dlvcounty,
                    ws.dlvpostcode,
                    ws.dlvcountry,
                    ws.Delv_Code
                }
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.ExcludingMissingMembers(),
                    "Ws_Update_Cardholder_Details не соответствуют ожидаемым");
        }

        [Then(
            @"User selects records in 'ProviderOperations' and check XML values in Request Ws_CardHolder_Details_Enquiry_V2:")]
        public void WhenUserSelectsRecordsInCardHolderDetailsEnquiryV2(
            Ws_CardHolder_Details_Enquiry_V2Result expectedList)
        {
            var providerOperationList = ProviderOperationRepository
                .GetLogByNameAndResponse("Ws_CardHolder_Details_Enquiry_V2", "%" + _context.PhoneNumber + "%");

            Assert.True(providerOperationList.First()
                    .Response.Contains("<ActionCode>000</ActionCode>"),
                "Action code != 000" + providerOperationList.First().Response);

            Ws_CardHolder_Details_Enquiry_V2Result ws =
                DeserializeXML<CardHolderDetailsEnquiryV2>(providerOperationList.First().Response)
                    .Body.Ws_CardHolder_Details_Enquiry_V2Response.Ws_CardHolder_Details_Enquiry_V2Result;

            new
                {
                    ws.CrdDesign,
                    ws.ImageID,
                }
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.ExcludingMissingMembers(),
                    "Ws_CardHolder_Details_Enquiry_V2Result не соответствуют ожидаемым");
        }


        [Then(@"User selects records in 'ProviderOperations' and check XML values in Request Ws_CreateCard:")]
        public void WhenUserSelectsRecordsUserss(Ws_CreateCard expectedList)
        {
            var providerOperationList = ProviderOperationRepository
                .GetLogByNameAndRequest("Ws_CreateCard", "%" + _context.PhoneNumber + "%")
                .OrderByDescending(it => it.RequestDate);

            Assert.True(providerOperationList.First()
                    .Response.Contains("<ActionCode>000</ActionCode>"),
                "Action code != 000" + providerOperationList.First().Response);

            Ws_CreateCard ws = DeserializeXML<CreateCard>(providerOperationList.First().Request).Body.Ws_CreateCard;

            new Ws_CreateCard
                {
                    DelvMethod = ws.DelvMethod,
                    Delv_AddrL1 = ws.Delv_AddrL1,
                    Delv_AddrL2 = ws.Delv_AddrL2,
                    Delv_AddrL3 = ws.Delv_AddrL3,
                    Delv_City = ws.Delv_City,
                    Delv_County = ws.Delv_County,
                    Delv_PostCode = ws.Delv_PostCode,
                    Delv_Country = ws.Delv_Country,
                    Delv_Code = ws.Delv_Code,
                    ProductRef = ws.ProductRef,
                    ImageId = ws.ImageId,
                    CardDesign = ws.CardDesign,
                }
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.ExcludingMissingMembers(),
                    "Ws_CreateCard не соответствуют ожидаемым");

            _context.Token = providerOperationList.First().PublicToken.ToString();
        }

        [Then(@"User selects records in 'Ws_BulkCreation' and Request parameter ProductRef = NP")]
        public void WhenUserSelectsRecordsinBulkCreation()
        {
              var providerOperationList = ProviderOperationRepository
                 .GetLogByNameAndResponse("Ws_BulkCreation", "%" + _context.Token + "%");

            Assert.True(providerOperationList.First()
                    .Response.Contains("<ActionCode>000</ActionCode>"),
                "Action code != 000" + providerOperationList.First().Response);

            providerOperationList.First().Request.Should().Contain("<ProductRef>NP</ProductRef>");
        }

   
        /// <summary>
        /// Select and check records in table Users by ID in Context
        /// </summary>
        [Then(@"User selects records in 'Users' for created user( by phone|| by partner):")]
        public void WhenUserSelectsRecordsUsersByContext(string by, ExpectedUser expectedList)
        {
            expectedList.PasswordExpireAt = DateTime.UtcNow.Date.AddMonths(6);

            switch (by)
            {
                case " by phone":
                    CheckAndReturnTUsers(expectedList, _context.PhoneNumber);
                    break;
                case "":
                    CheckAndReturnTUsers(expectedList, _context.Email);
                    break;
                case " by partner":
                    expectedList.UserExternalCode = _context.UserExternalCode;
                    CheckAndReturnTUsers(expectedList, _context.Email);
                    break;

                default:
                    throw new Exception("No any case -branch for " + by);
            }
           

        }

        public User CheckAndReturnTUsers(ExpectedUser expectedUser, string id)
        {

            var createdUser = _userRepository.GetByUserEmail(id);
            _context.UserId = createdUser.UserId;

             new ExpectedUser
                 {
                     KYCId = createdUser.KYCId,
                     UserRole = createdUser.UserRole,
                     State = createdUser.State,
                     PasswordExpireAt = createdUser.PasswordExpireAt.Date,
                     IsPep = createdUser.IsPep,
                     UserExternalCode = createdUser.UserExternalCode
                 }
         .ShouldBeEquivalentTo(
                    expectedUser,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "Users не соответствуют ожидаемым");
            return createdUser;
        }

       

        /// <summary>
        /// Select and check records in table Users by ID in Context
        /// </summary>
        [Then(@"User selects records in 'PersonalData' for created user:")]
        public void ThenUserSelectsRecordsForCreatedUser(PersonalData expectedList)
        {
            expectedList.Email = _context.Email;
            expectedList.UserId = _context.UserId;
            expectedList.FirstName = _context.PersDetails.FirstName;
            expectedList.LastName = _context.PersDetails.LastName;
            expectedList.MobilePhone = _context.PhoneNumber;

            var actualList = _personalDataRepository.FindBy("UserId", _context.UserId).Select(
                row => new
                {
                    row.Email,
                    row.MobilePhone,
                    row.FirstName,
                    row.LastName,
                    BirthDate = row.BirthDate.Date,
                    row.CitizenShipCountryId,
                    row.ResidenceCountryId,
                    row.Gender
                });

            actualList.First().ShouldBeEquivalentTo(
                expectedList,
                options => options.WithStrictOrdering().ExcludingMissingMembers(),
                "PersonalData не соответствуют ожидаемым");
        }

        [Then(@"User selects records in table 'BonusProgramClients' for created user:")]
        public void ThenUserSelectsRecordsInTableForCreatedUser(BonusProgramClients expected)
        {
            var actualList = _bonusProgramRepository.FindBy("ClientId", _context.UserId).Select(
                row => new
                {
                    row.BonusRefOwnerId,
                    row.IsActive,
                    row.UtmSource,
                    row.UtmMedium,
                    row.UtmTerm,
                    row.UtmContent,
                    row.UtmCampaign,
                    row.LinkType,
                    row.Link
                });

            actualList.First().ShouldBeEquivalentTo(
                expected,
                options => options.WithStrictOrdering().ExcludingMissingMembers(),
                "BonusProgramClients не соответствуют ожидаемым");
        }

        [Then(@"User selects records in table 'EpaZendeskUser' for created by promo card form user:")]
        [Then(@"User selects records in table 'EpaZendeskUser' for created business user:")]
        public void WhenUserSelectsRecordsEpaZendeskUser(IEnumerable<EpaZendeskUser> expectedList)
        {
            expectedList.First().UpdatedOn = DateTime.UtcNow.Date;
            WhenUserSelectsRecordsEpaZendeskUserByContext(expectedList);
        }

        /// <summary>
        /// Проверяльщик маппинга ЕПА и Зендеск юзеров для созданного юзера ЕПА 
        /// </summary>
        [Then(@"User selects records in table 'EpaZendeskUser' for created user:")]
        public void WhenUserSelectsRecordsEpaZendeskUserByContext(IEnumerable<EpaZendeskUser> expectedList)
        {
            var actualList = _epaZendeskUserRepository.SelectByEpaId(_context.UserId);

            expectedList.First().EpaId = _context.UserId;
            expectedList.First().CreatedOn = DateTime.UtcNow.Date;

            //Checking EpaId exist
            Assert.True(actualList.Single().EpaId!=null);

            actualList.Select(
                row => new
                {
                    row.EpaId,
                    CreatedOn = row.CreatedOn.Date,
                    UpdatedOn = row.UpdatedOn.HasValue ? row.UpdatedOn.Value.Date : (DateTime?) null
                })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "EpaZendeskUser не соответствуют ожидаемым");
        }

        /// <summary>
        /// Проверяльщик маппинга ЕПА и Зендеск юзеров
        /// </summary>
        [Then(@"User selects records in table 'EpaZendeskUser' where EpaId=""(.*)"":")]
        public void WhenUserSelectsRecordsEpaZendeskUser(Guid EpaId, IEnumerable<EpaZendeskUser> expectedList)
        {
            var actualList = _epaZendeskUserRepository.SelectByEpaId(EpaId);

            actualList.Select(
                    row => new
                    {
                        row.EpaId,
                        row.ZendeskId,
                        row.UpdatedOn
                    })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "EpaZendeskUser не соответствуют ожидаемым");
        }

        [Then(@"User selects records in table 'EpaUserZendeskTicket' where EpaUserId=""(.*)"":")]
        public void WhenUserSelectsRecordsEpaUserZendeskTicket(Guid EpaUserId,
            IEnumerable<EpaUserZendeskTicket> expectedList)
        {
            var actualList = _epaZendeskUserRepository.SelectTicketsByEpaUserId(EpaUserId);

            actualList.Select(
                    row => new
                    {
                        row.EpaUserId,
                        row.IsUnread,
                        row.Subject,
                        row.Status,
                        row.LastMessage,
                        row.LastMessageByClient,
                        row.CreatedViaChannel,
                        row.RateMessage,
                        row.Rating
                    })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.WithStrictOrdering().ExcludingMissingMembers(),
                    "EpaUserZendeskTicket не соответствуют ожидаемым");
        }


        public void UserSelectsRecordsUserAttachment(long TicketId, IEnumerable<UserAttachment> expectedList)
        {
            var actualList = _userAttachmentRepository.SelectUserAttachmentsByTicketId(TicketId);

            actualList.Select(
                    row => new UserAttachment
                    {
                        TicketId = row.TicketId,
                        EpaUserId = row.EpaUserId
                    })
                .ShouldBeEquivalentTo(
                    expectedList,
                    options => options.ExcludingMissingMembers(),
                    "UserAttachment не соответствуют ожидаемым");
        }

        /// <summary>
        /// Проверяльщик уведомлений по userid
        /// </summary>
        /// 
        [Then(@"User selects records in table 'Notification' for UserId=""(.*)""")]
        public void ThenUserSelectsRecordsInTableForUserId(Guid UserId,
            List<ExpectedNotification> expectedNotifications)
        {
            _notificationChecker = new NotificationChecker(_context.StartDate);
            WaitNotification(expectedNotifications, UserId);
        }

        public string CheckAndReturnConfirmationCode(Guid UserId, List<ExpectedConfirmationCode> expectedConfirmationCode)
        {
            _confirmationCodeChecker = new ConfirmationCodeChecker(_context.StartDate.Value);
            _confirmationCodeChecker
                    .ClearExpected()
                    .AddExpected(expectedConfirmationCode.ToArray())
                    .AssertAll(UserId);

            return _confirmationCodeRepository.GetLastCodeBy(UserId).VerificationCode;
        }

        /// <summary>
        /// Проверяльщик шаблонов платежей юзера ЕПА 
        /// </summary>
        [Then(@"User selects records in table 'MassPaymentTemplates' for UserId=""(.*)"":")]
        public void WhenUserSelectsRecordsMassPaymentTemplates(Guid userId, IEnumerable<ExpectedMassPaymentTemplates> expectedList)
        {
            expectedList.First().LastPaymentDate = _context.StartDate;
            _masspaymentTemplatesChecker.AddExpected(expectedList.ToArray()).AssertAll(userId);
        }


        [Given(@"Reset PaymentsCount in table 'MassPaymentTemplates' where TemplateId=""(.*)""")]
        public void WhenUserSelectsRecordsMassPaymentTemplatesByName(int templateId)
        {
            _massPaymentTemplatesrepository.UpdatePaymentsCount(0, templateId);
        }


        public void SetProperReceiver(List<ExpectedNotification> expectedNotifications)
        {
            _notificationChecker.StartDate = _context.StartDate;
            expectedNotifications.ForEach(it =>
                {
                    if (it.MessageType.Equals(NotificationType.Email))
                        it.Receiver = _context.Email;
                    if (it.MessageType.Equals(NotificationType.Sms))
                        it.Receiver = _context.PhoneNumber;
                }
            );
        }

        /// <summary>
        /// Проверяльщик уведомлений для созданного юзера
        /// </summary>
        [Then(@"User selects records in table 'Notification' for created user")]
        public void WhenUserSelectsNotifications(List<ExpectedNotification> expectedNotifications)
        {
            SetProperReceiver(expectedNotifications);
            WaitNotification(expectedNotifications, _context.UserId);
        }
        

        /// <summary>
        /// Проверяльщик уведомлений для созданного юзера c заменой InvoiceId
        /// </summary>
        [Then(@"User selects records in table 'Notification' for created user with ""(.*)"" replacing:")]
        public void WhenUserSelectsNotifications(string replaceString, List<ExpectedNotification> expectedNotifications)
        {
            SetProperReceiver(expectedNotifications);
            WhenUserSelectsNotifications(_context.UserId, replaceString, expectedNotifications);
        }

        /// <summary>
        /// Проверяльщик уведомлений с задержкой
        /// </summary>
        [Then(@"After 10 seconds delay User selects records in table 'Notification' where UserId=""(.*)"" with ""(.*)"" replacing:")]
        public void WhenUserSelectsNotificationsWithDelay(Guid userId, string replaceString, List<ExpectedNotification> expectedNotifications)
        {
            //Check that email is not sending
            Thread.Sleep(10000);
            WhenUserSelectsNotifications(userId, replaceString, expectedNotifications);
        }


        /// <summary>
        /// Проверяльщик уведомлений с заменой ячеек
        /// </summary>
        [Then(@"User didn't receive Notifications for UserId=""(.*)""")]
        public void UserNotReceiveNotifications(Guid userId)
        {
            List<ExpectedNotification> emptyList = new List<ExpectedNotification>();
            Thread.Sleep(10000);
            _notificationChecker.StartDate = _context.StartDate;
            WaitNotification(emptyList, userId);
        }

        /// <summary>
        /// Проверяльщик уведомлений с заменой ячеек
        /// </summary>
        [Then(@"User selects records in table 'Notification' where UserId=""(.*)"" with ""(.*)"" replacing:")]
        public void WhenUserSelectsNotifications(Guid userId, string replaceString,
            List<ExpectedNotification> expectedNotifications)
        {
            _notificationChecker.StartDate = _context.StartDate;

            string replaceOn;
            switch (replaceString)
            {
                case "**TXn_ID**":
                    replaceOn = _context.Auth_TXn_ID.ToString();
                    break;
                case "**TickedId**":
                    replaceOn = _context.TicketsIDList.Last().ToString();
                    break;
                case "**TPurseTransactionId**":
                    replaceOn = GetPurseTransactionsByUserId(userId.ToString())
                                    .OrderByDescending(it => it.CreationDate)
                                    .First()
                                    .PurseTransactionId.ToString();
                    break;
                case "**TPurseTransactionId** for currency exchange":
                    replaceOn = GetPurseTransactionsByUserId(userId.ToString())
                                   .First( it=>it.Direction.Equals("in"))
                                   .PurseTransactionId.ToString();
                    break;
                case "**TPurseTransactionId** for currency exchange and date":
                    replaceOn = GetPurseTransactionsByUserId(userId.ToString())
                                    .First(it => it.Direction.Equals("in"))
                                    .PurseTransactionId.ToString();

                    ReplaceTableCells(expectedNotifications, "xx", DateTime.UtcNow.ToString("MM"));
                    break;
                case "**date**":
                    replaceOn = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 30).ToString("dd.MM.yyyy");
                    
                    break;
                case "**Invoice**":
                    replaceOn = GetLastInvoiceByUserId(userId).InvoiceId.ToString();
                    break;

                case "**Invoice internal payment**":
                    // Sender sent his transfer for about 5 min ago
                    _context.StartDate = _context.StartDate.Value.AddMinutes(-5);

                    replaceOn =  GetLastInvoiceByUserId(userId).InvoiceId.ToString();
                    break;
                case "**SenderInvoiceId**":
                    replaceOn = _context.InvoiceId.ToString();
                    break;
                default:
                    throw new Exception("No any case -branch for " + replaceString);
            }

            ReplaceTableCells(expectedNotifications, replaceString, replaceOn);

            WaitNotification(expectedNotifications, userId);
        }

        public void ReplaceTableCells(List<ExpectedNotification> expectedNotifications, string replaceString, string replaceOn)
        {
            expectedNotifications.ForEach(
                n =>
                {
                    if (n.Title != null)
                        n.Title = n.Title.Replace(replaceString, replaceOn);
                });

        }

        /// <summary>
        /// Проверяльщик уведомлений
        /// </summary>
        public void WaitNotification(List<ExpectedNotification> expectedNotifications, Guid userId)
        {
            _notificationChecker.ClearExpected();
            _notificationChecker.AddExpected(expectedNotifications.ToArray()).AssertAll(userId);
        }

        
        [Then(@"User gets VerificationCode in table 'ConfirmationCodes' by email:")]
        public void ThenUserGetsVerificationCodeByEmail(ExpectedConfirmationCode expectedConfirmCode)
        {
            WaitConfirmationCode(expectedConfirmCode, _context.Email);
        }

        [Then(@"User gets VerificationCode in table 'ConfirmationCodes' by phone:")]
        public void ThenUserGetsVerificationCodeByPhone(ExpectedConfirmationCode expectedConfirmCode)
        {
            WaitConfirmationCode(expectedConfirmCode, _context.PhoneNumber);
        }

        [Then(@"User gets VerificationCode in table 'ConfirmationCodes' where:")]
        public void ThenUserGetsVerificationCodeWhere(ExpectedConfirmationCode expectedConfirmCode)
        {
            WaitConfirmationCode(expectedConfirmCode, expectedConfirmCode.Recipient);
        }


        ConfirmationCode confirmationCode;

        public void WaitConfirmationCode(ExpectedConfirmationCode expectedConfirmCode, string recipient)
        {

            _confirmationChecker = new ConfirmationCodeChecker(_context.StartDate.Value);


            //Getting userid in ConfirmationCode table
            while (confirmationCode==null)
            {
                confirmationCode = confirmationCode ?? _confirmationCodeRepository.GetBy(recipient, _context.StartDate.Value).FirstOrDefault();
            }


            expectedConfirmCode.UserId = confirmationCode.UserId;
            expectedConfirmCode.Recipient = recipient;

            _confirmationChecker.AddExpected(expectedConfirmCode).AssertAll(expectedConfirmCode.UserId);


            _context.VerificationCode = _confirmationCodeRepository.FindBy("Recipient", recipient)
                .Where(it => it.OperationType == expectedConfirmCode.OperationType).
                OrderByDescending(it=>it.CreatedDate).First()
                .VerificationCode;
        }


        [Then(@"User selects records in 'FraudOperationCheckLogs' by last FraudOperationLog where UserId=""(.*)"":")]
        public void WhenUserSelectsFraudOperationCheckLogs(Guid UserId, List<ExpectedFraudOperationCheckLog> expectedList)
        {

            var lastFraudOperationLogId = _fraudoperationLogRepository.GetByUserId(UserId)
                .Where(it => it.OperationDate > _context.StartDate)
                .Single().FraudOperationLogId;


            var actualList = _fraudoperationCheckLogsRepository.GetByFraudOperationLogId(lastFraudOperationLogId).Where(it => it.HasRisk);

            expectedList.Select(
                    row => new
                    {
                        OperationCheckId=_fraudoperationCheckRepository.GetByClassName(row.ClassName).OperationCheckId,
                        row.HasRisk,
                        row.AddedWeight,
                        row.Error,
                    })
                .ShouldBeEquivalentTo(
                    actualList, "ExpectedFraudOperationCheckLog не соответствуют ожидаемым");

        }

        [Then(@"Create BankWireInTemp and Accept with Type=(.*):")]
        public void ThenCreateBankWireInTempAndAcceptWithTypeUndefined(BankWireInType type, BankWiresInTemp table)
        {
            table.BankCreationDate=DateTime.UtcNow;
            table.IncomingDate= DateTime.UtcNow;

            _banksWiresInTempRepository.Add(table);

           // table.IsUndefined = true;
            new MasterAPISteps(_context).AcceptIncomingWire(table, type);
        }


        [Then(@"CardLoad status is true")]
        public void CheckCardLoadStatus()
        {
            _cardLoadQueueProcessedRepository.GetByOperationGuid(_context.OperationGuid.Value).Single().IsSuccess.Should().Be(true);
        }

        #endregion
    }

}