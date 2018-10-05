using System;

namespace ePayments.Tests.Web.Data
{
    /// <summary>
    /// ChatMessages
    /// </summary>
    public class ChatMessages
    {
        /// <summary>
        /// Тип сообщения
        /// </summary>
        public string From { get; set; }

        /// <summary>
        ///Дата последнего сообщения
        /// </summary>
        public DateTime Date { get; set; }

        /// <summary>
        ///  сообщение
        /// </summary>
        public string ChatMessage { get; set; }
    }

}
