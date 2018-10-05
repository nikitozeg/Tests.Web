namespace ePayments.Tests.Web.Data
{

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://schemas.xmlsoap.org/soap/envelope/")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope", Namespace = "http://schemas.xmlsoap.org/soap/envelope/", IsNullable = false)]
    public class CardHolderDetailsEnquiryV2
    {

        private object headerField;

        private CardHolderDetailsEnquiryV2EnvelopeBody bodyField;

        /// <remarks/>
        public object Header
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
        public CardHolderDetailsEnquiryV2EnvelopeBody Body
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
    public partial class CardHolderDetailsEnquiryV2EnvelopeBody
    {

        private Ws_CardHolder_Details_Enquiry_V2Response ws_CardHolder_Details_Enquiry_V2ResponseField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
        public Ws_CardHolder_Details_Enquiry_V2Response Ws_CardHolder_Details_Enquiry_V2Response
        {
            get
            {
                return this.ws_CardHolder_Details_Enquiry_V2ResponseField;
            }
            set
            {
                this.ws_CardHolder_Details_Enquiry_V2ResponseField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope", Namespace = "http://www.globalprocessing.ae/HyperionWeb", IsNullable = false)]
    public partial class Ws_CardHolder_Details_Enquiry_V2Response
    {

        private Ws_CardHolder_Details_Enquiry_V2Result ws_CardHolder_Details_Enquiry_V2ResultField;

        /// <remarks/>
        public Ws_CardHolder_Details_Enquiry_V2Result Ws_CardHolder_Details_Enquiry_V2Result
        {
            get
            {
                return this.ws_CardHolder_Details_Enquiry_V2ResultField;
            }
            set
            {
                this.ws_CardHolder_Details_Enquiry_V2ResultField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
    public partial class Ws_CardHolder_Details_Enquiry_V2Result
    {

        private string wSIDField;

        private string issCodeField;

        private byte txnCodeField;

        private System.DateTime locDateField;

        private uint locTimeField;

        private string custAccountField;

        private uint publicTokenField;

        private System.DateTime dOBField;

        private byte statCodeField;

        private object titleField;

        private string firstNameField;

        private string lastNameField;

        private string addrl1Field;

        private string addrl2Field;

        private object addrl3Field;

        private string cityField;

        private string postCodeField;

        private ushort countryField;

        private string telField;

        private object workAddrl1Field;

        private object workAddrl2Field;

        private object workAddrl3Field;

        private object workCityField;

        private object workPostCodeField;

        private object workCountyField;

        private object workCountryField;

        private object workTelField;

        private object eMailField;

        private object faxField;

        private string pOBoxField;

        private long mobTelField;

        private object maritalStatusField;

        private object sexField;

        private object crdProductField;

        private string embossNameField;

        private byte refuseCheckField;

        private byte mailShotsField;

        private object discretField;

        private object usrDataField;

        private object usrData1Field;

        private object usrData2Field;

        private object usrData3Field;

        private object usrData4Field;

        private string currCodeField;

        private string expDateField;

        private System.DateTime effDateField;

        private string svcCodeField;

        private byte additionalNoField;

        private System.DateTime dateCreatedField;

        private object dateActivatedField;

        private string crdDesignField;

        private byte pINField;

        private byte dlvMethodField;

        private string imageIDField;

        private object brnCodeField;

        private byte reNewField;

        private object denyMCCField;

        private object denySVCField;

        private object accTypeField;

        private string cVC2Field;

        private object dlvTitleField;

        private string dlvFirstNameField;

        private string dlvLastNameField;

        private string dlvAddrL1Field;

        private string dlvAddrL2Field;

        private string dlvAddrL3Field;

        private string dlvCityField;

        private string dlvCountyField;

        private ushort dlvCountryField;

        private string dlvTelField;

        private object dlvEffDateField;

        private object dlvExpDateField;

        private object isoLangField;

        private System.DateTime sysDateField;

        private byte actionCodeField;

        private object vanityNameField;

        private string dlvPostcodeField;

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
        public byte TxnCode
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
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime LocDate
        {
            get
            {
                return this.locDateField;
            }
            set
            {
                this.locDateField = value;
            }
        }

        /// <remarks/>
        public uint LocTime
        {
            get
            {
                return this.locTimeField;
            }
            set
            {
                this.locTimeField = value;
            }
        }

        /// <remarks/>
        public string CustAccount
        {
            get
            {
                return this.custAccountField;
            }
            set
            {
                this.custAccountField = value;
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
        public byte StatCode
        {
            get
            {
                return this.statCodeField;
            }
            set
            {
                this.statCodeField = value;
            }
        }

        /// <remarks/>
        public object Title
        {
            get
            {
                return this.titleField;
            }
            set
            {
                this.titleField = value;
            }
        }

        /// <remarks/>
        public string FirstName
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
        public string LastName
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
        public string Addrl1
        {
            get
            {
                return this.addrl1Field;
            }
            set
            {
                this.addrl1Field = value;
            }
        }

        /// <remarks/>
        public string Addrl2
        {
            get
            {
                return this.addrl2Field;
            }
            set
            {
                this.addrl2Field = value;
            }
        }

        /// <remarks/>
        public object Addrl3
        {
            get
            {
                return this.addrl3Field;
            }
            set
            {
                this.addrl3Field = value;
            }
        }

        /// <remarks/>
        public string City
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
        public string PostCode
        {
            get
            {
                return this.postCodeField;
            }
            set
            {
                this.postCodeField = value;
            }
        }

        /// <remarks/>
        public ushort Country
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
        public string Tel
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
        public object WorkAddrl1
        {
            get
            {
                return this.workAddrl1Field;
            }
            set
            {
                this.workAddrl1Field = value;
            }
        }

        /// <remarks/>
        public object WorkAddrl2
        {
            get
            {
                return this.workAddrl2Field;
            }
            set
            {
                this.workAddrl2Field = value;
            }
        }

        /// <remarks/>
        public object WorkAddrl3
        {
            get
            {
                return this.workAddrl3Field;
            }
            set
            {
                this.workAddrl3Field = value;
            }
        }

        /// <remarks/>
        public object WorkCity
        {
            get
            {
                return this.workCityField;
            }
            set
            {
                this.workCityField = value;
            }
        }

        /// <remarks/>
        public object WorkPostCode
        {
            get
            {
                return this.workPostCodeField;
            }
            set
            {
                this.workPostCodeField = value;
            }
        }

        /// <remarks/>
        public object WorkCounty
        {
            get
            {
                return this.workCountyField;
            }
            set
            {
                this.workCountyField = value;
            }
        }

        /// <remarks/>
        public object WorkCountry
        {
            get
            {
                return this.workCountryField;
            }
            set
            {
                this.workCountryField = value;
            }
        }

        /// <remarks/>
        public object WorkTel
        {
            get
            {
                return this.workTelField;
            }
            set
            {
                this.workTelField = value;
            }
        }

        /// <remarks/>
        public object EMail
        {
            get
            {
                return this.eMailField;
            }
            set
            {
                this.eMailField = value;
            }
        }

        /// <remarks/>
        public object Fax
        {
            get
            {
                return this.faxField;
            }
            set
            {
                this.faxField = value;
            }
        }

        /// <remarks/>
        public string POBox
        {
            get
            {
                return this.pOBoxField;
            }
            set
            {
                this.pOBoxField = value;
            }
        }

        /// <remarks/>
        public long MobTel
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
        public object MaritalStatus
        {
            get
            {
                return this.maritalStatusField;
            }
            set
            {
                this.maritalStatusField = value;
            }
        }

        /// <remarks/>
        public object Sex
        {
            get
            {
                return this.sexField;
            }
            set
            {
                this.sexField = value;
            }
        }

        /// <remarks/>
        public object CrdProduct
        {
            get
            {
                return this.crdProductField;
            }
            set
            {
                this.crdProductField = value;
            }
        }

        /// <remarks/>
        public string EmbossName
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
        public byte RefuseCheck
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
        public byte MailShots
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
        public object Discret
        {
            get
            {
                return this.discretField;
            }
            set
            {
                this.discretField = value;
            }
        }

        /// <remarks/>
        public object UsrData
        {
            get
            {
                return this.usrDataField;
            }
            set
            {
                this.usrDataField = value;
            }
        }

        /// <remarks/>
        public object UsrData1
        {
            get
            {
                return this.usrData1Field;
            }
            set
            {
                this.usrData1Field = value;
            }
        }

        /// <remarks/>
        public object UsrData2
        {
            get
            {
                return this.usrData2Field;
            }
            set
            {
                this.usrData2Field = value;
            }
        }

        /// <remarks/>
        public object UsrData3
        {
            get
            {
                return this.usrData3Field;
            }
            set
            {
                this.usrData3Field = value;
            }
        }

        /// <remarks/>
        public object UsrData4
        {
            get
            {
                return this.usrData4Field;
            }
            set
            {
                this.usrData4Field = value;
            }
        }

        /// <remarks/>
        public string CurrCode
        {
            get
            {
                return this.currCodeField;
            }
            set
            {
                this.currCodeField = value;
            }
        }

        /// <remarks/>
        public string ExpDate
        {
            get
            {
                return this.expDateField;
            }
            set
            {
                this.expDateField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime EffDate
        {
            get
            {
                return this.effDateField;
            }
            set
            {
                this.effDateField = value;
            }
        }

        /// <remarks/>
        public string SvcCode
        {
            get
            {
                return this.svcCodeField;
            }
            set
            {
                this.svcCodeField = value;
            }
        }

        /// <remarks/>
        public byte AdditionalNo
        {
            get
            {
                return this.additionalNoField;
            }
            set
            {
                this.additionalNoField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime DateCreated
        {
            get
            {
                return this.dateCreatedField;
            }
            set
            {
                this.dateCreatedField = value;
            }
        }

        /// <remarks/>
        public object DateActivated
        {
            get
            {
                return this.dateActivatedField;
            }
            set
            {
                this.dateActivatedField = value;
            }
        }

        /// <remarks/>
        public string CrdDesign
        {
            get
            {
                return this.crdDesignField;
            }
            set
            {
                this.crdDesignField = value;
            }
        }

        /// <remarks/>
        public byte PIN
        {
            get
            {
                return this.pINField;
            }
            set
            {
                this.pINField = value;
            }
        }

        /// <remarks/>
        public byte DlvMethod
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
        public string ImageID
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
        public object BrnCode
        {
            get
            {
                return this.brnCodeField;
            }
            set
            {
                this.brnCodeField = value;
            }
        }

        /// <remarks/>
        public byte ReNew
        {
            get
            {
                return this.reNewField;
            }
            set
            {
                this.reNewField = value;
            }
        }

        /// <remarks/>
        public object DenyMCC
        {
            get
            {
                return this.denyMCCField;
            }
            set
            {
                this.denyMCCField = value;
            }
        }

        /// <remarks/>
        public object DenySVC
        {
            get
            {
                return this.denySVCField;
            }
            set
            {
                this.denySVCField = value;
            }
        }

        /// <remarks/>
        public object AccType
        {
            get
            {
                return this.accTypeField;
            }
            set
            {
                this.accTypeField = value;
            }
        }

        /// <remarks/>
        public string CVC2
        {
            get
            {
                return this.cVC2Field;
            }
            set
            {
                this.cVC2Field = value;
            }
        }

        /// <remarks/>
        public object DlvTitle
        {
            get
            {
                return this.dlvTitleField;
            }
            set
            {
                this.dlvTitleField = value;
            }
        }

        /// <remarks/>
        public string DlvFirstName
        {
            get
            {
                return this.dlvFirstNameField;
            }
            set
            {
                this.dlvFirstNameField = value;
            }
        }

        /// <remarks/>
        public string DlvLastName
        {
            get
            {
                return this.dlvLastNameField;
            }
            set
            {
                this.dlvLastNameField = value;
            }
        }

        /// <remarks/>
        public string DlvAddrL1
        {
            get
            {
                return this.dlvAddrL1Field;
            }
            set
            {
                this.dlvAddrL1Field = value;
            }
        }

        /// <remarks/>
        public string DlvAddrL2
        {
            get
            {
                return this.dlvAddrL2Field;
            }
            set
            {
                this.dlvAddrL2Field = value;
            }
        }

        /// <remarks/>
        public string DlvAddrL3
        {
            get
            {
                return this.dlvAddrL3Field;
            }
            set
            {
                this.dlvAddrL3Field = value;
            }
        }

        /// <remarks/>
        public string DlvCity
        {
            get
            {
                return this.dlvCityField;
            }
            set
            {
                this.dlvCityField = value;
            }
        }

        /// <remarks/>
        public string DlvCounty
        {
            get
            {
                return this.dlvCountyField;
            }
            set
            {
                this.dlvCountyField = value;
            }
        }

        /// <remarks/>
        public ushort DlvCountry
        {
            get
            {
                return this.dlvCountryField;
            }
            set
            {
                this.dlvCountryField = value;
            }
        }

        /// <remarks/>
        public string DlvTel
        {
            get
            {
                return this.dlvTelField;
            }
            set
            {
                this.dlvTelField = value;
            }
        }

        /// <remarks/>
        public object DlvEffDate
        {
            get
            {
                return this.dlvEffDateField;
            }
            set
            {
                this.dlvEffDateField = value;
            }
        }

        /// <remarks/>
        public object DlvExpDate
        {
            get
            {
                return this.dlvExpDateField;
            }
            set
            {
                this.dlvExpDateField = value;
            }
        }

        /// <remarks/>
        public object IsoLang
        {
            get
            {
                return this.isoLangField;
            }
            set
            {
                this.isoLangField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime SysDate
        {
            get
            {
                return this.sysDateField;
            }
            set
            {
                this.sysDateField = value;
            }
        }

        /// <remarks/>
        public byte ActionCode
        {
            get
            {
                return this.actionCodeField;
            }
            set
            {
                this.actionCodeField = value;
            }
        }

        /// <remarks/>
        public object VanityName
        {
            get
            {
                return this.vanityNameField;
            }
            set
            {
                this.vanityNameField = value;
            }
        }

        /// <remarks/>
        public string DlvPostcode
        {
            get
            {
                return this.dlvPostcodeField;
            }
            set
            {
                this.dlvPostcodeField = value;
            }
        }
    }


}