
package lvds_rxtx_pkg;

    typedef struct packed {
        logic [7:0] data;
        logic       is_k;
        // debug
        logic disp;
        logic enc_kin_err;
        logic dec_code_err;
        logic dec_disp_err;
    } symbol_t;

    parameter symbol_t K28_1 = '{default:0, data:8'h3C, is_k:1'b1};
    parameter symbol_t K28_5 = '{default:0, data:8'hBC, is_k:1'b1};

    parameter symbol_t SYNC_STREAM = K28_5;
    parameter symbol_t TRANSACTION_START = K28_1;

endpackage
