using ePayments.Tests.Common.Extensions;
using ePayments.Tests.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Threading;
using static ePayments.Tests.Web.Constants.Locators;
using static ePayments.Tests.Web.WebDriver.DriverManagerHelper;

namespace ePayments.Tests.Web.WebDriver
{
    /// <summary>
    /// Хелперы 
    /// </summary>
    public class CommonComponentHelper
    {
        public static void WaitPreloaderFinish(String location)
        {
            //Sometimes preloader doesn't appears right after click
            Thread.Sleep(500);

            WaitElementIsPresenceByCss(location + Hidden);
        }

        public static void WaitPreloader(String location)
        {
            WaitElementIsInvisibleByCss(location);
        }

        public static void CaptchaAppears()
        {
            WaitPreloaderFinish(PreloaderGrid);
            WaitElementIsVisibleByCss(RecaptchaFrame);
        }
        
        /// <summary>
        /// Replace templates (marks with ** **) in text, with new values 
        /// </summary>
        /// <param name="text">Text to be replaced</param>
        /// <param name="rate">Rate </param>
        /// <param name="amount">outgoing amount</param>
        /// <param name="purseTransactionId">purseTransactionId</param>
        /// <returns></returns>
        public static string ReplaceString(string text, decimal rate, decimal amount, long? purseTransactionId = null, int? invoiceId = null, string externalTransactionId = null, decimal? fee = null, string email="")
        {
            return
                text
                    .Replace("**OutgoingAmount**", amount.ToString("n", new NumberFormatInfo {NumberGroupSeparator = " "}))
                    .Replace("**rate**", String.Format("{0:0.0000}", rate))
                    .Replace("**rateWM**",  rate.ToString())
                    .Replace("**fee**", fee.ToString())
                    .Replace("**amount + fee**", (fee+amount).ToString())
                    .Replace("**amount * rate**", (amount * rate).RoundBank().ToString("n", new NumberFormatInfo { NumberGroupSeparator = " " }))
                    .Replace("**amount ** rate**", (amount * rate).RoundBank().ToString())
                    .Replace("**amount / rate**", (amount / rate).RoundBank().ToString("n", new NumberFormatInfo { NumberGroupSeparator = " " }))
                    .Replace("**DD.MM.YY**",DateTime.UtcNow.ToLocalTime().ToString("dd.MM.yy"))
                    .Replace("**TPurseTransactionId**", purseTransactionId.ToString())
                    .Replace("**ExternalTransactionId**", externalTransactionId)
                    .Replace("**InvoiceId**", invoiceId.ToString())
                    .Replace("**Receiver**", email)
                    .Replace("**Generated**", DataBuilderHelper.GenerateStringValue(10));
        }

        public static List<T> ReplaceTable<T>(List<T> table, decimal rate, decimal amount, long? purseId = null, int? invoiceId = null, string externalTransactionId = null, decimal? fee = null, string email="")
        {
            PropertyInfo[] properties = typeof(T).GetProperties();


            foreach (var obj in table)
            {
                foreach (PropertyInfo property in properties)
                {
                    var propertyObj = obj.GetType().GetProperty(property.Name);

                    //Replace only not-null and string fields
                    if (propertyObj.GetValue(obj) != null && property.PropertyType == typeof(string))

                        propertyObj.SetValue(obj,
                            ReplaceString(property.GetValue(obj, null).ToString(), rate, amount, purseId,invoiceId, externalTransactionId, fee, email ));

                    // Replace for amount with type Decimal and value==0
                    if ((property.PropertyType == typeof(decimal?) ||property.PropertyType == typeof(decimal)))
                    {
                        if ((Decimal)property.GetValue(obj, null) == 0)
                            propertyObj.SetValue(obj, (amount * rate).RoundBank());
                        
                        //Qiwi provider comission = 2.5 %
                        if ((Decimal)property.GetValue(obj, null) == 0.025m)
                            propertyObj.SetValue(obj, (amount * rate * 0.025m).RoundBank());
                    }

                }
            }
            return table;
        }

      
        public static List<T> ReplaceTableWithList<T>(List<T> table, List<long> list)
        {
            PropertyInfo[] properties = typeof(T).GetProperties();


            foreach (var obj in table)
            {
                foreach (PropertyInfo property in properties)
                {
                    var propertyObj = obj.GetType().GetProperty(property.Name);

                    if (property.PropertyType == typeof(string) && propertyObj.GetValue(obj) != null)
                        propertyObj.SetValue(obj,
                            property.GetValue(obj, null).ToString()
                                .Replace("**TICKET_ID**", list[table.IndexOf(obj)].ToString()));
                }
            }
            return table;
        }
    }
}