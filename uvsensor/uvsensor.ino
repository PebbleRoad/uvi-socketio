#include <SPI.h>
#include <SFE_CC3000.h>
#include <SFE_CC3000_Client.h>
#include <stdlib.h>
#include <Wire.h>
#include "Adafruit_SI1145.h"

// Pins
#define CC3000_INT      2   // Needs to be an interrupt pin (D2/D3)
#define CC3000_EN       7   // Can be any digital pin
#define CC3000_CS       10  // Preferred is pin 10 on Uno

// Connection info data lengths
#define IP_ADDR_LEN     4   // Length of IP address in bytes
#define MAC_ADDR_LEN    6   // Length of MAC address in bytes

// Constants
char ap_ssid[] = "rye";                               // SSID of network
char ap_password[] = "Vancouver";                     // Password of network
unsigned int ap_security = WLAN_SEC_WPA2;             // Security of network
unsigned int timeout = 30000;                         // Milliseconds
char server[] = "uvi-monitor.herokuapp.com";          // Remote host site
uint16_t port = 80;

String ip_address = "";
String mac_address = "";

bool macAddressSent = false;

// Global Variables
SFE_CC3000 wifi = SFE_CC3000(CC3000_INT, CC3000_EN, CC3000_CS);
SFE_CC3000_Client client = SFE_CC3000_Client(wifi);

// UV sensor..
Adafruit_SI1145 uv = Adafruit_SI1145();

void setup() {
  
  // Initialize Serial port
  Serial.begin(115200);

  if (!uv.begin()) {
    Serial.println("Didn't find Si1145");
    while (1);
  }

  Serial.println();
  Serial.println("---------------------------");
  Serial.println("SparkFun CC3000 - WebClient");
  Serial.println("---------------------------");
  
  // Initialize CC3000 (configure SPI communications)
  if (wifi.init()) {
    Serial.println("CC3000 initialization complete");
  } else {
    Serial.println("Something went wrong during CC3000 init!");
  }
  
  // Connect using DHCP
  Serial.print("Connecting to SSID: ");
  Serial.println(ap_ssid);
  if(!wifi.connect(ap_ssid, ap_security, ap_password, timeout)) {
    Serial.println("Error: Could not connect to AP");
  }

  ip_address = getIPAddress();
  mac_address = getMacAddress();

  Serial.print("IP Address: ");
  Serial.println(ip_address);

  Serial.print("MAC Address: ");
  Serial.println(mac_address);

  sendUVI();
  
}

void loop() {

  // If there are incoming bytes, print them
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }
  
  // If the server has disconnected, stop the client and wifi
  if (!client.connected()) {
    Serial.println();
    Serial.println("closing client..");
    if (!client.close()) {
      Serial.println("Error: Could not close socket");
    }
    delay(1000);
    sendUVI();
  }
  
  // If the server has disconnected, stop the client and wifi
  // if ( !client.connected() ) {
  //   Serial.println();
    
  //   // Close socket
  //   if ( !client.close() ) {
  //     Serial.println("Error: Could not close socket");
  //   }
    
  //   // Disconnect WiFi
  //   if ( !wifi.disconnect() ) {
  //     Serial.println("Error: Could not disconnect from network");
  //   }
    
  //   // Do nothing
  //   Serial.println("Finished WebClient test");
  //   while(true){
  //     delay(1000);
  //   }
  // }
}

void sendUVI () {

  float uvIndex = uv.readUV();
  uvIndex /= 100.0;

  postData(uvIndex);
}

void postData (float uvi) {
  // Make a TCP connection to remote host
  Serial.print("Performing HTTP POST to: ");
  Serial.print(server);
  Serial.print(" - port: ");
  Serial.println(port);

  if (!client.connect(server, port)) {
    Serial.println("Error: Could not make a TCP connection");
  }

  String data = "";
  if (!macAddressSent) {
    data = "uvi=" + String(uvi) + "&mac=" + mac_address;
    macAddressSent = true;
  }
  else {
    data = "uvi=" + String(uvi);
  }

  // Make a HTTP POST request..
  client.println("POST /submit_data HTTP/1.1");
  client.print("Host: ");
  client.println(server);
  client.println("Connection: close");
  client.println("Content-Type: application/x-www-form-urlencoded");
  client.print("Content-Length: ");
  client.println(data.length());
  client.println();
  client.println(data);
  
  client.println();

  Serial.println();

}

String getIPAddress () {
  
  ConnectionInfo connection_info;
  int i;
  String ip_address = "";

  // Gather connection details and print IP address
  if (!wifi.getConnectionInfo(connection_info)) {
    Serial.println("Error: Could not obtain connection details");
  } else {
    for (i = 0; i < IP_ADDR_LEN; i++) {
      // Serial.print(connection_info.ip_address[i]);
      ip_address += connection_info.ip_address[i];
      if ( i < IP_ADDR_LEN - 1 ) {
        // Serial.print(".");
        ip_address += ".";
      }
    }
    // Serial.println();
  }
  return ip_address;
}

String getMacAddress () {
  unsigned char mac_addr[MAC_ADDR_LEN];
  int i;
  String mac = "";
  if (wifi.getMacAddress(mac_addr)) {
    // Serial.print("MAC address: ");
    for (i = 0; i < MAC_ADDR_LEN; i++) {
      if (mac_addr[i] < 0x10) {
        // Serial.print("0");
        mac += "0";
      }
      mac += String(mac_addr[i], HEX);
      // Serial.print(mac_addr[i], HEX);
      if (i < MAC_ADDR_LEN - 1) {
        // Serial.print(":");
        mac += ":";
      }
    }
  }
  else {
    mac = "ERROR: problem reading MAC address..";
  } 
  return mac;
}
