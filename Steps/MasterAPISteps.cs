using ePayments.Tests.ApiClient.ComplianceAssist;
using ePayments.Tests.ApiClient.ComplianceAssist.Request;
using ePayments.Tests.ApiClient.MasterApiClient;
using ePayments.Tests.ApiClient.MasterApiClient.Requests;
using ePayments.Tests.ApiClient.MasterApiClient.Responses;
using ePayments.Tests.Data.Domain.Enum;
using ePayments.Tests.Data.Domain.Poco;
using ePayments.Tests.Helpers;
using ePayments.Tests.Services;
using ePayments.Tests.Web.CatalogContext;
using FluentAssertions;
using NSoup.Nodes;
using NUnit.Framework;
using System;
using System.Linq;
using System.Threading;
using ePayments.Tests.Di;
using TechTalk.SpecFlow;

namespace ePayments.Tests.Web.Steps
{
    /// <summary>
    /// Steps with Master site API
    /// </summary>
    [Binding]
    class MasterAPISteps
    {
        public readonly MasterApiClient _masterApiClient;
        private NPCardService _npCardService;
        private string _sessionId;
        private readonly Context _context;
        private DataBaseSteps _dbInstance;
        public readonly ComplianceAssistClient _complianceAssistCallbackClient;

        /// <summary>
        /// Context injection (for sharing data between classes)
        /// </summary>
        /// <param name="context">Passed context</param>
        public MasterAPISteps(Context context)
        {
            _context = context;
            _complianceAssistCallbackClient = new ComplianceAssistClient(TestConfiguration.Current.XORkey,TestConfiguration.Current.NginxUrl);

            _npCardService = DiUtils.GetContainer().GetInstance<NPCardService>();
            _masterApiClient = new MasterApiClient(TestConfiguration.Current.MasterUrl);
            _masterApiClient.Authorize(TestConfiguration.Current.MasterUser, TestConfiguration.Current.MasterPassword);
            _dbInstance = new DataBaseSteps(_context);
        }

        [Then(@"User creates NP Card")]
        public void CreateNPCard()
        {
            Card _card = _npCardService.CreateNPCard();

            _context.FullPAN = _card.PanCode;
            _context.Token = _card.ProxyPANCode;
        }

        [Then(@"Operator blocks EPA Card for UserID=""(.*)""")]
        public void SetUserId(Guid UserId)
        {
            _context.UserId = UserId;
            BlockEPACard();
        }

        [Then(@"Operator blocks EPA Card for created user")]
        public void BlockEPACard()
        {
            var setRequest = new BlockEPACardRequest
            {
                CardId = _dbInstance
                    ._cardRepository.FindBy("UserId", _context.UserId)
                    .First()
                    .CardId.ToString(),
                NewState = "4",
                Reason = "3",
                ChangeStateNote = "reason"
            };


            _masterApiClient.SendPost<string>("Cards/ChangeCardStatus", setRequest);
        }

        [Then(@"Operator marks business user with RiskLevel A")]
        public void MarkUserRiskLevelA()
        {
            var response =
                _masterApiClient.SendPost<string>("Accounts/SetRiskLevel", new
                {
                    userId = _context.UserId,
                    RiskLevel = "RiskA"
                });

            Assert.True(response.Contains("Risk level is changed successfully!"), response);
        }

        [Then(@"Operator confirms Invoice refund")]
        public void SendInvoiceVerificate()
        {
            _sessionId = _masterApiClient.SendPost<AjaxResult>("Invoices/Verificate").Data;
        }

        [Then(@"Operator refunds last invoice for UserId=(.*)")]
        public void RefundInvoice(Guid userId)
        {
            var req = new
            {
                invoiceId = _dbInstance.GetLastInvoiceByUserId(userId).InvoiceId,
                verificationCode = _context.VerificationCode,
                sessionId = _sessionId
            };

            var response =
                _masterApiClient.SendPost<string>("Invoices/RefundInvoice", req);

            Assert.True(response.Contains("successfully refunded!"), response);
        }

        [Then(@"Operator close last invoice for UserId=(.*)")]
        public void CloseInvoice(Guid userId)
        {
            var req = new
            {
                invoiceId = _dbInstance.GetLastInvoiceByUserId(userId).InvoiceId,
            };

            var response =
                _masterApiClient.SendPost<string>("Invoices/CloseInvoice", req);

              Assert.True(response.Contains("Invoice close success"), response);
        }

