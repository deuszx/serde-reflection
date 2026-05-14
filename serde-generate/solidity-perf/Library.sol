/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library PerfLib {

    function bcs_serialize_len(uint256 x)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result;
        bytes1 entry;
        while (true) {
            if (x < 128) {
                entry = bytes1(uint8(x));
                return abi.encodePacked(result, entry);
            } else {
                uint256 xb = x >> 7;
                uint256 remainder = x - (xb << 7);
                require(remainder < 128);
                entry = bytes1(uint8(remainder) + 128);
                result = abi.encodePacked(result, entry);
                x = xb;
            }
        }
        require(false, "This line is unreachable");
        return result;
    }

    function bcs_deserialize_offset_len(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint256)
    {
        uint256 idx = 0;
        while (true) {
            if (uint8(input[pos + idx]) < 128) {
                uint256 result = 0;
                uint256 power = 1;
                for (uint256 u=0; u<idx; u++) {
                    uint8 val = uint8(input[pos + u]) - 128;
                    result += power * uint256(val);
                    power *= 128;
                }
                result += power * uint8(input[pos + idx]);
                return (pos + idx + 1, result);
            }
            idx += 1;
        }
        require(false, "This line is unreachable");
        return (0,0);
    }

    struct PerfEnum {
        uint8 choice;
        // choice=0 corresponds to Empty
        // choice=1 corresponds to Tag
        uint32 tag;
        // choice=2 corresponds to Named
        PerfEnum_Named named;
    }

    function PerfEnum_case_empty()
        internal
        pure
        returns (PerfEnum memory)
    {
        uint32 tag;
        PerfEnum_Named memory named;
        return PerfEnum(uint8(0), tag, named);
    }

    function PerfEnum_case_tag(uint32 tag)
        internal
        pure
        returns (PerfEnum memory)
    {
        PerfEnum_Named memory named;
        return PerfEnum(uint8(1), tag, named);
    }

    function PerfEnum_case_named(PerfEnum_Named memory named)
        internal
        pure
        returns (PerfEnum memory)
    {
        uint32 tag;
        return PerfEnum(uint8(2), tag, named);
    }

    function bcs_serialize_PerfEnum(PerfEnum memory input)
        internal
        pure
        returns (bytes memory)
    {
        if (input.choice == 1) {
            return abi.encodePacked(input.choice, bcs_serialize_uint32(input.tag));
        }
        if (input.choice == 2) {
            return abi.encodePacked(input.choice, bcs_serialize_PerfEnum_Named(input.named));
        }
        return abi.encodePacked(input.choice);
    }

    function bcs_deserialize_offset_PerfEnum(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, PerfEnum memory)
    {
        uint256 new_pos;
        uint8 choice;
        (new_pos, choice) = bcs_deserialize_offset_uint8(pos, input);
        uint32 tag;
        if (choice == 1) {
            (new_pos, tag) = bcs_deserialize_offset_uint32(new_pos, input);
        }
        PerfEnum_Named memory named;
        if (choice == 2) {
            (new_pos, named) = bcs_deserialize_offset_PerfEnum_Named(new_pos, input);
        }
        require(choice < 3);
        return (new_pos, PerfEnum(choice, tag, named));
    }

    function bcs_deserialize_PerfEnum(bytes memory input)
        internal
        pure
        returns (PerfEnum memory)
    {
        uint256 new_pos;
        PerfEnum memory value;
        (new_pos, value) = bcs_deserialize_offset_PerfEnum(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    struct PerfEnum_Named {
        string name;
        uint64 count;
    }

    function bcs_serialize_PerfEnum_Named(PerfEnum_Named memory input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = bcs_serialize_string(input.name);
        return abi.encodePacked(result, bcs_serialize_uint64(input.count));
    }

    function bcs_deserialize_offset_PerfEnum_Named(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, PerfEnum_Named memory)
    {
        uint256 new_pos;
        string memory name;
        (new_pos, name) = bcs_deserialize_offset_string(pos, input);
        uint64 count;
        (new_pos, count) = bcs_deserialize_offset_uint64(new_pos, input);
        return (new_pos, PerfEnum_Named(name, count));
    }

    function bcs_deserialize_PerfEnum_Named(bytes memory input)
        internal
        pure
        returns (PerfEnum_Named memory)
    {
        uint256 new_pos;
        PerfEnum_Named memory value;
        (new_pos, value) = bcs_deserialize_offset_PerfEnum_Named(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    struct PerfStruct {
        bool flag;
        uint64 counter;
        uint128 nonce;
        string label;
        bytes payload;
        uint32[] items;
        bytes32 bytes32_;
        tuplearray3_uint32 triple;
        opt_uint64 maybe;
    }

    function bcs_serialize_PerfStruct(PerfStruct memory input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = bcs_serialize_bool(input.flag);
        result = abi.encodePacked(result, bcs_serialize_uint64(input.counter));
        result = abi.encodePacked(result, bcs_serialize_uint128(input.nonce));
        result = abi.encodePacked(result, bcs_serialize_string(input.label));
        result = abi.encodePacked(result, bcs_serialize_bytes(input.payload));
        result = abi.encodePacked(result, bcs_serialize_seq_uint32(input.items));
        result = abi.encodePacked(result, bcs_serialize_bytes32(input.bytes32_));
        result = abi.encodePacked(result, bcs_serialize_tuplearray3_uint32(input.triple));
        return abi.encodePacked(result, bcs_serialize_opt_uint64(input.maybe));
    }

    function bcs_deserialize_offset_PerfStruct(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, PerfStruct memory)
    {
        uint256 new_pos;
        bool flag;
        (new_pos, flag) = bcs_deserialize_offset_bool(pos, input);
        uint64 counter;
        (new_pos, counter) = bcs_deserialize_offset_uint64(new_pos, input);
        uint128 nonce;
        (new_pos, nonce) = bcs_deserialize_offset_uint128(new_pos, input);
        string memory label;
        (new_pos, label) = bcs_deserialize_offset_string(new_pos, input);
        bytes memory payload;
        (new_pos, payload) = bcs_deserialize_offset_bytes(new_pos, input);
        uint32[] memory items;
        (new_pos, items) = bcs_deserialize_offset_seq_uint32(new_pos, input);
        bytes32 bytes32_;
        (new_pos, bytes32_) = bcs_deserialize_offset_bytes32(new_pos, input);
        tuplearray3_uint32 memory triple;
        (new_pos, triple) = bcs_deserialize_offset_tuplearray3_uint32(new_pos, input);
        opt_uint64 memory maybe;
        (new_pos, maybe) = bcs_deserialize_offset_opt_uint64(new_pos, input);
        return (new_pos, PerfStruct(flag, counter, nonce, label, payload, items, bytes32_, triple, maybe));
    }

    function bcs_deserialize_PerfStruct(bytes memory input)
        internal
        pure
        returns (PerfStruct memory)
    {
        uint256 new_pos;
        PerfStruct memory value;
        (new_pos, value) = bcs_deserialize_offset_PerfStruct(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_bool(bool input)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(input);
    }

    function bcs_deserialize_offset_bool(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, bool)
    {
        uint8 val = uint8(input[pos]);
        bool result = false;
        if (val == 1) {
            result = true;
        } else {
            require(val == 0);
        }
        return (pos + 1, result);
    }

    function bcs_deserialize_bool(bytes memory input)
        internal
        pure
        returns (bool)
    {
        uint256 new_pos;
        bool value;
        (new_pos, value) = bcs_deserialize_offset_bool(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_bytes(bytes memory input)
        internal
        pure
        returns (bytes memory)
    {
        uint256 len = input.length;
        bytes memory result = bcs_serialize_len(len);
        return abi.encodePacked(result, input);
    }

    function bcs_deserialize_offset_bytes(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, bytes memory)
    {
        uint256 len;
        uint256 new_pos;
        (new_pos, len) = bcs_deserialize_offset_len(pos, input);
        bytes memory result = new bytes(len);
        for (uint256 u=0; u<len; u++) {
            result[u] = input[new_pos + u];
        }
        return (new_pos + len, result);
    }

    function bcs_deserialize_bytes(bytes memory input)
        internal
        pure
        returns (bytes memory)
    {
        uint256 new_pos;
        bytes memory value;
        (new_pos, value) = bcs_deserialize_offset_bytes(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_bytes32(bytes32 input)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(input);
    }

    function bcs_deserialize_offset_bytes32(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, bytes32)
    {
        bytes32 dest;
        assembly {
            dest := mload(add(add(input, 0x20), pos))
        }
        return (pos + 32, dest);
    }

    struct opt_uint64 {
        bool has_value;
        uint64 value;
    }

    function bcs_serialize_opt_uint64(opt_uint64 memory input)
        internal
        pure
        returns (bytes memory)
    {
        if (input.has_value) {
            return abi.encodePacked(uint8(1), bcs_serialize_uint64(input.value));
        } else {
            return abi.encodePacked(uint8(0));
        }
    }

    function bcs_deserialize_offset_opt_uint64(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, opt_uint64 memory)
    {
        uint256 new_pos;
        bool has_value;
        (new_pos, has_value) = bcs_deserialize_offset_bool(pos, input);
        uint64 value;
        if (has_value) {
            (new_pos, value) = bcs_deserialize_offset_uint64(new_pos, input);
        }
        return (new_pos, opt_uint64(has_value, value));
    }

    function bcs_deserialize_opt_uint64(bytes memory input)
        internal
        pure
        returns (opt_uint64 memory)
    {
        uint256 new_pos;
        opt_uint64 memory value;
        (new_pos, value) = bcs_deserialize_offset_opt_uint64(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_seq_uint32(uint32[] memory input)
        internal
        pure
        returns (bytes memory)
    {
        uint256 len = input.length;
        bytes memory result = bcs_serialize_len(len);
        for (uint256 i=0; i<len; i++) {
            result = abi.encodePacked(result, bcs_serialize_uint32(input[i]));
        }
        return result;
    }

    function bcs_deserialize_offset_seq_uint32(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint32[] memory)
    {
        uint256 len;
        uint256 new_pos;
        (new_pos, len) = bcs_deserialize_offset_len(pos, input);
        uint32[] memory result;
        result = new uint32[](len);
        uint32 value;
        for (uint256 i=0; i<len; i++) {
            (new_pos, value) = bcs_deserialize_offset_uint32(new_pos, input);
            result[i] = value;
        }
        return (new_pos, result);
    }

    function bcs_deserialize_seq_uint32(bytes memory input)
        internal
        pure
        returns (uint32[] memory)
    {
        uint256 new_pos;
        uint32[] memory value;
        (new_pos, value) = bcs_deserialize_offset_seq_uint32(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_string(string memory input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory input_bytes = bytes(input);
        uint256 number_bytes = input_bytes.length;
        uint256 number_char = 0;
        uint256 pos = 0;
        while (true) {
            if (uint8(input_bytes[pos]) < 128) {
                number_char += 1;
            }
            pos += 1;
            if (pos == number_bytes) {
                break;
            }
        }
        bytes memory result_len = bcs_serialize_len(number_char);
        return abi.encodePacked(result_len, input);
    }

    function bcs_deserialize_offset_string(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, string memory)
    {
        uint256 len;
        uint256 new_pos;
        (new_pos, len) = bcs_deserialize_offset_len(pos, input);
        uint256 shift = 0;
        for (uint256 i=0; i<len; i++) {
            while (true) {
                bytes1 val = input[new_pos + shift];
                shift += 1;
                if (uint8(val) < 128) {
                    break;
                }
            }
        }
        bytes memory result_bytes = new bytes(shift);
        for (uint256 i=0; i<shift; i++) {
            result_bytes[i] = input[new_pos + i];
        }
        string memory result = string(result_bytes);
        return (new_pos + shift, result);
    }


    function bcs_deserialize_string(bytes memory input)
        internal
        pure
        returns (string memory)
    {
        uint256 new_pos;
        string memory value;
        (new_pos, value) = bcs_deserialize_offset_string(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    struct tuplearray3_uint32 {
        uint32[] values;
    }

    function bcs_serialize_tuplearray3_uint32(tuplearray3_uint32 memory input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result;
        for (uint i=0; i<3; i++) {
            result = abi.encodePacked(result, bcs_serialize_uint32(input.values[i]));
        }
        return result;
    }

    function bcs_deserialize_offset_tuplearray3_uint32(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, tuplearray3_uint32 memory)
    {
        uint256 new_pos = pos;
        uint32 value;
        uint32[] memory values;
        values = new uint32[](3);
        for (uint i=0; i<3; i++) {
            (new_pos, value) = bcs_deserialize_offset_uint32(new_pos, input);
            values[i] = value;
        }
        return (new_pos, tuplearray3_uint32(values));
    }

    function bcs_deserialize_tuplearray3_uint32(bytes memory input)
        internal
        pure
        returns (tuplearray3_uint32 memory)
    {
        uint256 new_pos;
        tuplearray3_uint32 memory value;
        (new_pos, value) = bcs_deserialize_offset_tuplearray3_uint32(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_uint128(uint128 input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(16);
        uint128 value = input;
        result[0] = bytes1(uint8(value));
        for (uint i=1; i<16; i++) {
            value = value >> 8;
            result[i] = bytes1(uint8(value));
        }
        return result;
    }

    function bcs_deserialize_offset_uint128(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint128)
    {
        uint128 value = uint8(input[pos + 15]);
        for (uint256 i=0; i<15; i++) {
            value = value << 8;
            value += uint8(input[pos + 14 - i]);
        }
        return (pos + 16, value);
    }

    function bcs_deserialize_uint128(bytes memory input)
        internal
        pure
        returns (uint128)
    {
        uint256 new_pos;
        uint128 value;
        (new_pos, value) = bcs_deserialize_offset_uint128(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_uint32(uint32 input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(4);
        uint32 value = input;
        result[0] = bytes1(uint8(value));
        for (uint i=1; i<4; i++) {
            value = value >> 8;
            result[i] = bytes1(uint8(value));
        }
        return result;
    }

    function bcs_deserialize_offset_uint32(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint32)
    {
        uint32 value = uint8(input[pos + 3]);
        for (uint256 i=0; i<3; i++) {
            value = value << 8;
            value += uint8(input[pos + 2 - i]);
        }
        return (pos + 4, value);
    }

    function bcs_deserialize_uint32(bytes memory input)
        internal
        pure
        returns (uint32)
    {
        uint256 new_pos;
        uint32 value;
        (new_pos, value) = bcs_deserialize_offset_uint32(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_uint64(uint64 input)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(8);
        uint64 value = input;
        result[0] = bytes1(uint8(value));
        for (uint i=1; i<8; i++) {
            value = value >> 8;
            result[i] = bytes1(uint8(value));
        }
        return result;
    }

    function bcs_deserialize_offset_uint64(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint64)
    {
        uint64 value = uint8(input[pos + 7]);
        for (uint256 i=0; i<7; i++) {
            value = value << 8;
            value += uint8(input[pos + 6 - i]);
        }
        return (pos + 8, value);
    }

    function bcs_deserialize_uint64(bytes memory input)
        internal
        pure
        returns (uint64)
    {
        uint256 new_pos;
        uint64 value;
        (new_pos, value) = bcs_deserialize_offset_uint64(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

    function bcs_serialize_uint8(uint8 input)
        internal
        pure
        returns (bytes memory)
    {
      return abi.encodePacked(input);
    }

    function bcs_deserialize_offset_uint8(uint256 pos, bytes memory input)
        internal
        pure
        returns (uint256, uint8)
    {
        uint8 value = uint8(input[pos]);
        return (pos + 1, value);
    }

    function bcs_deserialize_uint8(bytes memory input)
        internal
        pure
        returns (uint8)
    {
        uint256 new_pos;
        uint8 value;
        (new_pos, value) = bcs_deserialize_offset_uint8(0, input);
        require(new_pos == input.length, "incomplete deserialization");
        return value;
    }

} // end of library PerfLib
