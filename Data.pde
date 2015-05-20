class Data {
  public final int CHANNEL_NUM  = 3;
  public final int HISTORY_TIME = 5;
  public final int SAMPLE_RATE  = 100;
  
  public void Data() {
    acc = new short[CHANNEL_NUM][];
    for(int i = 0; i < CHANNEL_NUM; i++)
      acc[i] = new short[HISTORY_TIME * SAMPLE_RATE];
  }
  
  public int index;
  public short[][] acc;
}
