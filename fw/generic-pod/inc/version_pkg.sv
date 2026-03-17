
`default_nettype none

`define VERSION_MAJOR 0
`define VERSION_MINOR 1
`define VERSION_PATCH 0
`define VERSION_BUILD 0

package version_pkg;
    // placeholder for generated file
    typedef struct packed {
        logic [7:0] major;
        logic [7:0] minor;
        logic [7:0] patch;
        logic [7:0] build;
    } version_t;

    version_t version = '{major: `VERSION_MAJOR, minor: `VERSION_MINOR, patch: `VERSION_PATCH, build: `VERSION_BUILD};

    localparam int HASH_LENGTH = 28;    // 7 characters minimum for hex git hash
    localparam int STATE_LENGTH = 4;    // One character for state 0x0 for clean, 0xF for dirty
    localparam int RAW_LENGTH = STATE_LENGTH + HASH_LENGTH;

    typedef union packed {
        struct packed {
            logic [HASH_LENGTH-1:0] hash;
            logic [STATE_LENGTH-1:0] state; // state indicates if the git repository has uncommitted changes
        } fields;
        logic [RAW_LENGTH-1:0] raw;
    } version_hash_t;

    // These values are replaced by the version generation script
    localparam DEFAULT_VERSION_HASH = 'hBADC0DE;
    localparam DEFAULT_VERSION_STATE = 'hf;

    // Function to initialize a version_hash_t variable (using ref)
    function automatic void init_version_hash(ref version_hash_t vh);
        vh.fields.hash = DEFAULT_VERSION_HASH;
        vh.fields.state = DEFAULT_VERSION_STATE;
    endfunction

endpackage

`default_nettype wire // restore default net type
