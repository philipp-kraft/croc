# See LICENSE for license details.

#*****************************************************************************
# st_ld.S
#-----------------------------------------------------------------------------
#
# Test store and load instructions
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Bypassing Tests
  #-------------------------------------------------------------

  # Test sb and lb (signed byte)
  TEST_ST_LD_BYPASS(2,  lb,  sb, 0xffffffffffffffdd, 0, tdat );
  TEST_ST_LD_BYPASS(3,  lb,  sb, 0xffffffffffffffcd, 1, tdat );
  TEST_ST_LD_BYPASS(4,  lb,  sb, 0xffffffffffffffcc, 2, tdat );
  TEST_ST_LD_BYPASS(5,  lb,  sb, 0xffffffffffffffbc, 3, tdat );
  TEST_ST_LD_BYPASS(6,  lb,  sb, 0xffffffffffffffbb, 4, tdat );
  TEST_ST_LD_BYPASS(7,  lb,  sb, 0xffffffffffffffab, 5, tdat );

  TEST_ST_LD_BYPASS(8,  lb, sb, 0x33, 0, tdat );
  TEST_ST_LD_BYPASS(9,  lb, sb, 0x23, 1, tdat );
  TEST_ST_LD_BYPASS(10, lb, sb, 0x22, 2, tdat );
  TEST_ST_LD_BYPASS(11, lb, sb, 0x12, 3, tdat );
  TEST_ST_LD_BYPASS(12, lb, sb, 0x11, 4, tdat );
  TEST_ST_LD_BYPASS(13, lb, sb, 0x01, 5, tdat );

  # Test sb and lbu (unsigned byte)
  TEST_ST_LD_BYPASS(14, lbu, sb, 0x33, 0, tdat );
  TEST_ST_LD_BYPASS(15, lbu, sb, 0x23, 1, tdat );
  TEST_ST_LD_BYPASS(16, lbu, sb, 0x22, 2, tdat );
  TEST_ST_LD_BYPASS(17, lbu, sb, 0x12, 3, tdat );
  TEST_ST_LD_BYPASS(18, lbu, sb, 0x11, 4, tdat );
  TEST_ST_LD_BYPASS(19, lbu, sb, 0x01, 5, tdat );

  # Test sw and lw (signed word)
  TEST_ST_LD_BYPASS(20, lw, sw, 0xffffffffaabbccdd, 0,  tdat );
  TEST_ST_LD_BYPASS(21, lw, sw, 0xffffffffdaabbccd, 4,  tdat );
  TEST_ST_LD_BYPASS(22, lw, sw, 0xffffffffddaabbcc, 8,  tdat );
  TEST_ST_LD_BYPASS(23, lw, sw, 0xffffffffcddaabbc, 12, tdat );
  TEST_ST_LD_BYPASS(24, lw, sw, 0xffffffffccddaabb, 16, tdat );
  TEST_ST_LD_BYPASS(25, lw, sw, 0xffffffffbccddaab, 20, tdat );

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
