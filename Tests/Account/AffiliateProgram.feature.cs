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
namespace ePayments.Tests.Web.Tests.Account
{
    using TechTalk.SpecFlow;
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("TechTalk.SpecFlow", "2.3.2.0")]
    [System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    [NUnit.Framework.TestFixtureAttribute()]
    [NUnit.Framework.DescriptionAttribute("AffiliateProgram")]
    [NUnit.Framework.CategoryAttribute("AffiliateProgram")]
    public partial class AffiliateProgramFeature
    {
        
        private TechTalk.SpecFlow.ITestRunner testRunner;
        
#line 1 "AffiliateProgram.feature"
#line hidden
        
        [NUnit.Framework.OneTimeSetUpAttribute()]
        public virtual void FeatureSetup()
        {
            testRunner = TechTalk.SpecFlow.TestRunnerManager.GetTestRunner();
            TechTalk.SpecFlow.FeatureInfo featureInfo = new TechTalk.SpecFlow.FeatureInfo(new System.Globalization.CultureInfo("en-US"), "AffiliateProgram", null, ProgrammingLanguage.CSharp, new string[] {
                        "AffiliateProgram"});
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
        [NUnit.Framework.DescriptionAttribute("Выплата бонусных начислений")]
        [NUnit.Framework.CategoryAttribute("1324062")]
        public virtual void ВыплатаБонусныхНачислений()
        {
            TechTalk.SpecFlow.ScenarioInfo scenarioInfo = new TechTalk.SpecFlow.ScenarioInfo("Выплата бонусных начислений", new string[] {
                        "1324062"});
#line 5
this.ScenarioSetup(scenarioInfo);
#line 9
 testRunner.Given("User goes to SignIn page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 10
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 11
 testRunner.Given("User signin \"Epayments\" with \"referal123@qa.swiftcom.uk\" password \"3EDC4rfv\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 12
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 13
 testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 14
 testRunner.Given("Memorize 1-level refferer \'Available for payment\' table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 15
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 18
 testRunner.Given("User goes to SignIn page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 19
  testRunner.Given("User signin \"Epayments\" with \"qrrtttPart@test.ru\" password \"3EDC4rfv\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 20
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 21
 testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 22
 testRunner.Given("Memorize 0-level refferer \'Available for payment\' table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 23
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 26
 testRunner.Given("Set StartTime for DB search", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 27
 testRunner.Given("User signin \"Epayments\" with \"nikitatest206@qa.swiftcom.uk\" password \"72621010Aba" +
                    "c\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 28
 testRunner.Given("User clicks on Перевести menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 29
 testRunner.Given("User clicks on \"Другому человеку\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 30
 testRunner.Then("Section \'Amount including fees\' is: $ 0.00 (Комиссия: $ 0.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 31
 testRunner.Then("\'Получатель\' set to \'000304699\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 32
 testRunner.Then("\'Со счета\' selector set to \'RUB\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 33
 testRunner.Then("\'Отдаваемая сумма\' set to \'1000\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 34
 testRunner.Then("Section \'Amount including fees\' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 35
 testRunner.Given("User clicks on \"Далее\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 36
 testRunner.Given("User clicks on \"Подтвердить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table1 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationType",
                        "Recipient",
                        "UserId",
                        "IsUsed"});
            table1.AddRow(new string[] {
                        "MassPayment",
                        "+70276111299",
                        "8e80007b-62a8-471b-b5ca-4e2c622c56d9",
                        "false"});
#line 37
 testRunner.Then("User type SMS sent to:", ((string)(null)), table1, "Then ");
#line 40
 testRunner.Given("User clicks on \"Оплатить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 41
 testRunner.Then("User gets message \"Платеж успешно отправлен\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 42
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 45
 testRunner.Given("User signin \"Epayments\" with \"referal123@qa.swiftcom.uk\" password \"3EDC4rfv\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 46
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 47
    testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table2 = new TechTalk.SpecFlow.Table(new string[] {
                        "ForPayment",
                        "Processing",
                        "Cancelled",
                        "Completed"});
            table2.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table2.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table2.AddRow(new string[] {
                        "0.00",
                        "+3.15",
                        "0.00",
                        "0.00"});
#line 48
 testRunner.Given("User see 1-level refferer \'AvailableForPayment\' table with updated columns:", ((string)(null)), table2, "Given ");
#line 53
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 55
 testRunner.Given("User clicks on Перевести menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 56
 testRunner.Given("User clicks on \"Другому человеку\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 57
 testRunner.Then("Section \'Amount including fees\' is: $ 0.00 (Комиссия: $ 0.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 58
 testRunner.Then("\'Получатель\' set to \'000193351\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 59
 testRunner.Then("\'Со счета\' selector set to \'RUB\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 60
 testRunner.Then("\'Отдаваемая сумма\' set to \'1000\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 61
 testRunner.Then("Section \'Amount including fees\' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 62
 testRunner.Given("User clicks on \"Далее\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 63
 testRunner.Given("User clicks on \"Подтвердить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table3 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationType",
                        "Recipient",
                        "UserId",
                        "IsUsed"});
            table3.AddRow(new string[] {
                        "MassPayment",
                        "+70009991179",
                        "89fafa8d-49da-453c-ab85-eedf501dc706",
                        "false"});
#line 64
 testRunner.Then("User type SMS sent to:", ((string)(null)), table3, "Then ");
#line 67
 testRunner.Given("User clicks on \"Оплатить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 68
 testRunner.Then("User gets message \"Платеж успешно отправлен\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 69
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 72
 testRunner.Given("User signin \"Epayments\" with \"qrrtttPart@test.ru\" password \"3EDC4rfv\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 73
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 74
    testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table4 = new TechTalk.SpecFlow.Table(new string[] {
                        "ForPayment",
                        "Processing",
                        "Cancelled",
                        "Completed"});
            table4.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table4.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table4.AddRow(new string[] {
                        "0.00",
                        "+6.30",
                        "0.00",
                        "0.00"});
#line 75
 testRunner.Given("User see 0-level refferer \'AvailableForPayment\' table with updated columns:", ((string)(null)), table4, "Given ");
#line 80
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 82
 testRunner.Then("Send event to epacash for UserId = 8e80007b-62a8-471b-b5ca-4e2c622c56d9 with last" +
                    " InvoiceId", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 83
 testRunner.Then("Send event to epacash for UserId = 89fafa8d-49da-453c-ab85-eedf501dc706 with last" +
                    " InvoiceId", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 84
 testRunner.Then("User refresh the page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 85
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 86
 testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table5 = new TechTalk.SpecFlow.Table(new string[] {
                        "ForPayment",
                        "Processing",
                        "Cancelled",
                        "Completed"});
            table5.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table5.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table5.AddRow(new string[] {
                        "+6.30",
                        "0.00",
                        "0.00",
                        "0.00"});
#line 87
 testRunner.Given("User see 0-level refferer \'AvailableForPayment\' table with updated columns:", ((string)(null)), table5, "Given ");
#line 92
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 93
 testRunner.Then("Memorize eWallet section", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 96
 testRunner.Given("User clicks on \"Перевести на кошелек\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 97
 testRunner.Then("Success message \"Бонусное вознаграждение успешно зачислено на ваш кошелек×\" appea" +
                    "rs", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 98
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table6 = new TechTalk.SpecFlow.Table(new string[] {
                        "ForPayment",
                        "Processing",
                        "Cancelled",
                        "Completed"});
            table6.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table6.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table6.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "+6.30"});
#line 99
 testRunner.Given("User see 0-level refferer \'AvailableForPayment\' table with updated columns:", ((string)(null)), table6, "Given ");
#line 104
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table7 = new TechTalk.SpecFlow.Table(new string[] {
                        "USD",
                        "EUR",
                        "RUB"});
            table7.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "+6.30"});
#line 105
 testRunner.Then("eWallet updated sections are:", ((string)(null)), table7, "Then ");
#line 110
    testRunner.Then("Operator confirms Invoice refund", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table8 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationType",
                        "Recipient"});
            table8.AddRow(new string[] {
                        "20",
                        "+70002342342"});
#line 111
    testRunner.Then("User gets VerificationCode in table \'ConfirmationCodes\' where:", ((string)(null)), table8, "Then ");
#line 114
    testRunner.Then("Operator refunds last invoice for UserId=89fafa8d-49da-453c-ab85-eedf501dc706", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 115
 testRunner.Then("User refresh the page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 118
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 119
 testRunner.Then("User expands Payment Table", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table9 = new TechTalk.SpecFlow.Table(new string[] {
                        "ForPayment",
                        "Processing",
                        "Cancelled",
                        "Completed"});
            table9.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table9.AddRow(new string[] {
                        "0.00",
                        "0.00",
                        "0.00",
                        "0.00"});
            table9.AddRow(new string[] {
                        "-3.15",
                        "0.00",
                        "+3.15",
                        "+6.30"});
#line 120
 testRunner.Given("User see 0-level refferer \'AvailableForPayment\' table with updated columns:", ((string)(null)), table9, "Given ");
#line 125
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 126
 testRunner.Given("User clicks on Отчеты menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table10 = new TechTalk.SpecFlow.Table(new string[] {
                        "Date",
                        "Name",
                        "Amount"});
            table10.AddRow(new string[] {
                        "**DD.MM.YY**",
                        "Внутренний перевод",
                        "₽ 6.30"});
#line 127
 testRunner.Given("User see transactions list contains:", ((string)(null)), table10, "Given ");
#line 146
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 147
 testRunner.Given("User signin \"Epayments\" with \"nikitatest206@qa.swiftcom.uk\" password \"72621010Aba" +
                    "c\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 148
 testRunner.Given("User clicks on Перевести menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 149
 testRunner.Given("User clicks on \"Другому человеку\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 150
 testRunner.Then("Section \'Amount including fees\' is: $ 0.00 (Комиссия: $ 0.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 151
 testRunner.Then("\'Получатель\' set to \'000304699\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 152
 testRunner.Then("\'Со счета\' selector set to \'RUB\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 153
 testRunner.Then("\'Отдаваемая сумма\' set to \'1000\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 154
 testRunner.Given("Set StartTime for DB search", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 155
 testRunner.Then("Section \'Amount including fees\' is: ₽ 1 003.00 (Комиссия: ₽ 3.00)", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 156
 testRunner.Given("User clicks on \"Далее\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 157
 testRunner.Given("User clicks on \"Подтвердить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            TechTalk.SpecFlow.Table table11 = new TechTalk.SpecFlow.Table(new string[] {
                        "OperationType",
                        "Recipient",
                        "UserId",
                        "IsUsed"});
            table11.AddRow(new string[] {
                        "MassPayment",
                        "+70276111299",
                        "8e80007b-62a8-471b-b5ca-4e2c622c56d9",
                        "false"});
#line 158
 testRunner.Then("User type SMS sent to:", ((string)(null)), table11, "Then ");
#line 161
 testRunner.Given("User clicks on \"Оплатить\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 162
 testRunner.Then("User gets message \"Платеж успешно отправлен\" on Multiform", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 163
 testRunner.Then("Send event to epacash for UserId = 8e80007b-62a8-471b-b5ca-4e2c622c56d9 with last" +
                    " InvoiceId", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 165
 testRunner.Given("User LogOut", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line hidden
            this.ScenarioCleanup();
        }
        
        [NUnit.Framework.TestAttribute()]
        [NUnit.Framework.DescriptionAttribute("Создание/редактирование/удаление/восстановление партнерской ссылки")]
        [NUnit.Framework.CategoryAttribute("837633")]
        public virtual void СозданиеРедактированиеУдалениеВосстановлениеПартнерскойСсылки()
        {
            TechTalk.SpecFlow.ScenarioInfo scenarioInfo = new TechTalk.SpecFlow.ScenarioInfo("Создание/редактирование/удаление/восстановление партнерской ссылки", new string[] {
                        "837633"});
#line 170
this.ScenarioSetup(scenarioInfo);
#line 171
 testRunner.Given("User goes to SignIn page", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 172
  testRunner.Given("User signin \"Epayments\" with \"4edbb445feb0a4feac95e9fa22.autotest@qa.swiftcom.uk\"" +
                    " password \"72621010Abac\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 173
 testRunner.Given("User clicks on Партнерская программа menu", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 174
 testRunner.Then("User clicks on ADD", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 175
 testRunner.Then("User type Link reference", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 176
 testRunner.Then("\'Целевая страница\' value is \'https://www.sandbox.epayments.com\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 177
 testRunner.Given("Affiliate link value is \"https://sandbox.epacash.com/\"+AffiliateLink", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 178
 testRunner.Given("User clicks on button \"Сохранить\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 179
 testRunner.Then("Success message \"Партнерская ссылка создана×\" appears", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table12 = new TechTalk.SpecFlow.Table(new string[] {
                        "LinkNames",
                        "Transitions",
                        "Registrations",
                        "ForPayment",
                        "Processing",
                        "Cancelled"});
            table12.AddRow(new string[] {
                        "**link**",
                        "0",
                        "0",
                        "0.00",
                        "0.00",
                        "0.00"});
#line 180
 testRunner.Given("User see active partner links contains:", ((string)(null)), table12, "Given ");
#line 183
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 184
 testRunner.Given("User clicks on created partner link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 185
 testRunner.Then("User clicks on \"Редактировать\" on Partner Link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 186
 testRunner.Then("User type Link reference", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 187
 testRunner.Then("\'Целевая страница\' value is \'https://www.sandbox.epayments.com\'", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 188
 testRunner.Given("Affiliate link value is \"https://sandbox.epacash.com/\"+AffiliateLink", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 189
 testRunner.Given("User clicks on \"Сохранить\"", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 190
 testRunner.Then("Success message \"Партнерская ссылка сохранена×\" appears", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table13 = new TechTalk.SpecFlow.Table(new string[] {
                        "LinkNames",
                        "Transitions",
                        "Registrations",
                        "ForPayment",
                        "Processing",
                        "Cancelled"});
            table13.AddRow(new string[] {
                        "**link**",
                        "0",
                        "0",
                        "0.00",
                        "0.00",
                        "0.00"});
#line 191
 testRunner.Given("User see active partner links contains:", ((string)(null)), table13, "Given ");
#line 195
 testRunner.Given("User clicks on edited partner link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 196
 testRunner.Then("User clicks on \"Удалить\" on Partner Link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 197
 testRunner.Then("Make screenshot", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 198
 testRunner.Then("Click on Удалить on Modal Window", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 199
 testRunner.Then("Deleted Partner link is inactive", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 200
  testRunner.Given("User clicks on edited partner link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 201
 testRunner.Then("User clicks on \"Восстановить\" on Partner Link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 202
 testRunner.Then("Click on Восстановить on Modal Window", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            TechTalk.SpecFlow.Table table14 = new TechTalk.SpecFlow.Table(new string[] {
                        "LinkNames",
                        "Transitions",
                        "Registrations",
                        "ForPayment",
                        "Processing",
                        "Cancelled"});
            table14.AddRow(new string[] {
                        "**link**",
                        "0",
                        "0",
                        "0.00",
                        "0.00",
                        "0.00"});
#line 203
 testRunner.Given("User see active partner links contains:", ((string)(null)), table14, "Given ");
#line 206
 testRunner.Given("User clicks on edited partner link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Given ");
#line 207
 testRunner.Then("User clicks on \"Удалить\" on Partner Link", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line 208
 testRunner.Then("Click on Отмена on Modal Window", ((string)(null)), ((TechTalk.SpecFlow.Table)(null)), "Then ");
#line hidden
            this.ScenarioCleanup();
        }
    }
}
#pragma warning restore
#endregion