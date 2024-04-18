set positional-arguments

@default:
    just --choose

run *args: build
    WASMTIME_NEW_CLI=1 wasmtime run standalone/target/wasm32-wasi/release/standalone-linked.wasm $@

build: build-math build-calculator build-standalone
    wasm-tools compose calculator/target/wasm32-wasi/release/calculator.wasm \
        -d math/target/wasm32-wasi/release/math.wasm \
        -o calculator/target/wasm32-wasi/release/calculator-linked.wasm
    wasm-tools compose standalone/target/wasm32-wasi/release/standalone.wasm \
        -d calculator/target/wasm32-wasi/release/calculator-linked.wasm \
        -o standalone/target/wasm32-wasi/release/standalone-linked.wasm

clean: clean-math clean-calculator clean-standalone clean-changelog

@build-math:
    cd math && cargo component build --release

@build-calculator:
    cd calculator && cargo component build --release

@build-standalone:
    cd standalone && cargo component build --release

@clean-math:
    cd math && cargo clean

@clean-calculator:
    cd calculator && cargo clean

@clean-standalone:
    cd standalone && cargo clean

show: build
    wasm-tools component wit math/target/wasm32-wasi/release/math.wasm
    wasm-tools component wit calculator/target/wasm32-wasi/release/calculator.wasm
    wasm-tools component wit standalone/target/wasm32-wasi/release/standalone.wasm

show-linked: build
    wasm-tools component wit calculator/target/wasm32-wasi/release/calculator-linked.wasm
    wasm-tools component wit standalone/target/wasm32-wasi/release/standalone-linked.wasm