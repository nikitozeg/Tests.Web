using System;

namespace ePayments.Tests.Web.Constants
{
    public class Locators
    {
        #region EPA site
        //Sign In page
        public static String RegistrationView = ".main-welcome";
        public static String PhoneRadioBtn = "#acc-type-phone";
        public static String Login = "#loginField";
        public static String RegistrationBtn = ".button.large.success";

        //Login page
        public static String LanguageDropdown = " .dropdown";

        //Sidebar
        public static String Sidebar = "aside.sidebar-nav";
        public static String Support = " [href*= 'support']";
        public static String Counter = " [ng-show*= 'support']";
        public static String InvitesLocator = "[href='#/invites']";
       
 
        //Preloaders
        public static String Hidden = "[class~='ng-hide']";
        public static String Preloader = ".multiform-preloader[ng-show='homeController.isLoading()']";
        public static String PreloaderTicketChat = ".multiform-preloader[ng-show='createForm.loading']";
        public static String PreloaderGrid = "[ng-show*='.isLoading']";
        
        //Auth form
    
        public static String LoginBtn = "button[id='login-button-login']";
       
        //Payment form CARD
        public static String OutgoingValue = "[ng-model=\"model.outgoingAmount.value\"]";
        public static String IncomingValue = "[ng-model=\"model.incomingAmount.value\"]";
        public static String CardFullpan = "input[name='fullPan']";
        public static String CardCardholder = "input[name='externalCardHolder']";

        //Payment form 
        public static String LimitsAndMultiForm = ".action-bar-body";
        public static String CurrentSection = " section.current";
        public static String PaymentFormNextBtn = ".button.next:not([disabled])";
        public static String MultiFormPreloader = " .multiform-preloader";
        public static String PaymentSuccessMsg = ".step-success span";
        public static String PaymentPasswordLocator = ".split-inputs.pay-pass input";
        public static String PaymentPreloaderMsg = ".row.ng-binding";

     


        public static String Uiview = ".wrapper-main>[ui-view]";

        //Support: view
        public static String SupportTitle = ".title";
        public static String SupportCreateTicketForm = "[class='panel clearfix'] [name='createuiform']";
        public static String SupportChatTicketForm = "[class='panel clearfix'] [name='chatuiform']";
        public static String TicketTitle = "[name='ticketTitle']";
        public static String TicketMessage = "[name='ticketMessage']";
        public static String UploadBtn = "input[type='file']";
        public static String TicketsListItem = ".tickets-list-item";
        public static String TicketsActiveTab = ".tabs .active";
         

      
        //Support: tickets overview
        public static String TicketsListTitle = ".tickets-item-title";
        public static String TicketsUnreadCount = "[ng-show*='activeUnreadCount']";
        public static String TicketsListMessage = ".tickets-item-message";
        public static String TicketsListFrom = ".tickets-item-info .right";
        public static String TicketsListDate = ".tickets-item-info .left";

        //Shared elements
        public static String Icons = ".svg-icon-plus";
        public static String AlertBoxFail = ".alert-box.alert";
        public static String AlertBoxSuccess = ".alert-box.success";
        public static String AlertBoxWarning = ".alert-box.warning";
            
        //REGISTER EPAYMENTS PROMO CARDS
        public static String CardDetailsForm = "[class='container'] .panel";
        public static String CreateAccountForm = "[class='container'][ng-show='stepIndex == 2']";
        public static String PersonalDetailsForm = "[class='container'][ng-show='stepIndex == 3']";
        public static String ActivationDetailsForm = "[class='container'][ng-show='stepIndex == 4']";
        public static String SuccessRegistrationForm = "[class='container'][ng-show='stepIndex == 5']";

        public static String RecaptchaFrame = "[class*='recaptcha'] iframe";
        public static String RecaptchaButton = ".recaptcha-checkbox-checkmark";
        public static String PANInputSection = "#panpart_";
        public static String PhoneNumber = "#input-phone";
        public static String ConfirmCodeInput = "#input-confirm-code";
        public static String RecaptchaChecked = ".recaptcha-checkbox-checked";
        public static String FirstName = "#input-first-name";
        public static String LastName = "#input-last-name";
        public static String DOB = "#input-date-of-birth";
        public static String Email = "#input-email";
        public static String Citizenship = "#citizenship";

        public static String Country = "#country";
        public static String State = "#state";
        public static String City = "#city";
        public static String Index = "#index";
        public static String Address = "#adress";
        public static String SecretName = "#secret-name";
        public static String SecretDate = "#secret-date";
        public static String SecretPlace = "#secret-place";
        public static String SecretCode = "#secret-code";
        public static String SuccessMessage = " .small-margin-bottom-3";



        //Common
        public static String InputSubmit = "input[type='submit']";
        public static String Password = "input[type='password']";
        public static String ConfirmCode = "input[type='text']";
        public static String Disabled = "[disabled='disabled']";
        public static String NotDisabled = ":not([disabled])";
        public static String PreloaderMain = " .multiform-preloader";
        public static String ParentNode = "/parent::";
        public static String UISelectSearch = ".ui-select-search";
        public static String UISelectChoices= ".ui-select-choices:not([class*='ng-hide'])";
        public static String UISelectedInput= ".selectize-input";
        public static String ErrorMsg= "small.error";

           
        #endregion

    }
}
