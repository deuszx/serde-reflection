// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../Harness.sol";

/// Gas snapshot harness.
///
/// Each `bench_*` function calls a single Harness entry point with a
/// canonical input. `forge snapshot --check` compares each function's gas
/// against `../.gas-snapshot`; CI fails when the committed snapshot is out
/// of date.
///
/// To update the snapshot after a codegen change, from this directory:
///   cargo run --example generate_perf_library --features solidity   # in workspace root
///   forge snapshot
///   git add Library.sol .gas-snapshot
contract BenchTest {
    Harness h = new Harness();

    // ---- primitive scalars -----------------------------------------

    function test_ser_uint64_distinct_bytes() public view {
        h.ser_uint64(0x0102030405060708);
    }

    function test_deser_uint64_distinct_bytes() public view {
        h.deser_uint64(hex"0807060504030201");
    }

    function test_ser_uint128_distinct_bytes() public view {
        h.ser_uint128(0x0102030405060708090a0b0c0d0e0f10);
    }

    function test_deser_uint128_distinct_bytes() public view {
        h.deser_uint128(hex"100f0e0d0c0b0a090807060504030201");
    }

    function test_ser_uint32() public view {
        h.ser_uint32(0xdeadbeef);
    }

    // ---- bytes: empty / sub-word / one-word / multi-word -----------

    function test_ser_bytes_0() public view {
        h.ser_bytes("");
    }

    function test_ser_bytes_31() public view {
        bytes memory p = new bytes(31);
        for (uint256 i = 0; i < 31; i++) p[i] = bytes1(uint8(i));
        h.ser_bytes(p);
    }

    function test_ser_bytes_32() public view {
        bytes memory p = new bytes(32);
        for (uint256 i = 0; i < 32; i++) p[i] = bytes1(uint8(i));
        h.ser_bytes(p);
    }

    function test_ser_bytes_1024() public view {
        bytes memory p = new bytes(1024);
        for (uint256 i = 0; i < 1024; i++) p[i] = bytes1(uint8(i & 0xff));
        h.ser_bytes(p);
    }

    function test_deser_bytes_0() public view {
        // LEB128(0) = 0x00, no payload.
        h.deser_bytes(hex"00");
    }

    function test_deser_bytes_32() public view {
        bytes memory enc = new bytes(33);
        enc[0] = bytes1(uint8(32));
        for (uint256 i = 0; i < 32; i++) enc[i + 1] = bytes1(uint8(i));
        h.deser_bytes(enc);
    }

    function test_deser_bytes_1024() public view {
        bytes memory enc = new bytes(1026);
        // LEB128(1024) = 0x80 0x08.
        enc[0] = bytes1(uint8(0x80));
        enc[1] = bytes1(uint8(0x08));
        for (uint256 i = 0; i < 1024; i++) enc[i + 2] = bytes1(uint8(i & 0xff));
        h.deser_bytes(enc);
    }

    // ---- string ----------------------------------------------------

    function test_ser_string_short() public view {
        h.ser_string("perf-harness");
    }

    function test_deser_string_short() public view {
        // LEB128(12) = 0x0c, followed by "perf-harness".
        h.deser_string(hex"0c706572662d6861726e657373");
    }

    // ---- bytes32 ---------------------------------------------------

    function test_ser_bytes32() public view {
        h.ser_bytes32(0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20);
    }

    function test_deser_bytes32() public view {
        h.deser_bytes32(
            hex"0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
        );
    }

    // ---- seq<uint32> ------------------------------------------------

    function test_ser_seq_uint32_10() public view {
        uint32[] memory v = new uint32[](10);
        for (uint256 i = 0; i < 10; i++) v[i] = uint32(i * 7919);
        h.ser_seq_uint32(v);
    }

    function test_deser_seq_uint32_10() public view {
        // LEB128(10)=0x0a then 10 little-endian uint32s: i*7919 for i=0..9.
        h.deser_seq_uint32(
            hex"0a"
            hex"00000000"
            hex"ef1e0000"
            hex"de3d0000"
            hex"cd5c0000"
            hex"bc7b0000"
            hex"ab9a0000"
            hex"9ab90000"
            hex"89d80000"
            hex"78f70000"
            hex"67160100"
        );
    }

    // ---- opt<uint64> ------------------------------------------------

    function test_ser_opt_uint64_some() public view {
        h.ser_opt_uint64(true, 0x0102030405060708);
    }

    function test_ser_opt_uint64_none() public view {
        h.ser_opt_uint64(false, 0);
    }

    function test_deser_opt_uint64_some() public view {
        h.deser_opt_uint64(hex"010807060504030201");
    }

    function test_deser_opt_uint64_none() public view {
        h.deser_opt_uint64(hex"00");
    }

    // ---- tuplearray3<uint32> ---------------------------------------

    function test_ser_tuplearray3_uint32() public view {
        h.ser_tuplearray3_uint32(1, 2, 3);
    }

    function test_deser_tuplearray3_uint32() public view {
        // 3 little-endian uint32: 1, 2, 3.
        h.deser_tuplearray3_uint32(hex"010000000200000003000000");
    }

    // ---- PerfEnum --------------------------------------------------

    function test_ser_enum_empty() public view {
        h.ser_enum_empty();
    }

    function test_ser_enum_tag() public view {
        h.ser_enum_tag(0xdeadbeef);
    }

    function test_ser_enum_named_short() public view {
        h.ser_enum_named("alice", 7);
    }

    function test_deser_enum_empty() public view {
        h.deser_enum(hex"00");
    }

    function test_deser_enum_tag() public view {
        h.deser_enum(hex"01efbeadde");
    }

    // ---- PerfStruct -------------------------------------------------

    function test_ser_perf_struct() public view {
        bytes memory payload = new bytes(64);
        for (uint256 i = 0; i < 64; i++) payload[i] = bytes1(uint8(i));
        uint32[] memory items = new uint32[](4);
        items[0] = 1;
        items[1] = 2;
        items[2] = 3;
        items[3] = 4;
        h.ser_perf_struct(
            true,
            0x0102030405060708,
            0x0102030405060708090a0b0c0d0e0f10,
            "perf-harness",
            payload,
            items,
            0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20,
            10, 20, 30,
            true,
            0xfeedbeefdeadc0de
        );
    }
}
