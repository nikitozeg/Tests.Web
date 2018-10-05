using Newtonsoft.Json;

namespace ePayments.Tests.Web.Data
{
    public class NPCardCreateRequest
    {
        [JsonProperty("action:Index")]
        public string Action;
        [JsonProperty("CurrentStep")]
        public string CurrentStep;
        [JsonProperty("CardTypeTab.Description")]
        public string Description;
        [JsonProperty("CardTypeTab.CoBrand")]
        public string CoBrand;
        [JsonProperty("CardTypeTab.EmbossingName")]
        public string EmbossingName;
        [JsonProperty("CardTypeTab.NumberOfCards")]
        public string NumberOfCards;
        [JsonProperty("CardTypeTab.DeliveryMethod")]
        public string DeliveryMethod;
        [JsonProperty("CardTypeTab.Kyc")]
        public string Kyc;
        [JsonProperty("CardTypeTab.IsSingleAddress")]
        public bool IsSingleAddress;

        [JsonProperty("CardTypeTab.BulkDeliveryAddress.Country")]
        public string Country;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.County")]
        public string County;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.City")]
        public string City;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.PostCode")]
        public string PostCode;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.DeliveryAddress1")]
        public string DeliveryAddress1;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.DeliveryAddress2")]
        public string DeliveryAddress2;
        [JsonProperty("CardTypeTab.BulkDeliveryAddress.DeliveryAddress3")]
        public string DeliveryAddress3;
    }
}
