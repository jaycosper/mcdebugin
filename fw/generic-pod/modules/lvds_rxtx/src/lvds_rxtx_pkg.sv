
package lvds_rxtx_pkg;

    typedef struct packed {
        logic       valid;
        logic [7:0] data;
        logic       is_k;
        logic       disp;
        // debug from decoder
        logic       code_err;
        logic       disp_err;
    } rxtx_data_t;

    typedef struct packed {
        logic       valid;
        logic [9:0] data;
        logic       disp;
        // debug from encoder
        logic       kin_err;
    } symbol_t;

    parameter rxtx_data_t K28_1 = '{default:0, data:8'h3C, is_k:1'b1};
    parameter rxtx_data_t K28_5 = '{default:0, data:8'hBC, is_k:1'b1};

    parameter rxtx_data_t SYNC_STREAM = K28_5;
    parameter rxtx_data_t TRANSACTION_START = K28_1;

endpackage
