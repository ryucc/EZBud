import processing.core.PApplet;
import processing.serial.*;

class Receiver extends Thread {
  private final String DEVICE       = "/dev/tty.Jason-bt00-DevB";
  private final int    BAUD_RATE    = 460800;
  

  //
  private final int    PACKET_SIZE  = 16;
  private final int    THRESH       = 512;
  private final int    MASK         = 0xff;
  private final int    INVALID      = -1;
  
  //
  private PApplet parent;
  private Data    data;
  private Serial  serial;
  
  private byte[] buffer = new byte[PACKET_SIZE];
  
  //
  public Receiver(PApplet parent, Data data) {
    this.parent = parent;
    this.data = data;
    
    serial = new Serial(parent, DEVICE, BAUD_RATE);
    this.start();
  }
  
  public void run() {
    while(true){
      while(serial.available() > 0) {
        serial.readBytes(buffer);
        
        int pos;
        short val;
        pos = FlagPos(0xf1);
        if((pos != INVALID) && (pos < PACKET_SIZE - 1))
          data.index = (int) buffer[pos + 1];
        for(int i = 0; i < 3; i++) {
          pos = FlagPos(0xf2 + i);
          if((pos != INVALID) && (pos < PACKET_SIZE - 2)) {
            val = (short)((buffer[pos + 1] & MASK) << 8 | (buffer[pos + 2] & MASK));
            if((val < +THRESH) && (val > -THRESH))
              data.acc[i] = val;
          }
        }
      }
      try {
        Thread.sleep(50);
      } catch (InterruptedException e) {}
    }
  }
  
  private int FlagPos(int flag) {
    for(int i = 0; i < PACKET_SIZE; i++)
      if(buffer[i] == (byte) flag)
        return i;
    return INVALID;
  }
}
