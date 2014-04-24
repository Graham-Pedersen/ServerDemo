using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Reader
{
    public class Reader
    {
        private static Thread inputThread;
        private static AutoResetEvent getInput, gotInput;
        private static string input;

        static Reader()
        {
            inputThread = new Thread(reader);
            inputThread.IsBackground = true;
            inputThread.Start();
            getInput = new AutoResetEvent(false);
            gotInput = new AutoResetEvent(false);
        }

        private static void reader()
        {
            while (true)
            {
                getInput.WaitOne();
                input = Console.ReadLine();
                gotInput.Set();
            }
        }

        public static string ReadLine(int timeOutMillisecs)
        {
            getInput.Set();
            bool success = gotInput.WaitOne(timeOutMillisecs);
            if (success)
            {
                Console.SetCursorPosition(0, Console.CursorTop -1);
                ClearCurrentConsoleLine();
                return input;
            }
            else
                return "";
        }

        public static void ClearCurrentConsoleLine()
        {
            int currentLineCursor = Console.CursorTop;
            Console.SetCursorPosition(0, Console.CursorTop);
            for (int i = 0; i < Console.WindowWidth; i++)
                Console.Write(" ");
            Console.SetCursorPosition(0, currentLineCursor);
        }

        public static Byte[] makeByteArr(int size)
        {
            return new Byte[size];
        }
    }
}