        [Then(@"Operator try to set created user as verified")]
        public void TrySetUserAsVerified()
        {
            var response = MarkUserVerificated();
            Assert.True(response.Contains("There is a potential match with sanctions_pep_list"), response);
        }

        [Then(@"Operator set created user as verified")]
        public void SetUserAsVerified()
        {
            var response = MarkUserVerificated();
            Assert.True(response.Contains("Set user as verified is success"), response);
        }


        public string MarkUserVerificated()
        {
            return
                _masterApiClient.SendPost<string>("Documents/SetUserVerified", new { userId = _context.UserId });
        }

        [Then(@"Operator gets client info by card")]
        public void GetClientInfoByCard()
        {
          var response=  _masterApiClient.SendPost<string>("Cards/GetClientInfo", new
            {
                id = _context.CardId
            });
        }
        
        [Then(@"Operator clicks on edit card info and save it with CardDeliveryType = (RussianPost|RoyalMail)")]
        public void GetClientInfoByCards(string CardDeliveryType)
        {
            _context.CardId = _dbInstance
                ._cardRepository
                .FindBy("UserId", _context.UserId)
                .OrderByDescending(it=>it.PrerequestCreationDate)
                .First().CardId;


            var request = new
            {
                CardID = _context.CardId,
                CardCurrency = 1,
                CardPaid = "Paid",
                DeliveryPaid = "Paid",
                EmbossingName = _context.PersDetails.FirstName + " " + _context.PersDetails.LastName,
                CardDeliveryType,
                PassportExpireDate = "01/01/2036"
            };

            var a = _masterApiClient.SendPost<AjaxResult>("CardCreating/Edit",request);
        }


        [Then(@"Operator edits First Name")]
        public void EditClientInfo(PersonalData personalData)
        {
            _context.PersDetails.FirstName = personalData.FirstName;
            var request = new
            {
                _context.UserId,
                personalData.FirstName,
                personalData.LastName,
                BirthDate = "30.04.1991",
                personalData.Gender,
                ResidenceCountry= personalData.ResidenceCountryId,
                Citizenship = "",
                PassportNum = "",
                PassportExpiryDate = ""
            };

            _masterApiClient.SendPost<string>("Accounts/SavePersonalInfo", request);
        }


        [Then(@"Send CA (true|false) positive callback for created user")]
        public void SendCACallbackForCreatedUser(string flag)
        {
            SendCACallback(flag, _context.UserId.ToString());
        }
        
        [Then(@"Send CA (true|false|PEP) positive callback for reference '(.*)'")]
        public void SendCACallback(string flag, string reference)
        {

            _complianceAssistCallbackClient.SendPost(GetComplianceCallback(flag,reference));

        }

        public ComplianceResponse GetComplianceCallback(string flag,  string reference)
        {
            ComplianceResponseStatusSummary obj = new ComplianceResponseStatusSummary
            {
                Open = 0,
                InformationRequested = 0,
                Escalated = 0,
                FalsePositive = flag.Equals("false") ? 1 : 0,
                TruePositive = flag.Equals("true") ? 1 : 0,
                ConfirmedPep = flag.Equals("PEP") ? 1 : 0,
                PassedByRule = 0,
                Cancelled = 0

            };

          return new ComplianceResponse
            {
                Reference = reference,
                RequestId = _context.RequestId,
                ComplianceResponseStatusSummary = obj,
                CurrentStatus = "Processing",
                NewStatus = "Complete"
            };
        }




        [Then(@"Operator creates card")]
        public void Savecard()
        {
            var response = _masterApiClient.SendPost<AjaxResult>("CardCreating/ConfirmCreate",
                new CardCreatingConfirmCreateRequest
                {
                    CardIssuer = "Gps",
                    CardID = _context.CardId
                });

            response.Message.Should().Be("Success");
        }

        [Then(@"Get Invoice for last wire where UserId='(.*)'")]
        public BankWireOut GetLastWireOutForUser(Guid userId)
        {
            var wire=_dbInstance
                .GetBankWireOut(userId)
                .OrderByDescending(it => it.Id)
                .First();

            _context.InvoiceId = wire.InvoiceId;
            return wire;
        }

        public BankWiresInTemp GetLastWiresInTempByReference(string beneficiaryAccountNumber)
        {
            var wire = _dbInstance
                .GetBankWiresInTemp(beneficiaryAccountNumber)
                .Where (it=>it.BankCreationDate > _context.StartDate)
                .Single();

            return wire;
        }

