# See LICENSE for license details.

#*****************************************************************************
# ld_st.S
#-----------------------------------------------------------------------------
#
# Test load and store instructions
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Bypassing Tests
  #-------------------------------------------------------------

  # Test sb and lb (signed byte)
  TEST_LD_ST_BYPASS(2,  lb,  sb, 0xffffffffffffffdd, 0, tdat );
  TEST_LD_ST_BYPASS(3,  lb,  sb, 0xffffffffffffffcd, 1, tdat );
  TEST_LD_ST_BYPASS(4,  lb,  sb, 0xffffffffffffffcc, 2, tdat );
  TEST_LD_ST_BYPASS(5,  lb,  sb, 0xffffffffffffffbc, 3, tdat );
  TEST_LD_ST_BYPASS(6,  lb,  sb, 0xffffffffffffffbb, 4, tdat );
  TEST_LD_ST_BYPASS(7,  lb,  sb, 0xffffffffffffffab, 5, tdat );

  TEST_LD_ST_BYPASS(8,  lb, sb, 0x33, 0, tdat );
  TEST_LD_ST_BYPASS(9,  lb, sb, 0x23, 1, tdat );
  TEST_LD_ST_BYPASS(10, lb, sb, 0x22, 2, tdat );
  TEST_LD_ST_BYPASS(11, lb, sb, 0x12, 3, tdat );
  TEST_LD_ST_BYPASS(12, lb, sb, 0x11, 4, tdat );
  TEST_LD_ST_BYPASS(13, lb, sb, 0x01, 5, tdat );

  # Test sb and lbu (unsigned byte)
  TEST_LD_ST_BYPASS(14, lbu, sb, 0x33, 0, tdat );
  TEST_LD_ST_BYPASS(15, lbu, sb, 0x23, 1, tdat );
  TEST_LD_ST_BYPASS(16, lbu, sb, 0x22, 2, tdat );
  TEST_LD_ST_BYPASS(17, lbu, sb, 0x12, 3, tdat );
  TEST_LD_ST_BYPASS(18, lbu, sb, 0x11, 4, tdat );
  TEST_LD_ST_BYPASS(19, lbu, sb, 0x01, 5, tdat );

  li a0, 0xef         # Immediate load for manual store test
  la a1, tdat         # Load address of tdat
  sb a0, 3(a1)        # Store byte at offset 3 of tdat
  lb a2, 3(a1)        # Load byte back for verification

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdat:
    .rept 20
    .word 0xdeadbeef
    .endr


RVTEST_DATA_END
