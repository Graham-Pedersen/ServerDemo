using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Reader;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            Array a = System.Array.CreateInstance(typeof(System.Byte), 100);
            Byte[] b = (Byte[]) a;

            while (true)
            {
                String result = Reader.Reader.ReadLine(1000);
                if (result != "")
                {
                    Console.WriteLine(result);
                }
            }
        }
    }
}
