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

  # Test sh and lh (signed halfword)
  TEST_LD_ST_BYPASS(32, lh, sh, 0xffffffffffffccdd, 0, tdat );
  TEST_LD_ST_BYPASS(33, lh, sh, 0xffffffffffffbccd, 2, tdat );
  TEST_LD_ST_BYPASS(34, lh, sh, 0xffffffffffffbbcc, 4, tdat );
  TEST_LD_ST_BYPASS(35, lh, sh, 0xffffffffffffabbc, 6, tdat );
  TEST_LD_ST_BYPASS(36, lh, sh, 0xffffffffffffaabb, 8, tdat );
  TEST_LD_ST_BYPASS(37, lh, sh, 0xffffffffffffdaab, 10, tdat );

  TEST_LD_ST_BYPASS(38, lh, sh, 0x2233, 0, tdat );
  TEST_LD_ST_BYPASS(39, lh, sh, 0x1223, 2, tdat );
  TEST_LD_ST_BYPASS(40, lh, sh, 0x1122, 4, tdat );
  TEST_LD_ST_BYPASS(41, lh, sh, 0x0112, 6, tdat );
  TEST_LD_ST_BYPASS(42, lh, sh, 0x0011, 8, tdat );
  TEST_LD_ST_BYPASS(43, lh, sh, 0x3001, 10, tdat );

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
