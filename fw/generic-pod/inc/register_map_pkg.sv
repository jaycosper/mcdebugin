
package register_map_pkg;
  typedef struct packed {
    logic [31:0] bits;   // general status word
  } regmap_status_t;

  typedef struct packed {
    logic [27:0] hash;     // [31:4] = 28-bit Git hash,
    logic [3:0] state;     // [3:0] = repo state nibble (0x0 clean, 0xF dirty)
  } regmap_hash_t;

  typedef struct packed {
    regmap_status_t status;
    regmap_hash_t hash;
    // Add more groups later (pins, errors, version, etc.)
  } register_map_t;

endpackage