        [Then(@"Operator edits bank wire for UserId='(.*)' where WireService='(.*)' and sends to bank")]
        public void GetBankWiresOut(Guid userId, string wireServiceName)
        {
            //Getting last wire for UserId
            var wire = GetLastWireOutForUser(userId);

            //Get wire info, and checking wire service
            Document doc =
                NSoup.Parse.Parser.Parse(_masterApiClient.SendGet<string>($"BankWiresOut/EditWindow?id={wire.Id}"), "");

            var WireService = doc.Select("#WireServiceId [selected]").Single().Text();
            WireService.Should().Be(wireServiceName);

            //Send wire to bank
            var response = _masterApiClient
                .Authorize()
                .SendPost<AjaxResult>("BankWiresOut/SendToBank", GetSendedOutgoingWireRequest(wire.Id, _context.InvoiceId));
            response.Success.Should().BeTrue($"Error while sending wire: {response.Message}");
        }

        /// <summary>
        /// Отправить запрос с исходящим ваером в банк
        /// </summary>
        /// <param name="wireId">ID исх. ваера</param>
        /// <param name="invoiceId">Инвойса исх.ваера</param>
        /// <returns>SendBankWireOutRequest</returns>
        private SendBankWireOutRequest GetSendedOutgoingWireRequest(long wireId, int invoiceId)
        {
            var invoice = _dbInstance._invoiceRepository
                .GetByInvoiceId(invoiceId);

            Assert.That(invoice.State, Is.EqualTo(InvoiceState.WaitingForManualAdmission),
                $"Invoice '{invoice.InvoiceId}' should be in a '{InvoiceState.WaitingForManualAdmission:G}' state for outgoing bank wire");

            var wire = _dbInstance._banksWireOutRepository.GetByWireId(wireId);

            var request = new SendBankWireOutRequest
            {
                WireId = wire.Id,
                WireServiceId = (int)invoice.ReceiverSystemId,
                InvoiceId = invoice.InvoiceId,
                Amount = wire.Amount,
                UserId = invoice.UserId,
                BankAddress = wire.BankAddress,
                BankCity = wire.BankCity,
                BankCountryId = wire.BankCountryId,
                BankName = wire.BankName,
                BankSwift = wire.BankSwift,
                BankBicRussia = wire.BicRussia,
                BeneficiaryType = wire.BeneficiaryType,
                BeneficiaryAccount = wire.BeneficiaryAccount,
                BeneficiaryAddress = wire.BeneficiaryAddress,
                BeneficiaryCity = wire.BeneficiaryCity,
                BeneficiaryCountryId = wire.BeneficiaryCountryId,
                BeneficiaryName = wire.BeneficiaryName,
                BeneficiaryFirstName = wire.BeneficiaryFirstName,
                BeneficiaryLastName = wire.BeneficiaryLastName,
                BeneficiaryAba = wire.BeneficiaryAba,
                BeneficiaryCnaps = wire.BeneficiaryCnaps,
                BeneficiarySortCode = wire.BeneficiarySortCode,
                BeneficiaryRegistrationNumber = wire.BeneficiaryRegistrationNumber,
                BeneficiaryPostCode = wire.BeneficiaryPostCode,
                BeneficiaryStateOrProvince = wire.BeneficiaryStateOrProvince,
                PurposeOfPayment = wire.PurposeOfPayment,
                ProcessWireViaIntermediary = wire.ProcessWireViaIntermediary,
                IntermediaryAccount = wire.IntermediaryAccount,
                IntermediaryBankName = wire.IntermediaryBankName,
                IntermediaryBankSwift = wire.IntermediaryBankSwift,
                IntermediaryBankBicRussia = wire.IntermediaryBicRussia,
                IntermediaryBankCountryId = wire.IntermediaryBankCountryId,
                IntermediaryBankCity = wire.IntermediaryBankCity,
                Currency = ((Currency)wire.CurrencyId).ToString(),
                ChargeType = wire.Charge,
                Details = wire.Details,
                IntermediaryBankAddress = wire.IntermediaryBankAddress,
                Urgency = wire.Urgency,
                IsDelayed = wire.IsDelayed,
                Comment = "autotest comment"
            };

            return request;
        }
    

        [Then(@"Get FullPAN")]
        public void GetPan()
        {
            var response = _masterApiClient.SendPost<GetStoredCardPanResponse>("Cards/GetStoredCardPan",
                new
                {
                    cardId = _context.CardId
                });

            _context.FullPAN = response.Pan;
        }


