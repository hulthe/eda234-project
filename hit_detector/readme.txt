The hit detector detect the falling edge of the output signals from receivers.
The default value of the output signals from receivers is high(3V). The active value is low(0V). Therefore, we only need to detect the the falling edge which is the sign of getting shot.
Using two 2 FF synchronizers for two kinds of being shot: The sampling clk domain is 100Mhz and the receiver is running at 38kHz so use 2 FF synchronizer is enough to aviod metastability.
