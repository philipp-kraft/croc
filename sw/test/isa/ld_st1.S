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

  # Test sw and lw (signed word)
  TEST_LD_ST_BYPASS(20, lw, sw, 0xffffffffaabbccdd, 0,  tdat );
  TEST_LD_ST_BYPASS(21, lw, sw, 0xffffffffdaabbccd, 4,  tdat );
  TEST_LD_ST_BYPASS(22, lw, sw, 0xffffffffddaabbcc, 8,  tdat );
  TEST_LD_ST_BYPASS(23, lw, sw, 0xffffffffcddaabbc, 12, tdat );
  TEST_LD_ST_BYPASS(24, lw, sw, 0xffffffffccddaabb, 16, tdat );
  TEST_LD_ST_BYPASS(25, lw, sw, 0xffffffffbccddaab, 20, tdat );

  TEST_LD_ST_BYPASS(26, lw, sw, 0x00112233, 0,  tdat );
  TEST_LD_ST_BYPASS(27, lw, sw, 0x30011223, 4,  tdat );
  TEST_LD_ST_BYPASS(28, lw, sw, 0x33001122, 8,  tdat );
  TEST_LD_ST_BYPASS(29, lw, sw, 0x23300112, 12, tdat );
  TEST_LD_ST_BYPASS(30, lw, sw, 0x22330011, 16, tdat );
  TEST_LD_ST_BYPASS(31, lw, sw, 0x12233001, 20, tdat );

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
