#[allow(warnings)]
mod bindings;

use bindings::docs::calculator::calculate::{calc_expression, Operation};
use clap::builder::TypedValueParser;
use clap::Parser;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    match CalcApp::try_parse() {
        Ok(CalcApp { lhs, op, rhs }) => {
            let result = calc_expression(op, lhs, rhs);
            println!("got {result}");
            Ok(())
        }
        Err(err) if err.kind() == clap::error::ErrorKind::DisplayHelp => {
            println!("{}", err.render());
            Ok(())
        }
        Err(err) => {
            println!("{}", err.render());
            Err("wrong usage of cli".into())
        }
    }
}

/// A CLI for executing WebAssembly components that
/// implement the `example` world.
#[derive(Parser)]
#[clap(version = env!("CARGO_PKG_VERSION"))]
struct CalcApp {
    lhs: i64,
    #[arg(
        value_parser = clap::builder::PossibleValuesParser::new([OP_ADD, OP_SUB, OP_MUL, OP_DIV])
            .map(|s| s.parse::<Operation>().unwrap())
    )]
    op: Operation,
    rhs: i64,
}

const OP_ADD: &str = "add";
const OP_SUB: &str = "sub";
const OP_MUL: &str = "mul";
const OP_DIV: &str = "div";

impl std::fmt::Display for Operation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = match self {
            Operation::Add => OP_ADD,
            Operation::Sub => OP_SUB,
            Operation::Mul => OP_MUL,
            Operation::Div => OP_DIV,
        };
        s.fmt(f)
    }
}
impl std::str::FromStr for Operation {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            OP_ADD => Ok(Operation::Add),
            OP_SUB => Ok(Operation::Sub),
            OP_MUL => Ok(Operation::Mul),
            OP_DIV => Ok(Operation::Div),
            _ => Err(format!("Unknown log level: {s}")),
        }
    }
}
