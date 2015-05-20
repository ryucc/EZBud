Data     data;
Receiver receiver;
Plotter  plotter;

void setup() {
  data     = new Data();
  receiver = new Receiver(this, data);
  plotter  = new Plotter(this, data);
}

void draw() {
  plotter.draw();
}