        [Then(@"Wait for card ready to be activated")]
        [Then(@"Wait Webmoney invoice successed")]
        public void WaitWebmoneySuccessState()
        {
            Thread.Sleep(30000);
        }

        [Then(@"Operator gets first record in WebMoney MassPayments contains '(.*)'")]
        public void GetWMMassPayments(string text)
        {
            //Waiting 30 sec for Status = Completed
            WaitWebmoneySuccessState();
            Document doc =
                NSoup.Parse.Parser.Parse(_masterApiClient.SendGet<string>("WebMoney/MassPayments"), "");

            var MassPaymentRecord = doc.Select("tbody tr").First.Text();
            var ClosedDate = DateTime.UtcNow.ToString("dd/MM/yy");
            var CreatedDate = ClosedDate;

            MassPaymentRecord.Contains(ClosedDate);
            MassPaymentRecord.Contains(CreatedDate);
            MassPaymentRecord.Contains(text);
        }

        [Then(@"Operator updates CardDesign in UserReference:")]
        public void ThenOperatorUpdatesCardDesignFFInUserReference(EditUserReferenceRequest userReference)
        {
            var response = _masterApiClient.SendPost<string>("UserReferences/Edit", userReference);
            Assert.True(response.Contains("Reference save success!"), "Reference is not updated: " + response);
        }
        

        [Then(@"Operator creates undefined wire:")]
        [Then(@"Operator creates incoming wire:")]
        [Obsolete()]
        public void SendIncomingWire(CreateWire table)
        {
            SendOutgoingWire(GetWireInRequest(table));
        }

        public CreateWire GetWireInRequest(CreateWire table)
        {
            return
                new CreateWire
                {
                    senderName = "autotest " + DataBuilderHelper.GenerateStringValue(10),
                    reference = table.reference,
                    paymentDetails = table.paymentDetails,
                    beneficiaryAccountNumber = table.beneficiaryAccountNumber,
                    isUndefined = table.isUndefined,
                    currency = table.currency,
                    bankCharge = table.bankCharge,
                    bankCreationDate = DateTime.UtcNow.Date,
                    ourCharge = table.ourCharge,
                    wireServiceId = table.wireServiceId,
                    transactionId = DataBuilderHelper.GenerateStringValue(10),
                    transactionCommissionId = DataBuilderHelper.GenerateStringValue(10),
                    paymentAmount = table.paymentAmount,
                    operatorComment = "autotest comment"
                };
        }

        public void SendOutgoingWire(CreateWire request)
        {

            var response = _masterApiClient
                .SendPost<SessiodIdResponse>("BankWires/Verificate", request);

            if (response.Success && response.SessionId.HasValue)
            {
                var confirmationCode = _dbInstance._confirmationCodeRepository.GetLastCodeBySessionId(response.SessionId.Value);
                Assert.That(confirmationCode, Is.Not.Null, $"Confirmation code for session='{response.SessionId.Value}' doesn't exists");

                request.SessionId = response.SessionId.Value;
                request.VerificationCode = confirmationCode.VerificationCode;

                _masterApiClient
                    .SendPost<string>("BankWires/CreateWindow", request);
            }
        }

        public void AcceptIncomingWire(BankWiresInTemp table, BankWireInType type)
        {

            var response = _masterApiClient
                .SendPost<SessiodIdResponse>("BankWires/Verificate", table);

            if (response.Success && response.SessionId.HasValue)
            {
                var confirmationCode = _dbInstance._confirmationCodeRepository.GetLastCodeBySessionId(response.SessionId.Value);
                Assert.That(confirmationCode, Is.Not.Null, $"Confirmation code for session='{response.SessionId.Value}' doesn't exists");
                
                
                var request = new BankWiresInDataModelRequest
                {
                    Id= GetLastWiresInTempByReference(table.Reference).BankWireInTempId,
                    SenderName = table.SenderName,
                    Reference = table.Reference,
                    PaymentDetails = table.PaymentDetails,
                    BeneficiaryAccountNumber = table.BeneficiaryAccountNumber,
                   // IsUndefined=table.IsUndefined,
                    IsUndefined = type.ToString().Equals("Undefined"),
                    WireServiceId = table.WireServiceId,
                    TransactionId = table.TransactionId,
                    TransactionCommissionId = table.TransactionCommissionId,
                    Currency = table.CurrencyId,
                    BankCharge = table.BankCharge,
                    OurCharge = table.OurCharge,
                    BankCreationDate = table.BankCreationDate,

                    PaymentAmount = table.PaymentAmount,
                    SourceOfFundsId= table.SourceOfFundsId,
                    Type= type,
                    SessionId = response.SessionId.Value,
                    VerificationCode = confirmationCode.VerificationCode
            };

                _masterApiClient
                    .SendPost<string>("BankWires/Accept", request);
            }
        }

