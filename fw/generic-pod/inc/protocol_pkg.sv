`timescale 1ns / 1ps

package protocol_pkg;

    parameter int pRXTX_DATA_WIDTH      = 8;
    parameter int pENCODED_DATA_WIDTH   = pRXTX_DATA_WIDTH + 2;

    typedef struct packed {
        logic       valid;
        logic [pRXTX_DATA_WIDTH-1:0] data;
        logic       is_k;
        logic       disp;
        // debug from decoder
        logic       code_err;
        logic       disp_err;
    } rxtx_data_t;

    typedef struct packed {
        logic       valid;
        logic [pENCODED_DATA_WIDTH-1:0] data;
        logic       disp;
        // debug from encoder
        logic       kin_err;
    } symbol_t;

    parameter rxtx_data_t pK28_1 = '{default:0, data:'h3C, is_k:1'b1};
    parameter rxtx_data_t pK28_5 = '{default:0, data:'hBC, is_k:1'b1};

    parameter rxtx_data_t pSYNC_STREAM = pK28_5;
    parameter rxtx_data_t pMESSAGE_START = pK28_1;

    parameter int pMSG_DATA_WIDTH = 32;
    typedef logic [pMSG_DATA_WIDTH-1:0] msg_data_t;

    parameter int pMARKER_WIDTH         = 8;
    parameter int pPAYLOAD_LENGTH_WIDTH = 8;
    parameter int pTAG_WIDTH            = 8;
    parameter int pCMD_RSP_WIDTH        = 8;

    typedef struct packed {
        logic [pMARKER_WIDTH-1:0]           marker;
        logic [pPAYLOAD_LENGTH_WIDTH-1:0]   payload_length;
        logic [pTAG_WIDTH-1:0]              tag;
        logic [pCMD_RSP_WIDTH-1:0]          cmd_rsp;
    } header_t;

    parameter logic [pMARKER_WIDTH-1:0] pHEADER_MARKER_VALID = 'hA5; // marker value to indicate valid header

    parameter int pMSG_CRC_WIDTH = 32;
    typedef logic [pMSG_CRC_WIDTH-1:0] crc_t;

    // parameter int pMAX_PAYLOAD_BYTES = 2**pPAYLOAD_LENGTH_WIDTH - $size(header_t)/8 - $size(crc_t)/8; // 64KB max message size minus header and CRC overhead
    parameter int pMAX_PAYLOAD_DW = 32; // test case 32 DW = 128B

    parameter crc_t pCRC_POLY = 'h04C11DB7;

endpackage
