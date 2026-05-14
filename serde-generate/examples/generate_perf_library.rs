//! Generate `solidity-perf/Library.sol` from a canonical registry that covers
//! every codegen arm the gas snapshot benchmarks rely on (primitive ints,
//! `bytes`, `string`, `Vec<T>`, `Option<T>`, fixed-size arrays, simple and
//! complex enums, nested structs).
//!
//! Re-run this example after any change to `src/solidity.rs` and commit the
//! resulting `Library.sol` so that `forge snapshot --check` and the CI diff
//! step both see the updated codegen.
//!
//! Usage:
//!   cargo run --example generate_perf_library --features solidity
//!
//! The output is written to `serde-generate/solidity-perf/Library.sol`,
//! relative to the workspace root (the path is anchored on `CARGO_MANIFEST_DIR`).

use std::path::PathBuf;

use serde::{Deserialize, Serialize};
use serde_generate::{solidity, CodeGeneratorConfig};
use serde_reflection::{Samples, Tracer, TracerConfig};

#[derive(Serialize, Deserialize)]
pub struct PerfStruct {
    pub flag: bool,
    pub counter: u64,
    pub nonce: u128,
    pub label: String,
    #[serde(with = "serde_bytes")]
    pub payload: Vec<u8>,
    pub items: Vec<u32>,
    pub bytes32: [u8; 32],
    pub triple: [u32; 3],
    pub maybe: Option<u64>,
}

#[derive(Serialize, Deserialize)]
pub enum PerfEnum {
    Empty,
    Tag(u32),
    Named { name: String, count: u64 },
}

fn main() {
    let manifest_dir =
        PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"));
    let out_path = manifest_dir.join("solidity-perf").join("Library.sol");

    let mut tracer = Tracer::new(TracerConfig::default());
    let samples = Samples::new();
    tracer
        .trace_type::<PerfStruct>(&samples)
        .expect("trace PerfStruct");
    tracer
        .trace_type::<PerfEnum>(&samples)
        .expect("trace PerfEnum");
    let registry = tracer.registry().expect("registry");

    let config = CodeGeneratorConfig::new("PerfLib".to_string());
    let generator = solidity::CodeGenerator::new(&config);

    std::fs::create_dir_all(out_path.parent().unwrap()).expect("mkdir");
    let mut out = std::fs::File::create(&out_path).expect("open Library.sol");
    generator
        .output(&mut out, &registry)
        .expect("generate Library.sol");

    eprintln!("wrote {}", out_path.display());
}
