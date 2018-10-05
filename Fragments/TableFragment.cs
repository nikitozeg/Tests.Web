using ePayments.Tests.Web.WebDriver;
using FluentAssertions;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Reflection;
using System.Threading;

namespace ePayments.Tests.Web.Fragments
{
    static class TableFragment
    {
        /// <summary>
        /// Convert any Table from UI
        /// </summary>
        /// <returns>Found table</returns>
        public static IEnumerable<T> GetUITable<T>(DataGridComponent component, string locator, int tableIndex)
        {
            var table = component.FindElements(locator + " table tbody")[tableIndex];

            int counter = 0;
            while (!table.Displayed && counter < 10)
            {
                Thread.Sleep(200);
                counter++;
            }

            return ConvertTableRowsToList<T>(table.FindElements(By.CssSelector("tr")));
        }

        /// <summary>
        /// Проверить ожидаемую таблицу с фактической на UI
        /// </summary>
        /// <typeparam name="T">Тип элемента таблицы</typeparam>
        /// <param name="grid">Элемент содержащий фактическую таблицу на UI</param>
        /// <param name="locator">Локатор фактической таблицы</param>
        /// <param name="expectedTable">Ожидаемая таблица</param>
        /// <param name="tableIndex">Индекс фактической таблицы</param>
        public static void CheckTables<T>(DataGridComponent grid, string locator, List<T> expectedTable,
            int tableIndex = 0)
        {
            GetUITable<T>(grid, locator, tableIndex)
                .ShouldBeEquivalentTo(expectedTable,
                    $"Table {typeof(T).FullName} не соответствуют ожидаемым");
        }

        /// <summary>
        /// Проверить ожидаемую таблицу с фактической на UI с учетом порядка 
        /// </summary>
        /// <typeparam name="T">Тип элемента таблицы</typeparam>
        /// <param name="grid">Элемент содержащий фактическую таблицу на UI</param>
        /// <param name="locator">Локатор фактической таблицы</param>
        /// <param name="expectedTable">Ожидаемая таблица</param>
        /// <param name="tableIndex">Индекс фактической таблицы</param>
        public static void CheckTablesWithOrder<T>(DataGridComponent grid, string locator, List<T> expectedTable,
            int tableIndex = 0)
        {
            GetUITable<T>(grid, locator, tableIndex)
                .ShouldBeEquivalentTo(expectedTable, options => options.WithStrictOrdering(),
                    $"Table {typeof(T).FullName} не соответствуют ожидаемым");
        }

        private static List<T> ConvertTableRowsToList<T>(ReadOnlyCollection<IWebElement> rows)
        {
            List<T> list = new List<T>();

            Type myType = typeof(T);
            PropertyInfo[] properties = myType.GetProperties();
            T instance;

            foreach (var cell in rows)
            {
                int i = 0;

                IList<IWebElement> foundcells = cell.FindElements(By.CssSelector("td"));

                if (!foundcells[0].Text.Equals("Дата"))
                {
                    instance = (T) Activator.CreateInstance(typeof(T));

                    foreach (var property in properties)
                    {
                        property.SetValue(instance, foundcells[i].Text.Replace("\r\n", ""), null);
                        i++;
                    }
                    list.Add(instance);
                }
                else if (foundcells[0].Text.Equals("Дата"))
                            {
                                //EPA - 5445: "dd.MM.yyyy, HH:mm:ss"
                                string[] formats = new string[3] {"dd.MM.yyyy HH:mm", "yyyy-MM-dd HH:mm", "dd.MM.yyyy, HH:mm:ss"};
                                DateTime myDate = DateTime.ParseExact(foundcells[1].Text, formats, CultureInfo.InvariantCulture,
                                    DateTimeStyles.AssumeLocal);

                                myDate.Should().BeCloseTo(DateTime.UtcNow.ToLocalTime()
                                    //AddHours(1) - workaround for chrome bug https://bugs.chromium.org/p/chromium/issues/detail?id=865022
            #if SANDBOXCI
                                    .AddHours(1)
            #endif
                                    , 7 * 60 * 1000,
                                    "Date differs from the actual at least on 5min");
                            }
            }
            return list;
        }
    }
}