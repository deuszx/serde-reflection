// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Library.sol";

/// External entry points exercised by `test/Bench.t.sol`.
///
/// Each `ser_*` / `deser_*` function delegates straight to the inlined
/// `PerfLib.bcs_*` helper so that `forge test --gas-report` measures the
/// generated code, not the bench scaffolding.
///
/// Inputs are accepted via `bytes calldata` (for deserialize) or named
/// arguments (for serialize); the harness contract is otherwise stateless.
contract Harness {
    // -------------------------------------------------------------------
    // Primitive (de)serializers
    // -------------------------------------------------------------------

    function ser_uint64(uint64 x) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_uint64(x);
    }

    function deser_uint64(bytes calldata input) external pure returns (uint256, uint64) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_uint64(0, mem);
    }

    function ser_uint128(uint128 x) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_uint128(x);
    }

    function deser_uint128(bytes calldata input) external pure returns (uint256, uint128) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_uint128(0, mem);
    }

    function ser_uint32(uint32 x) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_uint32(x);
    }

    // -------------------------------------------------------------------
    // bytes / string
    // -------------------------------------------------------------------

    function ser_bytes(bytes calldata input) external pure returns (bytes memory) {
        bytes memory mem = input;
        return PerfLib.bcs_serialize_bytes(mem);
    }

    function deser_bytes(bytes calldata input) external pure returns (uint256, bytes memory) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_bytes(0, mem);
    }

    function ser_string(string calldata input) external pure returns (bytes memory) {
        string memory mem = input;
        return PerfLib.bcs_serialize_string(mem);
    }

    function deser_string(bytes calldata input) external pure returns (uint256, string memory) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_string(0, mem);
    }

    function ser_bytes32(bytes32 input) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_bytes32(input);
    }

    function deser_bytes32(bytes calldata input) external pure returns (uint256, bytes32) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_bytes32(0, mem);
    }

    // -------------------------------------------------------------------
    // Composite types
    // -------------------------------------------------------------------

    function ser_seq_uint32(uint32[] calldata input) external pure returns (bytes memory) {
        uint32[] memory mem = input;
        return PerfLib.bcs_serialize_seq_uint32(mem);
    }

    function deser_seq_uint32(bytes calldata input) external pure returns (uint256, uint32[] memory) {
        bytes memory mem = input;
        return PerfLib.bcs_deserialize_offset_seq_uint32(0, mem);
    }

    function ser_opt_uint64(bool has_value, uint64 value) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_opt_uint64(PerfLib.opt_uint64(has_value, value));
    }

    function deser_opt_uint64(bytes calldata input) external pure returns (uint256, bool, uint64) {
        bytes memory mem = input;
        (uint256 new_pos, PerfLib.opt_uint64 memory v) = PerfLib.bcs_deserialize_offset_opt_uint64(0, mem);
        return (new_pos, v.has_value, v.value);
    }

    function ser_tuplearray3_uint32(uint32 a, uint32 b, uint32 c) external pure returns (bytes memory) {
        uint32[] memory values = new uint32[](3);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        return PerfLib.bcs_serialize_tuplearray3_uint32(PerfLib.tuplearray3_uint32(values));
    }

    function deser_tuplearray3_uint32(bytes calldata input)
        external pure returns (uint256, uint32, uint32, uint32)
    {
        bytes memory mem = input;
        (uint256 new_pos, PerfLib.tuplearray3_uint32 memory v) =
            PerfLib.bcs_deserialize_offset_tuplearray3_uint32(0, mem);
        return (new_pos, v.values[0], v.values[1], v.values[2]);
    }

    // -------------------------------------------------------------------
    // Struct + Enum
    // -------------------------------------------------------------------

    function ser_perf_struct(
        bool flag,
        uint64 counter,
        uint128 nonce,
        string calldata label,
        bytes calldata payload,
        uint32[] calldata items,
        bytes32 b32,
        uint32 t0,
        uint32 t1,
        uint32 t2,
        bool maybe_has,
        uint64 maybe_value
    ) external pure returns (bytes memory) {
        uint32[] memory triple = new uint32[](3);
        triple[0] = t0;
        triple[1] = t1;
        triple[2] = t2;
        PerfLib.PerfStruct memory s = PerfLib.PerfStruct({
            flag: flag,
            counter: counter,
            nonce: nonce,
            label: label,
            payload: payload,
            items: items,
            bytes32_: b32,
            triple: PerfLib.tuplearray3_uint32(triple),
            maybe: PerfLib.opt_uint64(maybe_has, maybe_value)
        });
        return PerfLib.bcs_serialize_PerfStruct(s);
    }

    function deser_perf_struct(bytes calldata input)
        external pure returns (uint256, uint64, uint128)
    {
        bytes memory mem = input;
        (uint256 new_pos, PerfLib.PerfStruct memory s) =
            PerfLib.bcs_deserialize_offset_PerfStruct(0, mem);
        return (new_pos, s.counter, s.nonce);
    }

    function ser_enum_empty() external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_PerfEnum(PerfLib.PerfEnum_case_empty());
    }

    function ser_enum_tag(uint32 v) external pure returns (bytes memory) {
        return PerfLib.bcs_serialize_PerfEnum(PerfLib.PerfEnum_case_tag(v));
    }

    function ser_enum_named(string calldata name, uint64 count) external pure returns (bytes memory) {
        PerfLib.PerfEnum_Named memory named = PerfLib.PerfEnum_Named({name: name, count: count});
        return PerfLib.bcs_serialize_PerfEnum(PerfLib.PerfEnum_case_named(named));
    }

    function deser_enum(bytes calldata input) external pure returns (uint256, uint8) {
        bytes memory mem = input;
        (uint256 new_pos, PerfLib.PerfEnum memory e) = PerfLib.bcs_deserialize_offset_PerfEnum(0, mem);
        return (new_pos, e.choice);
    }
}
