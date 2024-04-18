#[allow(warnings)]
mod bindings;

use bindings::exports::docs::calculator::calculate::Operation;

use crate::bindings::docs::math::basic::{add, div, mul, sub};
use crate::bindings::exports::docs::calculator::calculate::Guest;

struct Component;

impl Guest for Component {
    fn eval_expression(expr: String) -> i64 {
        let num = expr.len().try_into().unwrap();
        add(num, num)
    }

    fn calc_expression(op: Operation, lhs: i64, rhs: i64) -> i64 {
        match op {
            Operation::Add => add(lhs, rhs),
            Operation::Sub => sub(lhs, rhs),
            Operation::Mul => mul(lhs, rhs),
            Operation::Div => div(lhs, rhs),
        }
    }
}

bindings::export!(Component with_types_in bindings);
