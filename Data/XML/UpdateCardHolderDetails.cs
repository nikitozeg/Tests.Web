namespace ePayments.Tests.Web.Data
{

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://schemas.xmlsoap.org/soap/envelope/")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope", Namespace = "http://schemas.xmlsoap.org/soap/envelope/", IsNullable = false)]
    public class UpdateCardHolderDetails
    {

        private EnvelopeHeader headerField;

        private EnvelopeBody bodyField;

        /// <remarks/>
        public EnvelopeHeader Header
        {
            get
            {
                return this.headerField;
            }
            set
            {
                this.headerField = value;
            }
        }

        /// <remarks/>
        public EnvelopeBody Body
        {
            get
            {
                return this.bodyField;
            }
            set
            {
                this.bodyField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://schemas.xmlsoap.org/soap/envelope/")]
    public partial class EnvelopeHeader
    {

        private object authSoapHeaderField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
        public object AuthSoapHeader
        {
            get
            {
                return this.authSoapHeaderField;
            }
            set
            {
                this.authSoapHeaderField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://schemas.xmlsoap.org/soap/envelope/")]
    public partial class EnvelopeBody
    {

        private Ws_Update_Cardholder_Details ws_Update_Cardholder_DetailsField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
        public Ws_Update_Cardholder_Details Ws_Update_Cardholder_Details
        {
            get
            {
                return this.ws_Update_Cardholder_DetailsField;
            }
            set
            {
                this.ws_Update_Cardholder_DetailsField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope", Namespace = "http://www.globalprocessing.ae/HyperionWeb", IsNullable = false)]
    public partial class Ws_Update_Cardholder_Details
    {

        private string wSIDField;

        private string issCodeField;

        private string txnCodeField;

        private string authTypeField;

        private System.DateTime dOBField;

        private ushort newAccCodeField;

        private string lastNameField;

        private string firstNameField;

        private string addr1Field;

        private string addr2Field;

        private string cityField;

        private string postcodeField;

        private ushort countryField;

        private long telField;

        private long mobTelField;

        private string embossNameField;

        private string refuseCheckField;

        private string mailShotsField;

        private string pinField;

        private object imageIDField;

        private string renewField;

        private string dlvMethodField;

        private string memoScopeField;

        private string itemSrcField;

        private string dlvfirstNameField;

        private string dlvlastNameField;

        private string dlvaddr1Field;

        private string dlvaddr2Field;

        private string dlvaddr3Field;

        private string dlvcityField;

        private string dlvpostcodeField;

        private string dlvcountyField;

        private ushort dlvcountryField;

        private long dlvtelField;

        private string dlvDaysValidField;

        private string crddesignField;

        private string fundCrdIssNumField;

        private string fundCrdCVCField;

        private string svcSrcField;

        private string svcTypeField;

        private string svcStatusField;

        private string secIDField;

        private string secValPosField;

        private uint publicTokenField;

        private string smsBalanceField;

        private object addr3Field;

        private ushort delv_CodeField;

        /// <remarks/>
        public string WSID
        {
            get
            {
                return this.wSIDField;
            }
            set
            {
                this.wSIDField = value;
            }
        }

        /// <remarks/>
        public string IssCode
        {
            get
            {
                return this.issCodeField;
            }
            set
            {
                this.issCodeField = value;
            }
        }

        /// <remarks/>
        public string TxnCode
        {
            get
            {
                return this.txnCodeField;
            }
            set
            {
                this.txnCodeField = value;
            }
        }

        /// <remarks/>
        public string AuthType
        {
            get
            {
                return this.authTypeField;
            }
            set
            {
                this.authTypeField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime DOB
        {
            get
            {
                return this.dOBField;
            }
            set
            {
                this.dOBField = value;
            }
        }

        /// <remarks/>
        public ushort newAccCode
        {
            get
            {
                return this.newAccCodeField;
            }
            set
            {
                this.newAccCodeField = value;
            }
        }

        /// <remarks/>
        public string lastName
        {
            get
            {
                return this.lastNameField;
            }
            set
            {
                this.lastNameField = value;
            }
        }

        /// <remarks/>
        public string firstName
        {
            get
            {
                return this.firstNameField;
            }
            set
            {
                this.firstNameField = value;
            }
        }

        /// <remarks/>
        public string addr1
        {
            get
            {
                return this.addr1Field;
            }
            set
            {
                this.addr1Field = value;
            }
        }

        /// <remarks/>
        public string addr2
        {
            get
            {
                return this.addr2Field;
            }
            set
            {
                this.addr2Field = value;
            }
        }

        /// <remarks/>
        public string city
        {
            get
            {
                return this.cityField;
            }
            set
            {
                this.cityField = value;
            }
        }

        /// <remarks/>
        public string postcode
        {
            get
            {
                return this.postcodeField;
            }
            set
            {
                this.postcodeField = value;
            }
        }

        /// <remarks/>
        public ushort country
        {
            get
            {
                return this.countryField;
            }
            set
            {
                this.countryField = value;
            }
        }

        /// <remarks/>
        public long tel
        {
            get
            {
                return this.telField;
            }
            set
            {
                this.telField = value;
            }
        }

        /// <remarks/>
        public long mobTel
        {
            get
            {
                return this.mobTelField;
            }
            set
            {
                this.mobTelField = value;
            }
        }

        /// <remarks/>
        public string embossName
        {
            get
            {
                return this.embossNameField;
            }
            set
            {
                this.embossNameField = value;
            }
        }

        /// <remarks/>
        public string refuseCheck
        {
            get
            {
                return this.refuseCheckField;
            }
            set
            {
                this.refuseCheckField = value;
            }
        }

        /// <remarks/>
        public string mailShots
        {
            get
            {
                return this.mailShotsField;
            }
            set
            {
                this.mailShotsField = value;
            }
        }

        /// <remarks/>
        public string pin
        {
            get
            {
                return this.pinField;
            }
            set
            {
                this.pinField = value;
            }
        }

        /// <remarks/>
        public object imageID
        {
            get
            {
                return this.imageIDField;
            }
            set
            {
                this.imageIDField = value;
            }
        }

        /// <remarks/>
        public string renew
        {
            get
            {
                return this.renewField;
            }
            set
            {
                this.renewField = value;
            }
        }

        /// <remarks/>
        public string dlvMethod
        {
            get
            {
                return this.dlvMethodField;
            }
            set
            {
                this.dlvMethodField = value;
            }
        }

        /// <remarks/>
        public string memoScope
        {
            get
            {
                return this.memoScopeField;
            }
            set
            {
                this.memoScopeField = value;
            }
        }

        /// <remarks/>
        public string itemSrc
        {
            get
            {
                return this.itemSrcField;
            }
            set
            {
                this.itemSrcField = value;
            }
        }

        /// <remarks/>
        public string dlvfirstName
        {
            get
            {
                return this.dlvfirstNameField;
            }
            set
            {
                this.dlvfirstNameField = value;
            }
        }

        /// <remarks/>
        public string dlvlastName
        {
            get
            {
                return this.dlvlastNameField;
            }
            set
            {
                this.dlvlastNameField = value;
            }
        }

        /// <remarks/>
        public string dlvaddr1
        {
            get
            {
                return this.dlvaddr1Field;
            }
            set
            {
                this.dlvaddr1Field = value;
            }
        }

        /// <remarks/>
        public string dlvaddr2
        {
            get
            {
                return this.dlvaddr2Field;
            }
            set
            {
                this.dlvaddr2Field = value;
            }
        }

        /// <remarks/>
        public string dlvaddr3
        {
            get
            {
                return this.dlvaddr3Field;
            }
            set
            {
                this.dlvaddr3Field = value;
            }
        }

        /// <remarks/>
        public string dlvcity
        {
            get
            {
                return this.dlvcityField;
            }
            set
            {
                this.dlvcityField = value;
            }
        }

        /// <remarks/>
        public string dlvpostcode
        {
            get
            {
                return this.dlvpostcodeField;
            }
            set
            {
                this.dlvpostcodeField = value;
            }
        }

        /// <remarks/>
        public string dlvcounty
        {
            get
            {
                return this.dlvcountyField;
            }
            set
            {
                this.dlvcountyField = value;
            }
        }

        /// <remarks/>
        public ushort dlvcountry
        {
            get
            {
                return this.dlvcountryField;
            }
            set
            {
                this.dlvcountryField = value;
            }
        }

        /// <remarks/>
        public long dlvtel
        {
            get
            {
                return this.dlvtelField;
            }
            set
            {
                this.dlvtelField = value;
            }
        }

        /// <remarks/>
        public string dlvDaysValid
        {
            get
            {
                return this.dlvDaysValidField;
            }
            set
            {
                this.dlvDaysValidField = value;
            }
        }

        /// <remarks/>
        public string crddesign
        {
            get
            {
                return this.crddesignField;
            }
            set
            {
                this.crddesignField = value;
            }
        }

        /// <remarks/>
        public string fundCrdIssNum
        {
            get
            {
                return this.fundCrdIssNumField;
            }
            set
            {
                this.fundCrdIssNumField = value;
            }
        }

        /// <remarks/>
        public string fundCrdCVC
        {
            get
            {
                return this.fundCrdCVCField;
            }
            set
            {
                this.fundCrdCVCField = value;
            }
        }

        /// <remarks/>
        public string svcSrc
        {
            get
            {
                return this.svcSrcField;
            }
            set
            {
                this.svcSrcField = value;
            }
        }

        /// <remarks/>
        public string svcType
        {
            get
            {
                return this.svcTypeField;
            }
            set
            {
                this.svcTypeField = value;
            }
        }

        /// <remarks/>
        public string svcStatus
        {
            get
            {
                return this.svcStatusField;
            }
            set
            {
                this.svcStatusField = value;
            }
        }

        /// <remarks/>
        public string secID
        {
            get
            {
                return this.secIDField;
            }
            set
            {
                this.secIDField = value;
            }
        }

        /// <remarks/>
        public string SecValPos
        {
            get
            {
                return this.secValPosField;
            }
            set
            {
                this.secValPosField = value;
            }
        }

        /// <remarks/>
        public uint PublicToken
        {
            get
            {
                return this.publicTokenField;
            }
            set
            {
                this.publicTokenField = value;
            }
        }

        /// <remarks/>
        public string SmsBalance
        {
            get
            {
                return this.smsBalanceField;
            }
            set
            {
                this.smsBalanceField = value;
            }
        }

        /// <remarks/>
        public object addr3
        {
            get
            {
                return this.addr3Field;
            }
            set
            {
                this.addr3Field = value;
            }
        }

        /// <remarks/>
        public ushort Delv_Code
        {
            get
            {
                return this.delv_CodeField;
            }
            set
            {
                this.delv_CodeField = value;
            }
        }
    }


}