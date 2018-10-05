using System;

namespace ePayments.Tests.Web.Data
{
    /// <summary>
    /// TicketsList
    /// </summary>
    public class TicketsList
    {
        /// <summary>
        /// Приоритет уведомления
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Тип сообщения
        /// </summary>
        public string From { get; set; }

        /// <summary>
        /// Последнее сообщение
        /// </summary>
        public string LastMessage { get; set; }

        /// <summary>
        ///Дата последнего сообщения
        /// </summary>
        public DateTime Date { get; set; }
    }
}