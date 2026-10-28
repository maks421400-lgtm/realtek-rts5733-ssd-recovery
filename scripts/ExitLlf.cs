
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
using System.Diagnostics;
public static class RealtekExitLlf {
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern SafeFileHandle CreateFile(string path,uint access,uint share,IntPtr sa,uint creation,uint flags,IntPtr template);
 [DllImport("kernel32.dll", SetLastError=true)] static extern bool DeviceIoControl(SafeFileHandle h,uint code,byte[] input,uint ilen,byte[] output,uint olen,out uint returned,IntPtr ov);
 public static string Run(int number, string expectedSerial) {
  if(IntPtr.Size!=8) throw new Exception("Requires 64-bit process");
  using(var h=CreateFile(@"\\.\PhysicalDrive"+number,0xC0000000,3,IntPtr.Zero,3,0,IntPtr.Zero)) {
   if(h.IsInvalid) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
   // Recheck the actual opened SATA handle, not only the Windows disk index.
   byte[] query=new byte[12], desc=new byte[4096]; uint n;
   if(!DeviceIoControl(h,0x2D1400,query,12,desc,4096,out n,IntPtr.Zero)) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
   uint so=BitConverter.ToUInt32(desc,24), bus=BitConverter.ToUInt32(desc,28);
   if(so==0 || so>=n || bus!=11) throw new Exception("Handle is not SATA storage");
   int end=Array.IndexOf(desc,(byte)0,(int)so); if(end<0) throw new Exception("Bad descriptor");
   string serial=System.Text.Encoding.ASCII.GetString(desc,(int)so,end-(int)so).Trim();
   if(serial!=expectedSerial) throw new Exception("Opened handle serial mismatch");
   byte[] length=new byte[8];
   if(!DeviceIoControl(h,0x7405c,null,0,length,8,out n,IntPtr.Zero)||BitConverter.ToInt64(length,0)!=1179136L)throw new Exception("Handle capacity differs from service state");
   byte[] b=new byte[48];
   b[0]=48; b[2]=0;
   Array.Copy(BitConverter.GetBytes((uint)30),0,b,12,4);
   b[40]=4; b[45]=0xE0; b[46]=0xFC;
   var sw=Stopwatch.StartNew();
   bool ok=DeviceIoControl(h,0x4D02C,b,(uint)b.Length,b,(uint)b.Length,out n,IntPtr.Zero);
   int error=ok?0:Marshal.GetLastWin32Error(); sw.Stop();
   return "utc="+DateTime.UtcNow.ToString("o")+"\ncommand=ATA SetFWMode FC feature04 count00 NORMAL; matched RtsAtad.dll RaSetFWMode\nwin32_ok="+ok+"\nwin32_error="+error+"\nelapsed_ms="+sw.ElapsedMilliseconds+"\nbytes_returned="+n+"\ntaskfile="+BitConverter.ToString(b,40,8)+"\nprevious="+BitConverter.ToString(b,32,8)+"\nraw="+BitConverter.ToString(b);

  }
 }
}
