using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ePayments.Tests.Web.Data
{

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://schemas.xmlsoap.org/soap/envelope/")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope",Namespace = "http://schemas.xmlsoap.org/soap/envelope/", IsNullable = false)]
    public class CreateCard
    {

        private EnvelopeHeaderCreateCard headerField;

        private CreateCardEnvelopeBody bodyField;

        /// <remarks/>
        public EnvelopeHeaderCreateCard Header
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
        public CreateCardEnvelopeBody Body
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
    public partial class EnvelopeHeaderCreateCard
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
    public class CreateCardEnvelopeBody
    {

        private Ws_CreateCard ws_CreateCardField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
        public Ws_CreateCard Ws_CreateCard
        {
            get
            {
                return this.ws_CreateCardField;
            }
            set
            {
                this.ws_CreateCardField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://www.globalprocessing.ae/HyperionWeb")]
    [System.Xml.Serialization.XmlRootAttribute(ElementName = "Envelope",Namespace = "http://www.globalprocessing.ae/HyperionWeb", IsNullable = false)]
    public class Ws_CreateCard
    {

        private string wSIDField;

        private string issCodeField;

        private byte txnCodeField;

        private string lastNameField;

        private string firstNameField;

        private string addrl1Field;

        private string addrl2Field;

        private string addrl3Field;

        private string cityField;

        private string postCodeField;

        private string countryField;

        private long mobileField;

        private string cardDesignField;

        private System.DateTime dOBField;

        private System.DateTime locDateField;

        private string locTimeField;

        private byte loadValueField;

        private string curCodeField;

        private string accCodeField;

        private byte itemSrcField;

        private byte loadFeeField;

        private byte createImageField;

        private byte createTypeField;

        private string custAccountField;

        private byte activateNowField;

        private string cardNameField;

        private string limitsGroupField;

        private string pERMSGroupField;

        private string productRefField;

        private long fulfil1Field;

        private byte delvMethodField;

        private string imageIdField;

        private bool replacementField;

        private string feeGroupField;

        private string delv_AddrL1Field;

        private string delv_AddrL2Field;

        private string delv_AddrL3Field;

        private string delv_CityField;

        private string delv_CountyField;

        private string delv_PostCodeField;

        private string delv_CountryField;

        private string delv_CodeField;

        private string schedFeeGroupField;

        private string linkageGroupField;

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
        public string Addrl3
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
        public string Country
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
        public long Mobile
        {
            get
            {
                return this.mobileField;
            }
            set
            {
                this.mobileField = value;
            }
        }

        /// <remarks/>
        public string CardDesign
        {
            get
            {
                return this.cardDesignField;
            }
            set
            {
                this.cardDesignField = value;
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
        public string LocTime
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
        public byte LoadValue
        {
            get
            {
                return this.loadValueField;
            }
            set
            {
                this.loadValueField = value;
            }
        }

        /// <remarks/>
        public string CurCode
        {
            get
            {
                return this.curCodeField;
            }
            set
            {
                this.curCodeField = value;
            }
        }

        /// <remarks/>
        public string AccCode
        {
            get
            {
                return this.accCodeField;
            }
            set
            {
                this.accCodeField = value;
            }
        }

        /// <remarks/>
        public byte ItemSrc
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
        public byte LoadFee
        {
            get
            {
                return this.loadFeeField;
            }
            set
            {
                this.loadFeeField = value;
            }
        }

        /// <remarks/>
        public byte CreateImage
        {
            get
            {
                return this.createImageField;
            }
            set
            {
                this.createImageField = value;
            }
        }

        /// <remarks/>
        public byte CreateType
        {
            get
            {
                return this.createTypeField;
            }
            set
            {
                this.createTypeField = value;
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
        public byte ActivateNow
        {
            get
            {
                return this.activateNowField;
            }
            set
            {
                this.activateNowField = value;
            }
        }

        /// <remarks/>
        public string CardName
        {
            get
            {
                return this.cardNameField;
            }
            set
            {
                this.cardNameField = value;
            }
        }

        /// <remarks/>
        public string LimitsGroup
        {
            get
            {
                return this.limitsGroupField;
            }
            set
            {
                this.limitsGroupField = value;
            }
        }

        /// <remarks/>
        public string PERMSGroup
        {
            get
            {
                return this.pERMSGroupField;
            }
            set
            {
                this.pERMSGroupField = value;
            }
        }

        /// <remarks/>
        public string ProductRef
        {
            get
            {
                return this.productRefField;
            }
            set
            {
                this.productRefField = value;
            }
        }

        /// <remarks/>
        public long Fulfil1
        {
            get
            {
                return this.fulfil1Field;
            }
            set
            {
                this.fulfil1Field = value;
            }
        }

        /// <remarks/>
        public byte DelvMethod
        {
            get
            {
                return this.delvMethodField;
            }
            set
            {
                this.delvMethodField = value;
            }
        }

        /// <remarks/>
        public string ImageId
        {
            get
            {
                return this.imageIdField;
            }
            set
            {
                this.imageIdField = value;
            }
        }

        /// <remarks/>
        public bool Replacement
        {
            get
            {
                return this.replacementField;
            }
            set
            {
                this.replacementField = value;
            }
        }

        /// <remarks/>
        public string FeeGroup
        {
            get
            {
                return this.feeGroupField;
            }
            set
            {
                this.feeGroupField = value;
            }
        }

        /// <remarks/>
        public string Delv_AddrL1
        {
            get
            {
                return this.delv_AddrL1Field;
            }
            set
            {
                this.delv_AddrL1Field = value;
            }
        }

        /// <remarks/>
        public string Delv_AddrL2
        {
            get
            {
                return this.delv_AddrL2Field;
            }
            set
            {
                this.delv_AddrL2Field = value;
            }
        }

        /// <remarks/>
        public string Delv_AddrL3
        {
            get
            {
                return this.delv_AddrL3Field;
            }
            set
            {
                this.delv_AddrL3Field = value;
            }
        }

        /// <remarks/>
        public string Delv_City
        {
            get
            {
                return this.delv_CityField;
            }
            set
            {
                this.delv_CityField = value;
            }
        }

        /// <remarks/>
        public string Delv_County
        {
            get
            {
                return this.delv_CountyField;
            }
            set
            {
                this.delv_CountyField = value;
            }
        }

        /// <remarks/>
        public string Delv_PostCode
        {
            get
            {
                return this.delv_PostCodeField;
            }
            set
            {
                this.delv_PostCodeField = value;
            }
        }

        /// <remarks/>
        public string Delv_Country
        {
            get
            {
                return this.delv_CountryField;
            }
            set
            {
                this.delv_CountryField = value;
            }
        }

        /// <remarks/>
        public string Delv_Code
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

        /// <remarks/>
        public string SchedFeeGroup
        {
            get
            {
                return this.schedFeeGroupField;
            }
            set
            {
                this.schedFeeGroupField = value;
            }
        }

        /// <remarks/>
        public string LinkageGroup
        {
            get
            {
                return this.linkageGroupField;
            }
            set
            {
                this.linkageGroupField = value;
            }
        }
    }


}