        [Then(@"Operator creates incoming wire from '(.*)':")]
        [Obsolete()]
        public void SendIncomsingWire(string sender, CreateWire table)
        {
            var request = GetWireInRequest(table);

            request.senderName = sender;

            SendOutgoingWire(request);
        }

        [Then(@"Operator process undefined incoming wire '(.*)':")]
        public void ProcessWire(Guid userId,BankWireInRequest table)
        {

            var lastUndefinedWire = _dbInstance._banksWireInRepository
                .GetByUserId(userId)
                .OrderByDescending(it => it.CreationDate).First();

            var request = new BankWireInRequest
            {
                BeneficiaryAccountNumber = table.BeneficiaryAccountNumber,
                ComissionForIdentification = table.ComissionForIdentification,
                CommissionForWire = table.CommissionForWire,
                SourceOfFundsId = table.SourceOfFundsId,
                OperatorComment = lastUndefinedWire.OperatorComment,
                BankCreationDate= lastUndefinedWire.BankCreationDate.Value,
                SenderName = lastUndefinedWire.SenderName,
                PaymentAmount=lastUndefinedWire.PaymentAmount,
                PaymentDetails = lastUndefinedWire.PaymentDetails,
                BankCharge = lastUndefinedWire.BankCharge,
                Currency = table.Currency,
                Reference = lastUndefinedWire.Reference,
                WireServiceId = lastUndefinedWire.WireServiceId
            };


            _context.StartDate = DateTime.UtcNow;


            //Getting undefined wire id
            _masterApiClient
                .SendGet<string>($"BankWires/ProcessUnidentifiedWire/{lastUndefinedWire.BankWireId}");


            //Get OperationGuid
            Document doc =
                NSoup.Parse.Parser.Parse(_masterApiClient
                    .SendPost<string>($"BankWires/ProcessUnidentifiedWire/{lastUndefinedWire.BankWireId}", request), "");

            _context.OperationGuid = Guid.Parse(doc.Select(".form-group [for=OperationGuid] + div").Single().Text());

            //Confirm processing undefind wire
            _masterApiClient
                .SendPost<string>("BankWires/ProcessUnidentifiedWireConfirm", new
                {
                    VerificationCode = _dbInstance._confirmationCodeRepository
                        .GetBy("+70002342342", _context.StartDate.Value).Single().VerificationCode
                });

        }



        [Then(@"Operator pushed on CloseCardLoad")]
        public void CloseCardLoad()
        {
            ProcessFailedCardLoad("FailedCardLoads/CloseCardLoad", new CloseCardLoadRequest
            {
                failedCardLoadId = _dbInstance._cardLoadQueueProcessedRepository.GetByOperationGuid(_context.OperationGuid.Value).Single().Id,
                isNotRefund = true
            });
        }

        [Then(@"Operator pushed on Refund transactions")]
        public void RefundTransactionsCardLoad()
        {
            ProcessFailedCardLoad("FailedCardLoads/CloseCardLoad", new CloseCardLoadRequest
            {
                failedCardLoadId = _dbInstance._cardLoadQueueProcessedRepository.GetByOperationGuid(_context.OperationGuid.Value).Single().Id,
                isNotRefund = false
            });
        }

        [Then(@"Operator pushed on Reload Funds")]
        public void ReloadFundsCardLoad()
        {
            ProcessFailedCardLoad("FailedCardLoads/ReloadFunds", new CloseCardLoadRequest
            {
                failedCardLoadId = _dbInstance._cardLoadQueueProcessedRepository.GetByOperationGuid(_context.OperationGuid.Value).Single().Id,
                isByApi = false
            });
        }

        public void ProcessFailedCardLoad(string Url, CloseCardLoadRequest request)
        {
            var response = _masterApiClient.SendPost<string>(Url, request);
            response.Should().Contain("success", "Unsuccessful cardload process");
        }

    }
}