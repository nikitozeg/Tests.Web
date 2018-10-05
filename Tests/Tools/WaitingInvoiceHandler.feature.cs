﻿// ------------------------------------------------------------------------------
//  <auto-generated>
//      This code was generated by SpecFlow (http://www.specflow.org/).
//      SpecFlow Version:2.3.2.0
//      SpecFlow Generator Version:2.3.0.0
// 
//      Changes to this file may cause incorrect behavior and will be lost if
//      the code is regenerated.
//  </auto-generated>
// ------------------------------------------------------------------------------
#region Designer generated code
#pragma warning disable
namespace ePayments.Tests.Web.Tests.Tools
{
    using TechTalk.SpecFlow;
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("TechTalk.SpecFlow", "2.3.2.0")]
    [System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    [NUnit.Framework.TestFixtureAttribute()]
    [NUnit.Framework.DescriptionAttribute("WaitingInvoiceHandler")]
    [NUnit.Framework.CategoryAttribute("WaitingInvoiceHandler")]
    public partial class WaitingInvoiceHandlerFeature
    {
        
        private TechTalk.SpecFlow.ITestRunner testRunner;
        
#line 1 "WaitingInvoiceHandler.feature"
#line hidden
        
        [NUnit.Framework.OneTimeSetUpAttribute()]
        public virtual void FeatureSetup()
        {
            testRunner = TechTalk.SpecFlow.TestRunnerManager.GetTestRunner();
            TechTalk.SpecFlow.FeatureInfo featureInfo = new TechTalk.SpecFlow.FeatureInfo(new System.Globalization.CultureInfo("en-US"), "WaitingInvoiceHandler", null, ProgrammingLanguage.CSharp, new string[] {
                        "WaitingInvoiceHandler"});
            testRunner.OnFeatureStart(featureInfo);
        }
        
        [NUnit.Framework.OneTimeTearDownAttribute()]
        public virtual void FeatureTearDown()
        {
            testRunner.OnFeatureEnd();
            testRunner = null;
        }
        
        [NUnit.Framework.SetUpAttribute()]
        public virtual void TestInitialize()
        {
        }
        
        [NUnit.Framework.TearDownAttribute()]
        public virtual void ScenarioTearDown()
        {
            testRunner.OnScenarioEnd();
        }
        
        public virtual void ScenarioSetup(TechTalk.SpecFlow.ScenarioInfo scenarioInfo)
        {
            testRunner.OnScenarioStart(scenarioInfo);
        }
        
        public virtual void ScenarioCleanup()
        {
            testRunner.CollectScenarioErrors();
        }
        
        [NUnit.Framework.TestAttribute()]
        [NUnit.Framework.DescriptionAttribute("WaitingInvoiceHandler не закрывает инвойсы исходящих ваеров")]
        [NUnit.Framework.CategoryAttribute("1676695")]
        [NUnit.Framework.TestCaseAttribute("toolWaitInvoiceHandlerBiz@qa.swiftcom.uk", "13684ab7-edb0-451c-a4d4-33fd839e30ac", "72621010Abac", "10 000.00", "4 500.00", "791479", null)]
        public virtual void WaitingInvoiceHandlerНеЗакрываетИнвойсыИсходящихВаеров(string user, string userId, string password, string amount, string comission, string userPurseId, string[] exampleTags)
        {
            string[] @__tags = new string[] {
                    "1676695"};
            if ((exampleTags != null))
            {
                @__tags = System.Linq.Enumerable.ToArray(System.Linq.Enumerable.Concat(@__tags, exampleTags));
            }
            TechTalk.SpecFlow.ScenarioInfo scenarioInfo = new TechTalk.SpecFlow.ScenarioInfo("WaitingInvoiceHandler не закрывает инвойсы исходящих ваеров", @__tags);
#line 6
 this.ScenarioSetup(scenarioInfo);
#line 13
    testRunner.Given("User goes to SignIn page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 14
 testRunner.Given(string.Format("User signin \"Epayments\" with \"{0}\" password \"{1}\"", user, password), ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 15
 testRunner.Given("User see Account Page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 16
 testRunner.Then("Memorize eWallet section", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 18
 testRunner.Given("User clicks on Перевести menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 19
 testRunner.Given("User clicks on \"На банковский счет\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 21
 testRunner.Then("Section \'Amount including fees\' is: $ 0.00 (Комиссия: $ 0.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 23
 testRunner.Then("\'Кошелек\' selector set to \'RUB\' in eWallet section", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 24
 testRunner.Then("\'Получатель платежа\' selector set to \'receiver bank, ReceiverName ReceiverSurname" +
                    ", LV10RTMB0000000000009\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 25
 testRunner.Then("\'Отдаваемая сумма\' set to \'10000\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 26
 testRunner.Then("\'Получаемая сумма\' value is \'10000.00\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table1 = new TechTalk.SpecFlow.Table(new string[] {
                        "Column1",
                        "Column2"});
            table1.AddRow(new string[] {
                        "Минимальная сумма перевода:",
                        "₽ 6 000.00"});
            table1.AddRow(new string[] {
                        "Максимальная сумма перевода:",
                        "₽ 6 000 000.00"});
            table1.AddRow(new string[] {
                        "Комиссия:",
                        "0.8%min ₽ 4 500, max ₽ 7 500"});
#line 28
 testRunner.Given("User see limits table", ((string)(null)), table1, "Given ");
#line 34
 testRunner.Then("\'Назначение платежа\' details set to \'Details\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 35
 testRunner.Then("\'Код валютной операции (VO)\' set to \'999999\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 37
 testRunner.Then(string.Format("Section \'Amount including fees\' is: ₽ 14 500.00 (Комиссия: ₽ {0})", comission), ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 39
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 40
 testRunner.Given("User clicks on \"Далее\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table2 = new TechTalk.SpecFlow.Table(new string[] {
                        "Column1",
                        "Column2"});
            table2.AddRow(new string[] {
                        "Отправитель",
                        string.Format("RUB, e-Wallet 001-{0}", userPurseId)});
            table2.AddRow(new string[] {
                        "Получатель",
                        "receiver bank, rcvrSwift12, ReceiverName ReceiverSurname, LV10RTMB0000000000009"});
            table2.AddRow(new string[] {
                        "Отдаваемая сумма",
                        string.Format("₽ {0}", amount)});
            table2.AddRow(new string[] {
                        "Комиссия",
                        string.Format("₽ {0}", comission)});
            table2.AddRow(new string[] {
                        "Сумма с комиссией",
                        "₽ 14 500.00"});
            table2.AddRow(new string[] {
                        "Получаемая сумма",
                        string.Format("₽ {0}", amount)});
            table2.AddRow(new string[] {
                        "Назначение платежа",
                        "Details"});
#line 42
 testRunner.Given("User see table", ((string)(null)), table2, "Given ");
#line 51
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 52
 testRunner.Given("Set StartTime for DB search", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 54
 testRunner.Given("User clicks on \"Подтвердить\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 55
 testRunner.Given("Set StartTime for DB search", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table3 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationType",
                        "Recipient",
                        "UserId",
                        "IsUsed"});
            table3.AddRow(new string[] {
                        "MassPayment",
                        "+70064581799",
                        string.Format("{0}", userId),
                        "false"});
#line 56
 testRunner.Then("User type SMS sent to:", ((string)(null)), table3, "Then ");
#line 59
 testRunner.Given("User clicks on \"Оплатить\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 60
 testRunner.Then("User gets message \"Обработка платежа займет несколько минут. Дождитесь результата" +
                    " перевода или продолжите работу в личном кабинете\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 61
 testRunner.Then(@"User gets message ""Платеж зарегистрирован и будет обработан в течение рабочего дня. Как только он будет исполнен банком, в личном кабинете в деталях операции в этом переводе появится Reference Number - дополнительный идентификатор операции в банке"" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 63
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 65
  testRunner.Then(string.Format("Operator edits bank wire for UserId=\'{0}\' where WireService=\'Rietumu\' and sends t" +
                        "o bank", userId), ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table4 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationTypeId",
                        "Amount",
                        "Fee"});
            table4.AddRow(new string[] {
                        "143",
                        "10000.00",
                        "4500.00"});
#line 68
 testRunner.Then("Preparing records in \'InvoicePositions\':", ((string)(null)), table4, "Then ");
#line hidden
            TechTalk.SpecFlow.Table table5 = new TechTalk.SpecFlow.Table(new string[] {
                        "State",
                        "Details",
                        "SenderSystemId",
                        "SenderIdentity",
                        "ReceiverSystemId",
                        "ReceiverIdentity",
                        "CurrencyId",
                        "PaymentSource",
                        "ReceiverIdentityType",
                        "UserId"});
            table5.AddRow(new string[] {
                        "WaitingForAutomaticAdmission",
                        "{VO99999}, Details",
                        "WaveCrest",
                        string.Format("001-{0}", userPurseId),
                        "Rietumu",
                        "rcvrSwift12/LV10RTMB0000000000009",
                        "Rub",
                        "EWallet",
                        "Purse",
                        string.Format("{0}", userId)});
#line 71
 testRunner.Then(string.Format("User selects last record in \'Invoices and InvoicePositions\' where UserId=\"{0}\":", userId), ((string)(null)), table5, "Then ");
#line 77
  testRunner.When("User download and executes \"Tools.WaitingInvoiceHandler\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "When ");
#line hidden
            TechTalk.SpecFlow.Table table6 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationTypeId",
                        "Amount",
                        "Fee"});
            table6.AddRow(new string[] {
                        "143",
                        "10000.00",
                        "4500.00"});
#line 80
 testRunner.Then("Preparing records in \'InvoicePositions\':", ((string)(null)), table6, "Then ");
#line hidden
            TechTalk.SpecFlow.Table table7 = new TechTalk.SpecFlow.Table(new string[] {
                        "State",
                        "Details",
                        "SenderSystemId",
                        "SenderIdentity",
                        "ReceiverSystemId",
                        "ReceiverIdentity",
                        "CurrencyId",
                        "PaymentSource",
                        "ReceiverIdentityType",
                        "UserId"});
            table7.AddRow(new string[] {
                        "WaitingForAutomaticAdmission",
                        "{VO99999}, Details",
                        "WaveCrest",
                        string.Format("001-{0}", userPurseId),
                        "Rietumu",
                        "rcvrSwift12/LV10RTMB0000000000009",
                        "Rub",
                        "EWallet",
                        "Purse",
                        string.Format("{0}", userId)});
#line 83
 testRunner.Then(string.Format("User selects last record in \'Invoices and InvoicePositions\' where UserId=\"{0}\":", userId), ((string)(null)), table7, "Then ");
#line hidden
            this.ScenarioCleanup();
        }
    }
}
#pragma warning restore
#endregion