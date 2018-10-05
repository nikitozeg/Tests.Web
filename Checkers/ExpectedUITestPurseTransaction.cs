using System;
using ePayments.Tests.Data.Domain.Enum;

namespace ePayments.Tests.Web.Checkers
{
    public sealed class ExpectedUITestPurseTransaction
    {
        /// <summary>Идентификатор секции кошелька</summary>
        public Currency CurrencyId { get; set; }

        /// <summary>Сумма</summary>
        public decimal Amount { get; set; }

        /// <summary>Идентификатор назначение</summary>
        public PurseTransactionDestination DestinationId { get; set; }

        //ToDo создать класс имеющий знания о деталях
        ///// <summary>Дополнительная информация</summary>
        //public string Details { get; set; }

        /// <summary>Направление</summary>
        public string Direction { get; set; }

        /// <summary>Идентификатор пользователя. Поле избыточное. Для повышения производительности запросов</summary>
        public Guid UserId { get; set; }

        /// <summary>Идентификатор кошелька. Поле избыточное. Для повышения производительности запросов</summary>
        public int PurseId { get; set; }

        /// <summary>Номер = количество предыдущих возвратов + этот возврат. Для оригинальной транзакции равен "0"</summary>
        public int RefundCount { get; set; }
    }
}