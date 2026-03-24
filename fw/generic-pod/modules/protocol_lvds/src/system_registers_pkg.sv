`timescale 1ns/1ps

package system_regs_pkg;

  typedef struct packed {
    logic [31:0] status;     // General 32-bit status
    logic [31:0] hash;       // [31:4]=28-bit Git hash, [3:0]=repo state nibble (0x0=clean, 0xF=dirty)
    // Expand here later: pin_states, version, errors, etc.
  } system_status_t;

  typedef struct packed {
    system_status_t status;   // current status block
    // Add more groups later: emulation, debug, pins, etc.
  } general_regs_t;

  localparam int MAX_PAYLOAD_BYTES = 64;
  localparam int CRC_POLY = 32'h04C11DB7;   // Ethernet CRC-32

endpackage
